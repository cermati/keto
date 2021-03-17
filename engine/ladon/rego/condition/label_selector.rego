package ory.condition

# ------------------------------------------------------------------------------
# eval_condition "interface"
# ------------------------------------------------------------------------------
eval_condition("LabelSelectorCondition", request, options, key) {
    labelSelector_selectorMatch(options, request.context[key])
}

# ------------------------------------------------------------------------------
# LabelSelector logic
# ------------------------------------------------------------------------------

# labelSelector_selectorMatch returns true if the labels set matches the
# selector. Otherwise, returns undefined.
labelSelector_selectorMatch(selector, labels) {
    labelSelector_labelMatch(selector, labels)
    labelSelector_expressionMatch(selector, labels)
}

# labelSelector_labelMatch returns true if the labels set matches the
# "matchLabels" map. Otherwise, returns undefined.
#
# For the exact specification of what a match is, see:
#   https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#LabelSelector
labelSelector_labelMatch(selector, labels) {
    matchLabelPairs := { [label, value] |
        some label
        value := selector.matchLabels[label]
    }

    labelPairs := { [label, value] |
        some label
        value := labels[label]
    }

    count(matchLabelPairs - labelPairs) == 0
}

# labelSelector_expressionMatch returns true if the labels set matches the
# "matchExpressions" array. Otherwise, returns undefined.
#
# Please refer to each function for more details.
labelSelector_expressionMatch(selector, labels) {
    labelSelector_expressionMatchIn_AllMatch(selector, labels)
    labelSelector_expressionMatchNotIn_AllMatch(selector, labels)
    labelSelector_expressionMatchExists_AllMatch(selector, labels)
    labelSelector_expressionMatchDoesNotExist_AllMatch(selector, labels)
}

# labelSelector_expressionMatchIn_AllMatch returns true if _all_ `operator=In`
# expressions matches with the labels set. Otherwise, returns undefined.
#
# An "In" expression matches the labels set if the expression's key exists in it
# and the value of said key is in the expression's values array.
labelSelector_expressionMatchIn_AllMatch(selector, labels) {
    # List of all "In" expressions
    allInExpressions := [ expr |
        # Expression is an "In" expression
        some i
        expr := selector.matchExpressions[i]
        expr.operator == "In"
    ]

    # List of all "In" expressions that matches
    matchingInExpressions := [ expr |
        # Expression is an "In" expression
        some i
        expr := selector.matchExpressions[i]
        expr.operator == "In"

        # expr.key must exist in labels
        _has_key(labels, expr.key)

        # The expr.values array must not be empty
        count(expr.values) > 0

        # The value of labels[expr.key] must be in the expr.values array
        _contains(expr.values, labels[expr.key])
    ]

    count(allInExpressions) == count(matchingInExpressions)
}

# labelSelector_expressionMatchNotIn_AllMatch returns true if _all_
# `operator=NotIn` expressions matches with the labels set. Otherwise,
# returns undefined.
#
# A "NotIn" expression matches the labels set if the expression's key exists in
# it and the value of said key IS NOT in the expression's values array.
labelSelector_expressionMatchNotIn_AllMatch(selector, labels) {
    # List of all "NotIn" expressions
    allNotInExpressions := [ expr |
        # Expression is an "NotIn" expression
        some i
        expr := selector.matchExpressions[i]
        expr.operator == "NotIn"
    ]

    # List of all "NotIn" expressions that matches
    matchingNotInExpressions := [ expr |
        # Expression is an "NotIn" expression
        some i
        expr := selector.matchExpressions[i]
        expr.operator == "NotIn"

        # Get the metadata.label value, or null if it does not exist. NotIn
        # selector matches if the labels does not contain the key.
        labelValue := object.get(labels, expr.key, null)

        # The expr.values array must not be empty
        count(expr.values) > 0

        # The value of labelValue must not be in the expr.values array
        not _contains(expr.values, labelValue)
    ]

    count(allNotInExpressions) == count(matchingNotInExpressions)
}

# labelSelector_expressionMatchExists_AllMatch returns true if _all_
# `operator=Exists` expressions matches with the labels set. Otherwise,
# returns undefined.
#
# A "Exists" expression matches the labels set if the expression's key exists in
# it. The value does not matter.
labelSelector_expressionMatchExists_AllMatch(selector, labels) {
    # List of all "Exists" expressions
    allExistsExpressions := [ expr |
        # Expression is an "Exists" expression
        some i
        expr := selector.matchExpressions[i]
        expr.operator == "Exists"
    ]

    # List of all "Exists" expressions that matches
    matchingExistsExpressions := [ expr |
        # Expression is an "Exists" expression
        some i
        expr := selector.matchExpressions[i]
        expr.operator == "Exists"

        # The labels must have an entry with expr.key as its key
        _has_key(labels, expr.key)
    ]

    count(allExistsExpressions) == count(matchingExistsExpressions)
}

# labelSelector_expressionMatchDoesNotExist_AllMatch returns true if _all_
# `operator=DoesNotExists` expressions matches with the labels set. Otherwise,
# returns undefined.
#
# A "DoesNotExists" expression matches the labels set if the expression's key
# DOES NOT exist in it.
labelSelector_expressionMatchDoesNotExist_AllMatch(selector, labels) {
    # List of all "DoesNotExist" expressions
    allDoesNotExistExpressions := [ expr |
        # Expression is an "DoesNotExist" expression
        some i
        expr := selector.matchExpressions[i]
        expr.operator == "DoesNotExist"
    ]

    # List of all "DoesNotExist" expressions that matches
    matchingDoesNotExistExpressions := [ expr |
        # Expression is an "DoesNotExist" expression
        some i
        expr := selector.matchExpressions[i]
        expr.operator == "DoesNotExist"

        # The labels must NOT have an entry with expr.key as its key
        not _has_key(labels, expr.key)
    ]

    count(allDoesNotExistExpressions) == count(matchingDoesNotExistExpressions)
}

# ------------------------------------------------------------------------------
# Tests (via `opa test -v .` on the engine/ladon/rego directory)
# ------------------------------------------------------------------------------

test_labelSelector_labelMatch {
    labelsComplete := {
        "organization": "foo_ltd",
        "team": "engineering"
    }

    labelsIncomplete := {
        "organization": "foo_ltd"
    }

    selectorOrgzTeam := {
        "matchLabels": {
            "organization": "foo_ltd",
            "team": "engineering"
        }
    }

    selectorOrgzOnly := {
        "matchLabels": {
            "organization": "foo_ltd"
        }
    }

    selectorExcess := {
        "matchLabels": {
            "organization": "foo_ltd",
            "none-match": "none-match"
        }
    }

    labelSelector_labelMatch(selectorOrgzTeam, labelsComplete)
    not labelSelector_labelMatch(selectorOrgzTeam, labelsIncomplete)
    not labelSelector_labelMatch(selectorOrgzTeam, {})
    not labelSelector_labelMatch(selectorOrgzTeam, null)

    labelSelector_labelMatch(selectorOrgzOnly, labelsComplete)
    labelSelector_labelMatch(selectorOrgzOnly, labelsIncomplete)

    not labelSelector_labelMatch(selectorExcess, labelsComplete)
    not labelSelector_labelMatch(selectorExcess, labelsIncomplete)
}

test_labelSelector_expressionMatchIn_AllMatch {
    labels := {
        "organization": "foo_ltd",
        "team": "engineering"
    }

    selectorMatches := {
        "matchExpressions": [
            { "key": "organization", "operator": "In", "values": ["foo_ltd", "bar_corp"]},
            { "key": "team", "operator": "In", "values": ["engineering"]}
        ]
    }

    selectorNotMatch1 := {
        "matchExpressions": [
            { "key": "organization", "operator": "In", "values": ["bar_corp", "baz_ltd"]},
            { "key": "team", "operator": "In", "values": ["engineering"]}
        ]
    }

    selectorNotMatch2 := {
        "matchExpressions": [
            { "key": "location", "operator": "In", "values": ["earth"]},
        ]
    }

    labelSelector_expressionMatchIn_AllMatch(selectorMatches, labels)
    not labelSelector_expressionMatchIn_AllMatch(selectorNotMatch1, labels)
    not labelSelector_expressionMatchIn_AllMatch(selectorNotMatch2, labels)
}

test_labelSelector_expressionMatchNotIn_AllMatch {
    labels := {
        "organization": "foo_ltd",
        "team": "engineering"
    }

    selectorMatches1 := {
        "matchExpressions": [
            { "key": "organization", "operator": "NotIn", "values": ["bar_corp", "baz_ltd"]},
            { "key": "team", "operator": "NotIn", "values": ["finance"]}
        ]
    }

    selectorMatches2 := {
        "matchExpressions": [
            { "key": "unknownFieldName", "operator": "NotIn", "values": ["foo", "bar"]},
        ]
    }

    selectorNotMatch1 := {
        "matchExpressions": [
            { "key": "organization", "operator": "NotIn", "values": ["bar_corp", "baz_ltd"]},
            { "key": "team", "operator": "NotIn", "values": ["engineering"]}
        ]
    }

    selectorNotMatch2 := {
        "matchExpressions": [
            { "key": "organization", "operator": "NotIn", "values": ["foo_ltd"]},
        ]
    }

    labelSelector_expressionMatchNotIn_AllMatch(selectorMatches1, labels)
    labelSelector_expressionMatchNotIn_AllMatch(selectorMatches2, labels)
    not labelSelector_expressionMatchNotIn_AllMatch(selectorNotMatch1, labels)
    not labelSelector_expressionMatchNotIn_AllMatch(selectorNotMatch2, labels)
}

test_labelSelector_expressionMatchExists_AllMatch {
    labels := {
        "organization": "foo_ltd",
        "team": "engineering"
    }

    selectorMatches := {
        "matchExpressions": [
            { "key": "organization", "operator": "Exists"},
            { "key": "team", "operator": "Exists"}
        ]
    }

    selectorNotMatch1 := {
        "matchExpressions": [
            { "key": "organization", "operator": "Exists"},
            { "key": "team", "operator": "Exists"},
            { "key": "location", "operator": "Exists"}
        ]
    }

    selectorNotMatch2 := {
        "matchExpressions": [
            { "key": "location", "operator": "Exists"},
        ]
    }

    labelSelector_expressionMatchExists_AllMatch(selectorMatches, labels)
    not labelSelector_expressionMatchExists_AllMatch(selectorNotMatch1, labels)
    not labelSelector_expressionMatchExists_AllMatch(selectorNotMatch2, labels)
}

test_labelSelector_expressionMatchDoesNotExist_AllMatch {
    labels := {
        "organization": "foo_ltd",
        "team": "engineering"
    }

    selectorMatches := {
        "matchExpressions": [
            { "key": "region", "operator": "DoesNotExist"},
            { "key": "zone", "operator": "DoesNotExist"}
        ]
    }

    selectorNotMatch1 := {
        "matchExpressions": [
            { "key": "organization", "operator": "DoesNotExist"},
            { "key": "team", "operator": "DoesNotExist"},
            { "key": "region", "operator": "DoesNotExist"}
        ]
    }

    selectorNotMatch2 := {
        "matchExpressions": [
            { "key": "organization", "operator": "DoesNotExist"},
        ]
    }

    labelSelector_expressionMatchDoesNotExist_AllMatch(selectorMatches, labels)
    not labelSelector_expressionMatchDoesNotExist_AllMatch(selectorNotMatch1, labels)
    not labelSelector_expressionMatchDoesNotExist_AllMatch(selectorNotMatch2, labels)
}

test_labelSelector_selectorMatch {
    labels := {
        "key1": "value1",
        "key2": "value2",
        "key3": "value3",
        "key4": "value4",
        "key5": "",
    }

    selectorMatches := {
        "matchLabels": {
            "key1": "value1",
            "key2": "value2",
        },

        "matchExpressions": [
            { "key": "key3", "operator": "In", "values": ["value3a", "value3b", "value3"]},
            { "key": "key4", "operator": "NotIn", "values": ["value4a", "value4b"]},
            { "key": "key5", "operator": "Exists"},
            { "key": "key6", "operator": "DoesNotExist"},
        ]
    }

    selectorNotMatch := {
        "matchLabels": {
            "key1": "value1",
            "key2": "value2",
        },

        "matchExpressions": [
            { "key": "key3", "operator": "In", "values": ["value3a", "value3b", "value3"]},
            { "key": "key4", "operator": "NotIn", "values": ["value4a", "value4b"]},
            { "key": "key5", "operator": "Exists"},
            { "key": "key5", "operator": "DoesNotExist"},
        ]
    }

    labelSelector_selectorMatch(selectorMatches, labels)
    not labelSelector_selectorMatch(selectorNotMatch, labels)
}
