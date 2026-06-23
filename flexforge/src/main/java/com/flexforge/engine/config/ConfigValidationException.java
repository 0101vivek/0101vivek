package com.flexforge.engine.config;

import java.util.List;

/** Raised when a config bundle fails structural or semantic validation. */
public class ConfigValidationException extends RuntimeException {

    private final List<String> errors;

    public ConfigValidationException(List<String> errors) {
        super("Config bundle is invalid:\n  - " + String.join("\n  - ", errors));
        this.errors = errors;
    }

    public List<String> getErrors() {
        return errors;
    }
}
