package com.flexforge.engine.error;

/** No valid credentials/token were supplied; mapped to HTTP 401. */
public class UnauthenticatedException extends RuntimeException {
    public UnauthenticatedException(String message) {
        super(message);
    }
}
