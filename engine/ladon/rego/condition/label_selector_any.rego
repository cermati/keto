package ory.condition

# ------------------------------------------------------------------------------
# eval_condition "interface"
# ------------------------------------------------------------------------------
eval_condition("AnyLabelSelectorCondition", request, options, key) {
    anyLabelSelector_anySelectorMatch(options.labelSelectors, request.context[key])
}

# ------------------------------------------------------------------------------
# AnyLabelSelectorCondition logic
# ------------------------------------------------------------------------------

# anyLabelSelector_anySelectorMatch returns true if one of the passed label
# selector matches with the labels set. Otherwise, returns undefined.
anyLabelSelector_anySelectorMatch(selectors, labels) {
    matchingSelectors := { selector |
        selector := selectors[_];
        labelSelector_selectorMatch(selector, labels)
    }

    count(matchingSelectors) > 0
}

# ------------------------------------------------------------------------------
# Tests (via `opa test -v .` on the engine/ladon/rego directory)
# ------------------------------------------------------------------------------

test_anyLabelSelector_anySelectorMatch {
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

    anyLabelSelector_anySelectorMatch([selectorMatches, selectorNotMatch], labels)
    anyLabelSelector_anySelectorMatch([selectorMatches, selectorMatches], labels)
    anyLabelSelector_anySelectorMatch([selectorMatches], labels)

    not anyLabelSelector_anySelectorMatch([selectorNotMatch], labels)
    not anyLabelSelector_anySelectorMatch([selectorNotMatch, selectorNotMatch], labels)
    not anyLabelSelector_anySelectorMatch([], labels)
    not anyLabelSelector_anySelectorMatch(null, labels)
}
