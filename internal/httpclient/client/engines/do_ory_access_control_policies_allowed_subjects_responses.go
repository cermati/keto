// Code generated by go-swagger; DO NOT EDIT.

package engines

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"context"
	"fmt"
	"io"

	"github.com/go-openapi/runtime"
	"github.com/go-openapi/strfmt"
	"github.com/go-openapi/swag"

	"github.com/ory/keto/internal/httpclient/models"
)

// DoOryAccessControlPoliciesAllowedSubjectsReader is a Reader for the DoOryAccessControlPoliciesAllowedSubjects structure.
type DoOryAccessControlPoliciesAllowedSubjectsReader struct {
	formats strfmt.Registry
}

// ReadResponse reads a server response into the received o.
func (o *DoOryAccessControlPoliciesAllowedSubjectsReader) ReadResponse(response runtime.ClientResponse, consumer runtime.Consumer) (interface{}, error) {
	switch response.Code() {
	case 200:
		result := NewDoOryAccessControlPoliciesAllowedSubjectsOK()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return result, nil
	case 500:
		result := NewDoOryAccessControlPoliciesAllowedSubjectsInternalServerError()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return nil, result
	default:
		return nil, runtime.NewAPIError("response status code does not match any response statuses defined for this endpoint in the swagger spec", response, response.Code())
	}
}

// NewDoOryAccessControlPoliciesAllowedSubjectsOK creates a DoOryAccessControlPoliciesAllowedSubjectsOK with default headers values
func NewDoOryAccessControlPoliciesAllowedSubjectsOK() *DoOryAccessControlPoliciesAllowedSubjectsOK {
	return &DoOryAccessControlPoliciesAllowedSubjectsOK{}
}

/* DoOryAccessControlPoliciesAllowedSubjectsOK describes a response with status code 200, with default header values.

authorizedSubjectsResult
*/
type DoOryAccessControlPoliciesAllowedSubjectsOK struct {
	Payload *models.AuthorizedSubjectsResult
}

func (o *DoOryAccessControlPoliciesAllowedSubjectsOK) Error() string {
	return fmt.Sprintf("[POST /engines/acp/ory/{flavor}/allowed-subjects][%d] doOryAccessControlPoliciesAllowedSubjectsOK  %+v", 200, o.Payload)
}
func (o *DoOryAccessControlPoliciesAllowedSubjectsOK) GetPayload() *models.AuthorizedSubjectsResult {
	return o.Payload
}

func (o *DoOryAccessControlPoliciesAllowedSubjectsOK) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.AuthorizedSubjectsResult)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

// NewDoOryAccessControlPoliciesAllowedSubjectsInternalServerError creates a DoOryAccessControlPoliciesAllowedSubjectsInternalServerError with default headers values
func NewDoOryAccessControlPoliciesAllowedSubjectsInternalServerError() *DoOryAccessControlPoliciesAllowedSubjectsInternalServerError {
	return &DoOryAccessControlPoliciesAllowedSubjectsInternalServerError{}
}

/* DoOryAccessControlPoliciesAllowedSubjectsInternalServerError describes a response with status code 500, with default header values.

The standard error format
*/
type DoOryAccessControlPoliciesAllowedSubjectsInternalServerError struct {
	Payload *DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody
}

func (o *DoOryAccessControlPoliciesAllowedSubjectsInternalServerError) Error() string {
	return fmt.Sprintf("[POST /engines/acp/ory/{flavor}/allowed-subjects][%d] doOryAccessControlPoliciesAllowedSubjectsInternalServerError  %+v", 500, o.Payload)
}
func (o *DoOryAccessControlPoliciesAllowedSubjectsInternalServerError) GetPayload() *DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody {
	return o.Payload
}

func (o *DoOryAccessControlPoliciesAllowedSubjectsInternalServerError) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

/*DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody do ory access control policies allowed subjects internal server error body
swagger:model DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody
*/
type DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody struct {

	// code
	Code int64 `json:"code,omitempty"`

	// details
	Details []interface{} `json:"details"`

	// message
	Message string `json:"message,omitempty"`

	// reason
	Reason string `json:"reason,omitempty"`

	// request
	Request string `json:"request,omitempty"`

	// status
	Status string `json:"status,omitempty"`
}

// Validate validates this do ory access control policies allowed subjects internal server error body
func (o *DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody) Validate(formats strfmt.Registry) error {
	return nil
}

// ContextValidate validates this do ory access control policies allowed subjects internal server error body based on context it is used
func (o *DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody) ContextValidate(ctx context.Context, formats strfmt.Registry) error {
	return nil
}

// MarshalBinary interface implementation
func (o *DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody) MarshalBinary() ([]byte, error) {
	if o == nil {
		return nil, nil
	}
	return swag.WriteJSON(o)
}

// UnmarshalBinary interface implementation
func (o *DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody) UnmarshalBinary(b []byte) error {
	var res DoOryAccessControlPoliciesAllowedSubjectsInternalServerErrorBody
	if err := swag.ReadJSON(b, &res); err != nil {
		return err
	}
	*o = res
	return nil
}
