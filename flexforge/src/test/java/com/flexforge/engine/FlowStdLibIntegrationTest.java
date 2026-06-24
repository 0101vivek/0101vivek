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
 * Exercises the flow standard-library steps (math, string, crypto) chained in one flow.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class FlowStdLibIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void toolboxFlowRunsMathStringCrypto() {
        ResponseEntity<Map> resp = rest.postForEntity("/flows/toolbox/run",
                Map.of("x", 2, "y", 3, "name", "ada"), Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(((Number) resp.getBody().get("sum")).doubleValue()).isEqualTo(5.0);
        assertThat(resp.getBody().get("name")).isEqualTo("ADA");
        assertThat(String.valueOf(resp.getBody().get("id"))).hasSize(36); // a UUID
    }
}
