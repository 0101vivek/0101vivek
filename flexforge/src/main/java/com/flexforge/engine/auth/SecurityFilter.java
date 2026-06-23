package com.flexforge.engine.auth;

import com.flexforge.engine.config.model.SecurityConfig;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Reads the {@code Authorization: Bearer <jwt>} header and, if present and valid,
 * populates {@link AuthContext} for the duration of the request. It deliberately does not
 * reject requests itself — authorization is enforced by {@link AccessGuard} at the point
 * of use, so REST gets clean 401/403 responses and GraphQL gets per-field errors. The
 * context is always cleared at the end to keep pooled request threads clean.
 */
@Component
@Order(1)
public class SecurityFilter extends OncePerRequestFilter {

    private final SecurityConfig security;
    private final JwtService jwtService;

    public SecurityFilter(SecurityConfig security, JwtService jwtService) {
        this.security = security;
        this.jwtService = jwtService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        try {
            if (security.enabled) {
                String header = request.getHeader("Authorization");
                if (header != null && header.startsWith("Bearer ")) {
                    try {
                        AuthContext.Principal principal = jwtService.verify(header.substring(7).trim());
                        AuthContext.set(principal.username(), principal.roles());
                    } catch (RuntimeException ignored) {
                        // Invalid token → stay unauthenticated; AccessGuard will 401 on use.
                    }
                }
            }
            chain.doFilter(request, response);
        } finally {
            AuthContext.clear();
        }
    }
}
