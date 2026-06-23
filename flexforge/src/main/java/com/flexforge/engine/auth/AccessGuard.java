package com.flexforge.engine.auth;

import com.flexforge.engine.config.model.SecurityConfig;
import com.flexforge.engine.error.ForbiddenException;
import com.flexforge.engine.error.UnauthenticatedException;

import java.util.List;

/**
 * Central authorization check used by every protocol surface. When security is disabled
 * it is a no-op (open app). Otherwise it requires an authenticated principal and enforces
 * the per-entity read/write role rules from config.
 */
public class AccessGuard {

    private final SecurityConfig security;

    public AccessGuard(SecurityConfig security) {
        this.security = security;
    }

    public boolean securityEnabled() {
        return security != null && security.enabled;
    }

    public void requireRead(String entity) {
        if (!securityEnabled()) {
            return;
        }
        requireAuthenticated();
        SecurityConfig.AccessRule rule = security.ruleFor(entity);
        enforce(entity, "read", rule == null ? null : rule.read);
    }

    public void requireWrite(String entity) {
        if (!securityEnabled()) {
            return;
        }
        requireAuthenticated();
        SecurityConfig.AccessRule rule = security.ruleFor(entity);
        enforce(entity, "write", rule == null ? null : rule.write);
    }

    public void requireAuthenticated() {
        if (!securityEnabled()) {
            return;
        }
        if (!AuthContext.isAuthenticated()) {
            throw new UnauthenticatedException("Authentication required");
        }
    }

    private void enforce(String entity, String op, List<String> allowedRoles) {
        // No rule (or empty list) means "any authenticated user" — already satisfied.
        if (allowedRoles == null || allowedRoles.isEmpty()) {
            return;
        }
        AuthContext.Principal principal = AuthContext.get();
        for (String role : allowedRoles) {
            if (principal.roles().contains(role)) {
                return;
            }
        }
        throw new ForbiddenException(
                "Role(s) " + principal.roles() + " may not " + op + " " + entity);
    }
}
