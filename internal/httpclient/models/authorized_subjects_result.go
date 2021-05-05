// Code generated by go-swagger; DO NOT EDIT.

package models

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"context"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/strfmt"
	"github.com/go-openapi/swag"
	"github.com/go-openapi/validate"
)

// AuthorizedSubjectsResult AuthorizedSubjectsResult is a list of subjects allowed to do an action.
//
// swagger:model authorizedSubjectsResult
type AuthorizedSubjectsResult struct {

	// Subjects is a list of subjects allowed to do an action
	// Required: true
	Subjects []string `json:"subjects"`
}

// Validate validates this authorized subjects result
func (m *AuthorizedSubjectsResult) Validate(formats strfmt.Registry) error {
	var res []error

	if err := m.validateSubjects(formats); err != nil {
		res = append(res, err)
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}

func (m *AuthorizedSubjectsResult) validateSubjects(formats strfmt.Registry) error {

	if err := validate.Required("subjects", "body", m.Subjects); err != nil {
		return err
	}

	return nil
}

// ContextValidate validates this authorized subjects result based on context it is used
func (m *AuthorizedSubjectsResult) ContextValidate(ctx context.Context, formats strfmt.Registry) error {
	return nil
}

// MarshalBinary interface implementation
func (m *AuthorizedSubjectsResult) MarshalBinary() ([]byte, error) {
	if m == nil {
		return nil, nil
	}
	return swag.WriteJSON(m)
}

// UnmarshalBinary interface implementation
func (m *AuthorizedSubjectsResult) UnmarshalBinary(b []byte) error {
	var res AuthorizedSubjectsResult
	if err := swag.ReadJSON(b, &res); err != nil {
		return err
	}
	*m = res
	return nil
}
