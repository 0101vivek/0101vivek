package com.flexforge.engine.auth;

import com.flexforge.engine.config.model.SecurityConfig;
import com.flexforge.engine.error.NotFoundException;
import com.flexforge.engine.error.UnauthenticatedException;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Issues JWTs against the in-config user store. {@code POST /auth/login} with
 * {@code {username, password}} returns {@code {token, roles}}. Stored passwords may be
 * plaintext (v0 convenience) or BCrypt hashes ({@code $2a$...}).
 */
@RestController
public class AuthController {

    private final SecurityConfig security;
    private final JwtService jwtService;
    private final BCryptPasswordEncoder bcrypt = new BCryptPasswordEncoder();

    public AuthController(SecurityConfig security, JwtService jwtService) {
        this.security = security;
        this.jwtService = jwtService;
    }

    @PostMapping(value = "/auth/login", consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> login(@RequestBody Map<String, String> body) {
        if (!security.enabled) {
            throw new NotFoundException("Authentication is not enabled for this app");
        }
        String username = body.get("username");
        String password = body.get("password");
        SecurityConfig.UserDef user = username == null ? null : security.findUser(username);
        if (user == null || !passwordMatches(password, user.password)) {
            throw new UnauthenticatedException("Invalid username or password");
        }
        String token = jwtService.issue(user.username, user.roles);
        return Map.of("token", token, "roles", user.roles);
    }

    private boolean passwordMatches(String supplied, String stored) {
        if (supplied == null || stored == null) {
            return false;
        }
        if (stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$")) {
            return bcrypt.matches(supplied, stored);
        }
        return stored.equals(supplied);
    }
}
