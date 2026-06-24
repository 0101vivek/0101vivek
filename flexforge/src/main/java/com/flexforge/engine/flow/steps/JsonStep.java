package com.flexforge.engine.flow.steps;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * "json" step. params: {op, value, path}. Ops: parse (string->object), stringify
 * (object->string), get (dot-path lookup), merge (combine two objects). Returns {result}.
 */
@Component
public class JsonStep implements FlowStep {

    private final ObjectMapper objectMapper;

    public JsonStep(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public String type() {
        return "json";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String op = String.valueOf(p.getOrDefault("op", "stringify"));
        try {
            Object result = switch (op) {
                case "parse" -> objectMapper.readValue(String.valueOf(p.get("value")), Object.class);
                case "stringify" -> objectMapper.writeValueAsString(p.get("value"));
                case "get" -> Expressions.lookup(String.valueOf(p.get("path")),
                        Map.of("value", p.get("value") == null ? Map.of() : p.get("value")));
                case "merge" -> {
                    Map<String, Object> merged = new LinkedHashMap<>();
                    if (p.get("value") instanceof Map<?, ?> a) {
                        a.forEach((k, v) -> merged.put(String.valueOf(k), v));
                    }
                    if (p.get("with") instanceof Map<?, ?> b) {
                        b.forEach((k, v) -> merged.put(String.valueOf(k), v));
                    }
                    yield merged;
                }
                default -> throw new IllegalArgumentException("Unknown json op '" + op + "'");
            };
            return Map.of("result", result == null ? "" : result);
        } catch (Exception e) {
            return Map.of("error", e.getMessage());
        }
    }
}
