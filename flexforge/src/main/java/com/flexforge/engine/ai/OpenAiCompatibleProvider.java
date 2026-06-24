package com.flexforge.engine.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flexforge.engine.config.model.AiConfig;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Calls an OpenAI-compatible {@code /chat/completions} endpoint. Works with OpenAI and with
 * Anthropic/others fronted by a gateway (LiteLLM, etc.). A native Anthropic provider can be
 * added later as another {@link AiProvider} without touching callers.
 */
public class OpenAiCompatibleProvider implements AiProvider {

    private final HttpClient http = HttpClient.newHttpClient();
    private final ObjectMapper objectMapper;
    private final AiConfig config;

    public OpenAiCompatibleProvider(AiConfig config, ObjectMapper objectMapper) {
        this.config = config;
        this.objectMapper = objectMapper;
    }

    @Override
    public String name() {
        return "openai";
    }

    @Override
    public String complete(String prompt, Map<String, Object> options) {
        try {
            List<Map<String, Object>> messages = new ArrayList<>();
            Object system = options.get("system");
            if (system != null) {
                messages.add(Map.of("role", "system", "content", String.valueOf(system)));
            }
            messages.add(Map.of("role", "user", "content", prompt));

            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("model", options.getOrDefault("model", config.model));
            payload.put("messages", messages);
            if (options.get("temperature") != null) {
                payload.put("temperature", options.get("temperature"));
            }
            if (options.get("maxTokens") != null) {
                payload.put("max_tokens", options.get("maxTokens"));
            }

            HttpRequest request = HttpRequest.newBuilder(URI.create(config.baseUrl + "/chat/completions"))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + config.apiKey)
                    .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(payload)))
                    .build();
            HttpResponse<String> resp = http.send(request, HttpResponse.BodyHandlers.ofString());
            JsonNode root = objectMapper.readTree(resp.body());
            JsonNode content = root.path("choices").path(0).path("message").path("content");
            if (content.isMissingNode()) {
                throw new IllegalStateException("AI provider error: " + resp.body());
            }
            return content.asText();
        } catch (Exception e) {
            throw new IllegalStateException("AI completion failed: " + e.getMessage(), e);
        }
    }
}
