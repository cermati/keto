package ory.condition

cast_string_empty(r, key) = value {
  not r[key]
  value := ""
}{
  cast_string(r[key], value)
}

# _contains returns true if elem is in arr
_contains(arr, elem) = true {
  arr[_] = elem
} else = false { true }

# _has_key returns true if key is defined in the map
_has_key(m, k) = true {
  _ = m[k]
} else = false { true }


# ------------------------------------------------------------------------------
# Tests (via `opa test -v .` on the engine/ladon/rego directory)
# ------------------------------------------------------------------------------

test__contains {
  _contains(["aa", "bb", "cc"], "bb")

  not _contains(["aa", "bb", "cc"], "dd")
  not _contains([], "dd")
  not _contains(null, "dd")
}

test__has_key {
  _has_key({"key1": "val1", "key2": "val2"}, "key2")
  _has_key({"key1": "val1", "key2": null}, "key2")

  not _has_key({"key1": "val1", "key2": "val2"}, "key3")
  not _has_key({}, "key3")
  not _has_key(null, "key3")
}
