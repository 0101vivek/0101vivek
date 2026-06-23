package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Covers the enhancement batch: declarative field validation, operator-aware search, and
 * the metadata/OpenAPI introspection endpoints that drive the UI.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class FeaturesIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void validationRejectsBadEmailAndMissingRequired() {
        // invalid email → 400
        ResponseEntity<Map> badEmail = rest.postForEntity("/api/Customer",
                Map.of("email", "not-an-email", "fullName", "Bob"), Map.class);
        assertThat(badEmail.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(badEmail.getBody()).containsKey("errors");

        // missing required email → 400
        ResponseEntity<Map> missing = rest.postForEntity("/api/Customer",
                Map.of("fullName", "Bob"), Map.class);
        assertThat(missing.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    void searchOperatorsFilterResults() {
        rest.postForEntity("/api/Customer",
                Map.of("email", "gold@example.com", "fullName", "Goldie", "tier", "gold"), Map.class);
        rest.postForEntity("/api/Customer",
                Map.of("email", "silver@example.com", "fullName", "Silvio", "tier", "silver"), Map.class);

        ResponseEntity<Map> like = rest.getForEntity("/api/Customer?tier_like=gol", Map.class);
        assertThat(like.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(((Number) like.getBody().get("total")).intValue()).isGreaterThanOrEqualTo(1);

        ResponseEntity<Map> eq = rest.getForEntity("/api/Customer?tier=silver", Map.class);
        assertThat(((Number) eq.getBody().get("total")).intValue()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void metaDescribesAppWithoutSecrets() {
        ResponseEntity<Map> meta = rest.getForEntity("/__meta", Map.class);
        assertThat(meta.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(meta.getBody().get("appId")).isEqualTo("crm-demo");
        assertThat(meta.getBody()).containsKey("entities");
        // never leak secrets
        assertThat(meta.getBody().toString()).doesNotContain("jwtSecret");
        assertThat(meta.getBody().toString()).doesNotContain("password");
    }

    @Test
    void openApiSpecIsGenerated() {
        ResponseEntity<Map> spec = rest.getForEntity("/__meta/openapi.json", Map.class);
        assertThat(spec.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(spec.getBody().get("openapi")).isEqualTo("3.0.3");
        assertThat(spec.getBody()).containsKey("paths");
    }
}
