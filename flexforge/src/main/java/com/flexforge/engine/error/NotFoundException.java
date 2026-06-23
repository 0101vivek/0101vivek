package com.flexforge.engine.error;

/** Thrown when a requested row does not exist; mapped to HTTP 404 by the REST layer. */
public class NotFoundException extends RuntimeException {
    public NotFoundException(String message) {
        super(message);
    }
}
