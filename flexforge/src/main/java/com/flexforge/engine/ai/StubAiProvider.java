package com.flexforge.engine.ai;

import java.util.Map;

/**
 * Deterministic offline provider used when no API key is configured. It lets AI-driven
 * flows be authored, run and tested without network or credentials; swapping in a real
 * provider requires only config, not flow changes.
 */
public class StubAiProvider implements AiProvider {

    @Override
    public String name() {
        return "stub";
    }

    @Override
    public String complete(String prompt, Map<String, Object> options) {
        return "[stub-ai] " + (prompt == null ? "" : prompt.trim());
    }
}
