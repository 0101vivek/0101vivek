package com.flexforge.engine.config.model;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Config-driven authentication & authorization. Turning auth on, defining users/roles,
 * and setting per-entity access rules are all declarative — exactly the "configure, don't
 * code" model the project is built around. When {@code enabled} is false the engine is
 * fully open (the v0 default), so existing apps are unaffected.
 *
 * <p>v0 ships JWT (HS256) with an in-config user store. OAuth2/OIDC and external identity
 * providers plug into the same {@code AuthContext}/{@code AccessGuard} seam (ROADMAP).
 */
public class SecurityConfig {

    /** Master switch. When false, no authentication is required (open app). */
    public boolean enabled = false;

    /** HS256 signing secret; use a ${ENV} placeholder in real deployments. */
    public String jwtSecret;

    /** Access-token lifetime in minutes. */
    public int tokenTtlMinutes = 60;

    /** In-config user store. Passwords may be plaintext (v0) or BCrypt ($2a$...) hashes. */
    public List<UserDef> users = new ArrayList<>();

    /** Per-entity access rules keyed by entity name. Absent entity = "any authenticated". */
    public Map<String, AccessRule> rules = new LinkedHashMap<>();

    public AccessRule ruleFor(String entityName) {
        if (rules == null) {
            return null;
        }
        for (Map.Entry<String, AccessRule> e : rules.entrySet()) {
            if (e.getKey().equalsIgnoreCase(entityName)) {
                return e.getValue();
            }
        }
        return null;
    }

    public UserDef findUser(String username) {
        for (UserDef u : users) {
            if (u.username != null && u.username.equals(username)) {
                return u;
            }
        }
        return null;
    }

    public static class UserDef {
        public String username;
        public String password;
        public List<String> roles = new ArrayList<>();
    }

    /** Roles allowed to read / write an entity. Empty or null list = any authenticated user. */
    public static class AccessRule {
        public List<String> read = new ArrayList<>();
        public List<String> write = new ArrayList<>();
    }
}
