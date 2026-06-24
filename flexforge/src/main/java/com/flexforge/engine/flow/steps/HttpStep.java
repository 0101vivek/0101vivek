package com.flexforge.engine.flow.steps;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * "http" step: calls an external API. params: {method, url, headers, body}. Returns
 * {status, body}. This is the generic outbound-integration primitive (and the basis for
 * the Tier-1 "any language" serverless-function connector).
 */
@Component
public class HttpStep implements FlowStep {

    private final HttpClient http = HttpClient.newHttpClient();
    private final ObjectMapper objectMapper;

    public HttpStep(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public String type() {
        return "http";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String method = String.valueOf(p.getOrDefault("method", "GET")).toUpperCase();
        String url = String.valueOf(p.get("url"));
        Object body = p.get("body");

        try {
            String payload = body == null ? null
                    : (body instanceof String s ? s : objectMapper.writeValueAsString(body));
            HttpRequest.Builder req = HttpRequest.newBuilder(URI.create(url));
            if (p.get("headers") instanceof Map<?, ?> headers) {
                headers.forEach((k, v) -> req.header(String.valueOf(k), String.valueOf(v)));
            }
            HttpRequest.BodyPublisher pub = payload == null
                    ? HttpRequest.BodyPublishers.noBody()
                    : HttpRequest.BodyPublishers.ofString(payload);
            req.method(method, pub);
            HttpResponse<String> resp = http.send(req.build(), HttpResponse.BodyHandlers.ofString());

            Map<String, Object> out = new LinkedHashMap<>();
            out.put("status", resp.statusCode());
            out.put("body", parseMaybeJson(resp.body()));
            return out;
        } catch (Exception e) {
            return Map.of("error", e.getMessage());
        }
    }

    private Object parseMaybeJson(String body) {
        if (body == null || body.isBlank()) {
            return body;
        }
        try {
            return objectMapper.readValue(body, Object.class);
        } catch (Exception e) {
            return body;
        }
    }
}
