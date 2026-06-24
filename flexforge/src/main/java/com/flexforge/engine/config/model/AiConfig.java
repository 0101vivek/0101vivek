package com.flexforge.engine.config.model;

/**
 * AI provider configuration. The engine is AI-ready: an {@code ai} flow step calls the
 * configured provider through a uniform interface. With no API key it runs in a
 * deterministic "stub" mode so flows (and tests) work offline; set a key to use a real
 * OpenAI-compatible endpoint (OpenAI, or Anthropic/others via a gateway). Additional
 * native providers plug in as new AiProvider implementations.
 */
public class AiConfig {

    /** stub | openai (OpenAI-compatible HTTP). Auto-falls back to stub if no apiKey. */
    public String provider = "stub";

    /** API key; use a ${ENV} placeholder. Blank => stub mode. */
    public String apiKey;

    /** Base URL for the OpenAI-compatible API. */
    public String baseUrl = "https://api.openai.com/v1";

    /** Default model id; overridable per step. */
    public String model = "gpt-4o-mini";
}
