package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;
import static java.time.Duration.ofSeconds;

/**
 * Verifies that a flow with a schedule trigger runs automatically (the cron/fixed-rate
 * trigger for no-code automation).
 */
@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "flexforge.config.path=classpath:scheduled-app.yaml")
class SchedulerIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    @SuppressWarnings("unchecked")
    void scheduledFlowRunsAutomatically() {
        await().atMost(ofSeconds(8)).untilAsserted(() -> {
            ResponseEntity<List> notes = rest.getForEntity("/__notifications", List.class);
            List<Map<String, Object>> body = notes.getBody();
            assertThat(body).isNotNull();
            assertThat(body.stream().anyMatch(n -> "heartbeat".equals(n.get("subject")))).isTrue();
        });
    }
}
