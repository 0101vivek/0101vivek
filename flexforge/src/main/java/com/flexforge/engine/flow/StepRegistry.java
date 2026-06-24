package com.flexforge.engine.flow;

import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Discovers every {@link FlowStep} bean and indexes it by type. Spring injects all step
 * implementations, so adding a step type is just adding a bean — no registration code.
 */
@Component
public class StepRegistry {

    private final Map<String, FlowStep> byType = new HashMap<>();

    public StepRegistry(List<FlowStep> steps) {
        for (FlowStep step : steps) {
            byType.put(step.type(), step);
        }
    }

    public FlowStep require(String type) {
        FlowStep step = byType.get(type);
        if (step == null) {
            throw new IllegalArgumentException("Unknown flow step type '" + type
                    + "'. Registered: " + byType.keySet());
        }
        return step;
    }

    public java.util.Set<String> types() {
        return byType.keySet();
    }
}
