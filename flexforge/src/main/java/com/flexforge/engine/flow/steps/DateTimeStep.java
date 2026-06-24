package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * "datetime" step. params: {op, value, amount, unit, format}. Ops: now, epoch, format,
 * add, diff, year, month, day, dayOfWeek. Returns {result}.
 */
@Component
public class DateTimeStep implements FlowStep {

    @Override
    public String type() {
        return "datetime";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String op = String.valueOf(p.getOrDefault("op", "now"));
        Object result = switch (op) {
            case "now" -> Instant.now().toString();
            case "epoch" -> Instant.now().toEpochMilli();
            case "format" -> LocalDate.parse(str(p.get("value")))
                    .format(DateTimeFormatter.ofPattern(strOr(p.get("format"), "yyyy-MM-dd")));
            case "add" -> LocalDate.parse(str(p.get("value")))
                    .plusDays(amount(p)).toString();
            case "diff" -> Duration.between(
                    Instant.parse(ensureInstant(str(p.get("value")))),
                    Instant.parse(ensureInstant(str(p.get("value2"))))).toDays();
            case "year" -> LocalDate.parse(str(p.get("value"))).getYear();
            case "month" -> LocalDate.parse(str(p.get("value"))).getMonthValue();
            case "day" -> LocalDate.parse(str(p.get("value"))).getDayOfMonth();
            case "dayOfWeek" -> LocalDate.parse(str(p.get("value"))).getDayOfWeek().toString();
            default -> throw new IllegalArgumentException("Unknown datetime op '" + op + "'");
        };
        return Map.of("result", result);
    }

    private long amount(Map<String, Object> p) {
        try {
            return Long.parseLong(str(p.getOrDefault("amount", "0")));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String ensureInstant(String s) {
        return s.contains("T") ? s : s + "T00:00:00Z";
    }

    private String str(Object o) {
        return o == null ? "" : String.valueOf(o);
    }

    private String strOr(Object o, String def) {
        String s = str(o);
        return s.isEmpty() ? def : s;
    }
}
