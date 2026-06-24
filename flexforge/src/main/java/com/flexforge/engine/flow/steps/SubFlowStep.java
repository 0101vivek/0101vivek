package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowEngine;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * "flow" step: runs another named flow as a sub-routine (composition/reuse). params:
 * {flow, input}. Returns {response, steps} of the sub-flow. FlowEngine is injected lazily
 * to break the engine&lt;-&gt;step cycle.
 */
@Component
public class SubFlowStep implements FlowStep {

    private final FlowEngine engine;

    public SubFlowStep(@Lazy FlowEngine engine) {
        this.engine = engine;
    }

    @Override
    public String type() {
        return "flow";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String flow = String.valueOf(p.get("flow"));
        Map<String, Object> input = p.get("input") instanceof Map<?, ?> m
                ? new LinkedHashMap<>((Map<String, Object>) m) : new LinkedHashMap<>();
        FlowContext sub = engine.run(flow, input);
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("response", sub.response());
        out.put("steps", sub.steps());
        return out;
    }
}
