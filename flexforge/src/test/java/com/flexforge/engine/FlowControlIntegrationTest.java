package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Covers control-flow steps (loop + sub-flow, switch) and SELECT field validation.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class FlowControlIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    @SuppressWarnings("unchecked")
    void loopRunsSubFlowPerItem() {
        ResponseEntity<Map> resp = rest.postForEntity("/flows/batch/run",
                Map.of("numbers", List.of(1, 2, 3)), Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(((Number) resp.getBody().get("count")).intValue()).isEqualTo(3);
        List<Map<String, Object>> results = (List<Map<String, Object>>) resp.getBody().get("results");
        assertThat(((Number) results.get(0).get("value")).doubleValue()).isEqualTo(2.0);
        assertThat(((Number) results.get(2).get("value")).doubleValue()).isEqualTo(6.0);
    }

    @Test
    void switchBranchesByValue() {
        assertThat(rest.postForEntity("/flows/route/run", Map.of("kind", "a"), Map.class).getBody().get("path")).isEqualTo("A");
        assertThat(rest.postForEntity("/flows/route/run", Map.of("kind", "b"), Map.class).getBody().get("path")).isEqualTo("B");
        assertThat(rest.postForEntity("/flows/route/run", Map.of("kind", "z"), Map.class).getBody().get("path")).isEqualTo("default");
    }

    @Test
    void selectFieldRejectsInvalidOption() {
        ResponseEntity<Map> bad = rest.postForEntity("/api/Customer",
                Map.of("email", "sel@example.com", "fullName", "Sel", "tier", "diamond"), Map.class);
        assertThat(bad.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);

        ResponseEntity<Map> ok = rest.postForEntity("/api/Customer",
                Map.of("email", "sel2@example.com", "fullName", "Sel2", "tier", "gold",
                        "channels", List.of("email", "sms")), Map.class);
        assertThat(ok.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }
}
