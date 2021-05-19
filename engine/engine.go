package engine

import (
	"context"
	"net/http"

	"github.com/julienschmidt/httprouter"
	"github.com/open-policy-agent/opa/ast"
	"github.com/open-policy-agent/opa/rego"
	"github.com/pkg/errors"

	"github.com/ory/herodot"
)

// swagger:ignore
type Engine struct {
	compiler *ast.Compiler
	h        herodot.Writer
}

func NewEngine(
	compiler *ast.Compiler,
	h herodot.Writer,
) *Engine {
	return &Engine{
		compiler: compiler,
		h:        h,
	}
}

// swagger:ignore
type evaluator func(ctx context.Context, r *http.Request, ps httprouter.Params) ([]func(*rego.Rego), error)

func (h *Engine) Evaluate(e evaluator) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		ctx := r.Context()

		rs, err := e(ctx, r, ps)
		if err != nil {
			h.h.WriteError(w, r, err)
			return
		}

		allowed, err := h.eval(ctx, rs)
		if err != nil {
			h.h.WriteError(w, r, err)
			return
		}

		code := http.StatusOK
		if !allowed {
			code = http.StatusForbidden
		}

		h.h.WriteCode(w, r, code, &AuthorizationResult{Allowed: allowed})
	}
}

func (h *Engine) EvaluateAllowedSubjects(e evaluator) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		ctx := r.Context()

		rs, err := e(ctx, r, ps)
		if err != nil {
			h.h.WriteError(w, r, err)
			return
		}

		allowedSubjects, err := h.evalAllowedSubjects(ctx, rs)
		if err != nil {
			h.h.WriteError(w, r, err)
			return
		}

		h.h.WriteCode(w, r, http.StatusOK, &AuthorizedSubjectsResult{Subjects: allowedSubjects})
	}
}

func (h *Engine) eval(ctx context.Context, options []func(*rego.Rego)) (bool, error) {
	// tracer := topdown.NewBufferTracer()
	r := rego.New(
		append(
			options,
			rego.Compiler(h.compiler),
			// rego.Tracer(tracer),
		)...,
	)

	rs, err := r.Eval(ctx)
	if err != nil {
		return false, errors.WithStack(err)
	}

	if len(rs) != 1 || len(rs[0].Expressions) != 1 {
		return false, errors.Errorf("expected one evaluation result but got %d results instead", len(rs))
	}

	result, ok := rs[0].Expressions[0].Value.(bool)
	if !ok {
		return false, errors.Errorf("expected evaluation result to be of type bool but got %T instead", rs[0].Expressions[0].Value)
	}

	return result, nil
}

// Analogous to h.eval(), but this one is used by the handler for the
// /allowed-subjects API, which returns a list of allowed subjects instead of
// whether a single subject is allowed to do an action or not.
func (h *Engine) evalAllowedSubjects(
	ctx context.Context,
	options []func(*rego.Rego),
) ([]string, error) {
	// tracer := topdown.NewBufferTracer()
	r := rego.New(
		append(
			options,
			rego.Compiler(h.compiler),
			// rego.Tracer(tracer),
		)...,
	)

	rs, err := r.Eval(ctx)
	if err != nil {
		return nil, errors.WithStack(err)
	}

	if len(rs) != 1 || len(rs[0].Expressions) != 1 {
		return nil, errors.Errorf("expected one evaluation result but got %d results instead", len(rs))
	}

	resultIface, ok := rs[0].Expressions[0].Value.([]interface{})
	if !ok {
		return nil, errors.Errorf("expected evaluation result to be of type []interface{} but got %T instead", rs[0].Expressions[0].Value)
	}

	result := []string{}
	for _, val := range resultIface {
		valStr, ok := val.(string)
		if !ok {
			return nil, errors.Errorf("expected evaluation result element to be of type string but got %T instead", val)
		}

		result = append(result, valStr)
	}

	return result, nil
}
