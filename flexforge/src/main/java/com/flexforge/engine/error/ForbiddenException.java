package com.flexforge.engine.error;

/** Authenticated, but the principal's roles don't allow the operation; mapped to HTTP 403. */
public class ForbiddenException extends RuntimeException {
    public ForbiddenException(String message) {
        super(message);
    }
}
