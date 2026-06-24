package com.flexforge.engine.flow.steps;

import com.flexforge.engine.ai.AiProvider;
import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * "ai" step: runs an LLM completion via the configured provider. params: {prompt, model,
 * system, temperature, maxTokens}. Returns {text, provider}. Because it's just a FlowStep,
 * AI sits in the same flow graph as db/http/condition steps — the user's AI modules extend
 * this same pattern (RAG, classify, extract, agent) as additional step types.
 */
@Component
public class AiStep implements FlowStep {

    private final AiProvider provider;

    public AiStep(AiProvider provider) {
        this.provider = provider;
    }

    @Override
    public String type() {
        return "ai";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String prompt = String.valueOf(p.getOrDefault("prompt", ""));
        String text = provider.complete(prompt, p);
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("text", text);
        out.put("provider", provider.name());
        return out;
    }
}
