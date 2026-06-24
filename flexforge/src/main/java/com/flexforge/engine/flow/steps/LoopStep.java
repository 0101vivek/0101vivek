package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowEngine;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * "loop" step: runs a sub-flow once per item in a list and collects the results. params:
 * {items, flow}. Each iteration runs the flow with input {item, index}. Returns
 * {count, results}.
 */
@Component
public class LoopStep implements FlowStep {

    private final FlowEngine engine;

    public LoopStep(@Lazy FlowEngine engine) {
        this.engine = engine;
    }

    @Override
    public String type() {
        return "loop";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String flow = String.valueOf(p.get("flow"));
        List<Object> items = p.get("items") instanceof List<?> l ? new ArrayList<>(l) : new ArrayList<>();
        List<Object> results = new ArrayList<>();
        for (int i = 0; i < items.size(); i++) {
            Map<String, Object> input = new LinkedHashMap<>();
            input.put("item", items.get(i));
            input.put("index", i);
            FlowContext sub = engine.run(flow, input);
            results.add(sub.response() != null ? sub.response() : sub.steps());
        }
        return Map.of("count", results.size(), "results", results);
    }
}
