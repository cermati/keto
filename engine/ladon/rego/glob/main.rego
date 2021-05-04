package ory.glob

import data.store.ory.glob as store
import data.ory.core as core
import data.ory.condition as condition
import input as request

default allow = false

allow {
    decide_allow(store.policies, store.roles)
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

match_subjects(matches, roles, subject) {
    core.match_glob(matches, subject)
} {
    r := core.role_ids_glob(roles, subject)
    rr := r[_]
    core.match_glob(matches, rr)
}
