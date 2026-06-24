package com.flexforge.engine.ai;

import java.util.Map;

/**
 * Uniform LLM provider interface. New providers (OpenAI, Anthropic, local, gateway) are
 * added by implementing this — the AI flow step and everything above it stay unchanged.
 * This is the seam the user's AI modules plug into.
 */
public interface AiProvider {

    String name();

    /**
     * Produce a completion for the given prompt.
     *
     * @param prompt  the user prompt (already expression-resolved)
     * @param options step params: model, system, temperature, maxTokens, ...
     */
    String complete(String prompt, Map<String, Object> options);
}
