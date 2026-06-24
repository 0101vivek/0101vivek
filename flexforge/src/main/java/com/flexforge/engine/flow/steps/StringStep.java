package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Map;

/**
 * "string" step. params: {op, value, arg, arg2}. Ops: upper, lower, trim, length, concat,
 * replace, substring, split, contains, startsWith, endsWith, padLeft, padRight, reverse,
 * capitalize. Returns {result}.
 */
@Component
public class StringStep implements FlowStep {

    @Override
    public String type() {
        return "string";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String op = String.valueOf(p.getOrDefault("op", "upper"));
        String v = str(p.get("value"));
        String arg = str(p.get("arg"));
        String arg2 = str(p.get("arg2"));
        Object result = switch (op) {
            case "upper" -> v.toUpperCase();
            case "lower" -> v.toLowerCase();
            case "trim" -> v.trim();
            case "length" -> v.length();
            case "concat" -> v + arg;
            case "replace" -> v.replace(arg, arg2);
            case "substring" -> v.substring(Math.min(intOf(arg), v.length()),
                    arg2.isEmpty() ? v.length() : Math.min(intOf(arg2), v.length()));
            case "split" -> Arrays.asList(v.split(arg.isEmpty() ? "," : arg));
            case "contains" -> v.contains(arg);
            case "startsWith" -> v.startsWith(arg);
            case "endsWith" -> v.endsWith(arg);
            case "padLeft" -> pad(v, intOf(arg), arg2.isEmpty() ? " " : arg2, true);
            case "padRight" -> pad(v, intOf(arg), arg2.isEmpty() ? " " : arg2, false);
            case "reverse" -> new StringBuilder(v).reverse().toString();
            case "capitalize" -> v.isEmpty() ? v : Character.toUpperCase(v.charAt(0)) + v.substring(1);
            default -> throw new IllegalArgumentException("Unknown string op '" + op + "'");
        };
        return Map.of("result", result);
    }

    private String pad(String v, int len, String ch, boolean left) {
        StringBuilder sb = new StringBuilder(v);
        while (sb.length() < len) {
            if (left) {
                sb.insert(0, ch);
            } else {
                sb.append(ch);
            }
        }
        return sb.toString();
    }

    private int intOf(String s) {
        try {
            return s.isEmpty() ? 0 : Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String str(Object o) {
        return o == null ? "" : String.valueOf(o);
    }
}
