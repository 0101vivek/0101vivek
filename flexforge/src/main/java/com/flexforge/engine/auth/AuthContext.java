package com.flexforge.engine.auth;

import java.util.Set;

/**
 * Per-request principal, set by {@link SecurityFilter} on the request thread and read by
 * the REST controller and the GraphQL data fetchers (which run synchronously on that same
 * thread). This is the single seam every protocol surface consults for authorization, so
 * adding a new protocol does not mean re-implementing auth.
 */
public final class AuthContext {

    private static final ThreadLocal<Principal> HOLDER = new ThreadLocal<>();

    private AuthContext() {
    }

    public static void set(String username, Set<String> roles) {
        HOLDER.set(new Principal(username, roles));
    }

    public static Principal get() {
        return HOLDER.get();
    }

    public static boolean isAuthenticated() {
        return HOLDER.get() != null;
    }

    public static void clear() {
        HOLDER.remove();
    }

    public record Principal(String username, Set<String> roles) {
    }
}
