package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Covers config-declared custom flow endpoints: required-param/header checks (with clear
 * "what's missing" feedback), method enforcement, and the json action.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class EndpointsIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void missingRequiredParamIsReported() {
        ResponseEntity<Map> resp = rest.getForEntity("/run/ping", Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(resp.getBody().get("errors").toString()).contains("who");
    }

    @Test
    void validRequestRunsJsonAction() {
        ResponseEntity<Map> resp = rest.getForEntity("/run/ping?who=ada", Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(resp.getBody().get("message")).isEqualTo("pong");
    }

    @Test
    void missingRequiredHeaderIsReported() {
        ResponseEntity<Map> resp = rest.postForEntity("/run/notify", null, Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(resp.getBody().get("errors").toString()).contains("X-API-Key");
    }

    @Test
    void wrongMethodIsRejected() {
        ResponseEntity<Map> resp = rest.getForEntity("/run/notify", Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.METHOD_NOT_ALLOWED);
    }

    @Test
    void headerSatisfiesCheck() {
        HttpHeaders h = new HttpHeaders();
        h.set("X-API-Key", "anything");
        ResponseEntity<Map> resp = rest.exchange("/run/notify", HttpMethod.POST,
                new HttpEntity<>(null, h), Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(resp.getBody().get("accepted")).isEqualTo(true);
    }
}
