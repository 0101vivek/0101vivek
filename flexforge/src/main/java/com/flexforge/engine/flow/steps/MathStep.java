package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * "math" step. params: {op, a, b} or {op, values:[...]}. Ops: add, subtract, multiply,
 * divide, mod, pow, round, floor, ceil, abs, min, max, avg. Returns {result}.
 */
@Component
public class MathStep implements FlowStep {

    @Override
    public String type() {
        return "math";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String op = String.valueOf(p.getOrDefault("op", "add"));
        double a = num(p.get("a"));
        double b = num(p.get("b"));
        double result = switch (op) {
            case "add" -> a + b;
            case "subtract" -> a - b;
            case "multiply" -> a * b;
            case "divide" -> b == 0 ? 0 : a / b;
            case "mod" -> b == 0 ? 0 : a % b;
            case "pow" -> Math.pow(a, b);
            case "round" -> Math.round(a);
            case "floor" -> Math.floor(a);
            case "ceil" -> Math.ceil(a);
            case "abs" -> Math.abs(a);
            case "min", "max", "avg", "sum" -> aggregate(op, p.get("values"), a, b);
            default -> throw new IllegalArgumentException("Unknown math op '" + op + "'");
        };
        return Map.of("result", result);
    }

    private double aggregate(String op, Object values, double a, double b) {
        List<Double> nums = new java.util.ArrayList<>();
        if (values instanceof List<?> list) {
            for (Object o : list) {
                nums.add(num(o));
            }
        } else {
            nums.add(a);
            nums.add(b);
        }
        return switch (op) {
            case "min" -> nums.stream().mapToDouble(Double::doubleValue).min().orElse(0);
            case "max" -> nums.stream().mapToDouble(Double::doubleValue).max().orElse(0);
            case "sum" -> nums.stream().mapToDouble(Double::doubleValue).sum();
            default -> nums.stream().mapToDouble(Double::doubleValue).average().orElse(0);
        };
    }

    private double num(Object o) {
        if (o instanceof Number n) {
            return n.doubleValue();
        }
        try {
            return o == null ? 0 : Double.parseDouble(o.toString());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
