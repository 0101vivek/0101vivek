package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

/**
 * "list" step. params: {op, items, field, value, separator}. Ops: length, first, last,
 * reverse, sort, distinct, sum, avg, min, max, join, pluck (field), count. Returns {result}.
 */
@Component
public class ListStep implements FlowStep {

    @Override
    public String type() {
        return "list";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String op = String.valueOf(p.getOrDefault("op", "length"));
        List<Object> items = p.get("items") instanceof List<?> l ? new ArrayList<>(l) : new ArrayList<>();
        String field = p.get("field") == null ? null : String.valueOf(p.get("field"));

        Object result = switch (op) {
            case "length", "count" -> items.size();
            case "first" -> items.isEmpty() ? null : items.get(0);
            case "last" -> items.isEmpty() ? null : items.get(items.size() - 1);
            case "reverse" -> { Collections.reverse(items); yield items; }
            case "distinct" -> new ArrayList<>(new LinkedHashSet<>(items));
            case "sort" -> { items.sort((a, b) -> String.valueOf(a).compareTo(String.valueOf(b))); yield items; }
            case "join" -> join(items, String.valueOf(p.getOrDefault("separator", ",")));
            case "sum" -> nums(items, field).stream().mapToDouble(Double::doubleValue).sum();
            case "avg" -> nums(items, field).stream().mapToDouble(Double::doubleValue).average().orElse(0);
            case "min" -> nums(items, field).stream().mapToDouble(Double::doubleValue).min().orElse(0);
            case "max" -> nums(items, field).stream().mapToDouble(Double::doubleValue).max().orElse(0);
            case "pluck" -> pluck(items, field);
            default -> throw new IllegalArgumentException("Unknown list op '" + op + "'");
        };
        return Map.of("result", result);
    }

    private String join(List<Object> items, String sep) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) {
                sb.append(sep);
            }
            sb.append(items.get(i));
        }
        return sb.toString();
    }

    @SuppressWarnings("unchecked")
    private List<Double> nums(List<Object> items, String field) {
        List<Double> out = new ArrayList<>();
        for (Object o : items) {
            Object v = (field != null && o instanceof Map<?, ?> m) ? m.get(field) : o;
            try {
                out.add(v instanceof Number n ? n.doubleValue() : Double.parseDouble(String.valueOf(v)));
            } catch (Exception ignored) {
                // skip non-numeric
            }
        }
        return out;
    }

    @SuppressWarnings("unchecked")
    private List<Object> pluck(List<Object> items, String field) {
        List<Object> out = new ArrayList<>();
        for (Object o : items) {
            if (o instanceof Map<?, ?> m) {
                out.add(m.get(field));
            }
        }
        return out;
    }
}
