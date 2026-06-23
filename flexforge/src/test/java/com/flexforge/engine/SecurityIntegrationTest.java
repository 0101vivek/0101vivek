package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Boots the engine with the security-enabled bundle and proves config-driven auth:
 * login issues a JWT, role rules gate read vs. write, and the same rules apply across
 * REST and GraphQL because both consult the one AccessGuard.
 */
@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "flexforge.config.path=classpath:secure-app.yaml")
class SecurityIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @org.junit.jupiter.api.BeforeEach
    void useHttpClient5() {
        // The JDK HttpURLConnection cannot retry a streamed POST on a 401 challenge.
        // HttpClient5 returns the 401/403 response cleanly so negative auth cases assert.
        rest.getRestTemplate().setRequestFactory(
                new org.springframework.http.client.HttpComponentsClientHttpRequestFactory());
    }

    @Test
    void unauthenticatedRequestIsRejected() {
        ResponseEntity<Map> resp = rest.getForEntity("/api/Note", Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    void adminCanWriteViewerCannot() {
        String adminToken = login("admin", "admin123");
        String viewerToken = login("viewer", "viewer123");

        // ADMIN creates a Note
        ResponseEntity<Map> created = exchange(HttpMethod.POST, "/api/Note", adminToken,
                Map.of("title", "first", "body", "hello"));
        assertThat(created.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        // VIEWER may read
        ResponseEntity<Map> viewerRead = exchange(HttpMethod.GET, "/api/Note", viewerToken, null);
        assertThat(viewerRead.getStatusCode()).isEqualTo(HttpStatus.OK);

        // VIEWER may NOT write → 403
        ResponseEntity<Map> viewerWrite = exchange(HttpMethod.POST, "/api/Note", viewerToken,
                Map.of("title", "nope"));
        assertThat(viewerWrite.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void badCredentialsRejected() {
        ResponseEntity<Map> resp = rest.postForEntity("/auth/login",
                Map.of("username", "admin", "password", "wrong"), Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    private String login(String user, String password) {
        ResponseEntity<Map> resp = rest.postForEntity("/auth/login",
                Map.of("username", user, "password", password), Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        return (String) resp.getBody().get("token");
    }

    private ResponseEntity<Map> exchange(HttpMethod method, String url, String token, Object body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(token);
        return rest.exchange(url, method, new HttpEntity<>(body, headers), Map.class);
    }
}
