package ory.core

match_glob(patterns, compare) {
    pattern := patterns[_]
    glob.match(pattern, [":"], compare, output)
    output == true
}
