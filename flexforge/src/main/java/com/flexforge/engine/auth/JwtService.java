package com.flexforge.engine.auth;

import com.flexforge.engine.config.model.SecurityConfig;
import com.flexforge.engine.error.UnauthenticatedException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/** Issues and verifies HS256 JWTs whose claims carry the authenticated user's roles. */
public class JwtService {

    private final SecretKey key;
    private final int ttlMinutes;

    public JwtService(SecurityConfig security) {
        String secret = security.jwtSecret;
        if (secret == null || secret.getBytes(StandardCharsets.UTF_8).length < 32) {
            // HS256 needs >= 256 bits of key material; pad a short/missing secret so the
            // engine still boots in dev. Real deployments must set a strong ${ENV} secret.
            secret = (secret == null ? "" : secret) + "flexforge-dev-secret-please-override-0123456789";
        }
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.ttlMinutes = security.tokenTtlMinutes <= 0 ? 60 : security.tokenTtlMinutes;
    }

    public String issue(String username, List<String> roles) {
        Instant now = Instant.now();
        return Jwts.builder()
                .subject(username)
                .claim("roles", roles)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(ttlMinutes * 60L)))
                .signWith(key)
                .compact();
    }

    /** Parse and verify a token, returning the principal. Throws if invalid/expired. */
    public AuthContext.Principal verify(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            Set<String> roles = new LinkedHashSet<>();
            Object raw = claims.get("roles");
            if (raw instanceof List<?> list) {
                for (Object r : list) {
                    roles.add(String.valueOf(r));
                }
            }
            return new AuthContext.Principal(claims.getSubject(), roles);
        } catch (JwtException | IllegalArgumentException e) {
            throw new UnauthenticatedException("Invalid or expired token");
        }
    }
}
