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
 * Exercises the no-code flow engine over HTTP triggers: expression interpolation, a DB
 * action step, and conditional branching — all defined purely in config.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class FlowIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void greetFlowInterpolatesInput() {
        ResponseEntity<Map> resp = rest.postForEntity("/flows/greet/run",
                Map.of("name", "Ada"), Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(resp.getBody().get("message")).isEqualTo("Hello Ada");
    }

    @Test
    void signupFlowCreatesRecordViaDbStep() {
        ResponseEntity<Map> resp = rest.postForEntity("/flows/signup/run",
                Map.of("email", "flow@example.com", "fullName", "Flow User"), Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(resp.getBody().get("email")).isEqualTo("flow@example.com");
        Object id = resp.getBody().get("id");
        assertThat(id).isNotNull();

        // the record really exists via the normal REST surface
        ResponseEntity<Map> fetched = rest.getForEntity("/api/Customer/" + id, Map.class);
        assertThat(fetched.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(fetched.getBody().get("email")).isEqualTo("flow@example.com");
    }

    @Test
    void gradeFlowBranchesOnCondition() {
        ResponseEntity<Map> pass = rest.postForEntity("/flows/grade/run",
                Map.of("score", 70), Map.class);
        assertThat(pass.getBody().get("result")).isEqualTo("pass");

        ResponseEntity<Map> fail = rest.postForEntity("/flows/grade/run",
                Map.of("score", 30), Map.class);
        assertThat(fail.getBody().get("result")).isEqualTo("fail");
    }
}
