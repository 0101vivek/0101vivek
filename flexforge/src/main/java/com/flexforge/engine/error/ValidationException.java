package com.flexforge.engine.error;

import java.util.List;

/** One or more field validation rules failed; mapped to HTTP 400 with the error list. */
public class ValidationException extends RuntimeException {

    private final List<String> errors;

    public ValidationException(List<String> errors) {
        super("Validation failed: " + String.join("; ", errors));
        this.errors = errors;
    }

    public List<String> getErrors() {
        return errors;
    }
}
