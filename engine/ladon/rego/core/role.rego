package ory.core

role_ids(roles, subject) = r {
    r := [role | role := roles[i].id
        roles[i].members[_] == subject
    ]
}

role_ids_glob(roles, subject) = r {
    r := [role | role := roles[i].id
        match_glob(roles[i].members, subject)
    ]
}
