package ory.glob

import data.store.ory.glob as store
import data.ory.core as core
import data.ory.condition as condition
import input as request

default allow = false
default allowed_subjects = []

allow {
    decide_allow(store.policies, store.roles)
}

allowed_subjects = subjects {
    subjects := decide_allowed_subjects(store.policies, store.roles)
}

decide_allow(policies, roles) {
    effects := [effect | effect := policies[i].effect
        core.match_glob(policies[i].resources, request.resource)
        match_subjects(policies[i].subjects, roles, request.subject)
        core.match_glob(policies[i].actions, request.action)
        condition.all_conditions_true(policies[i])
    ]

    count(effects, c)
    c > 0

    core.effect_allow(effects)
}

# Return a set of subjects that are allowed (and are not denied) to do a certain
# action
decide_allowed_subjects(policies, roles) = subjects {
    # A "flag" which is not defined on the regular /allowed API call, thus
    # skipping the execution of this whole function which can be slow
    request.context.__ory_allowed_subjects

    # List of matching policies which effect is "allow"
    matching_allow_policies := [ policy |
        policy := policies[_]

        policy.effect == "allow"
        core.match_glob(policy.resources, request.resource)
        core.match_glob(policy.actions, request.action)
        condition.all_conditions_true(policy)
    ]

    # List of matching policies which effect is "deny"
    matching_deny_policies := [ policy |
        policy := policies[_]

        policy.effect == "deny"
        core.match_glob(policy.resources, request.resource)
        core.match_glob(policy.actions, request.action)
        condition.all_conditions_true(policy)
    ]

    # The final set of subjects is the set of subjects allowed to do the action
    # subtracted by the set of subjetcs denied
    allowed_subjects := _get_subjects(matching_allow_policies, roles)
    denied_subjects := _get_subjects(matching_deny_policies, roles)

    subjects := allowed_subjects - denied_subjects
}

# Returns all subjects of a list of policies, including members of roles that
# are configured to be one of the policies' subjects
_get_subjects(policies, roles) = subjects {
    # Set of subjects for each policy
    policy_subjects := { subjects |
        policy := policies[_]

        # Set of subjects (not roles) from the policy's $.subjects field
        subjects_from_policy := { subject |
            subject := policy.subjects[_]

            # Exclude if the "subject" is actually a role
            roles_with_same_id := [ role_id | role_id := roles[_].id; role_id == subject ]
            count(roles_with_same_id) == 0
        }

        # Set of subjects from roles in the policy's $.subjects field
        subjects_from_roles := { subject |
            role_id := policy.subjects[_]

            # Only include if the "subject" is actually a role
            roles[i].id == role_id

            subject := roles[i].members[_]
        }

        # Union the two sets
        subjects := subjects_from_policy | subjects_from_roles
    }

    # Union all the sets from each policies
    subjects := union(policy_subjects)
}

match_subjects(matches, roles, subject) {
    core.match_glob(matches, subject)
} {
    r := core.role_ids_glob(roles, subject)
    rr := r[_]
    core.match_glob(matches, rr)
}
