// Package engine
package engine

// AuthorizationResult is the result of an access control decision. It contains the decision outcome.
// swagger:model authorizationResult
type AuthorizationResult struct {
	// Allowed is true if the request should be allowed and false otherwise.
	//
	// required: true
	Allowed bool `json:"allowed"`
}

// AuthorizedSubjectsResult is a list of subjects allowed to do an action.
// swagger:model authorizedSubjectsResult
type AuthorizedSubjectsResult struct {
	// Subjects is a list of subjects allowed to do an action
	//
	// required: true
	Subjects []string `json:"subjects"`
}
