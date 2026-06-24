package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.Objects;

/**
 * "condition" step: evaluates {@code left op right} and returns a Boolean the engine uses
 * to branch to then/else. Operators: == != &gt; &gt;= &lt; &lt;= contains.
 */
@Component
public class ConditionStep implements FlowStep {

    @Override
    public String type() {
        return "condition";
    }

    @Override
    public Object execute(StepConfig step, FlowContext ctx) {
        Object left = Expressions.resolve(step.params.get("left"), ctx.root());
        Object right = Expressions.resolve(step.params.get("right"), ctx.root());
        String op = String.valueOf(step.params.getOrDefault("op", "=="));

        Double ln = asNumber(left);
        Double rn = asNumber(right);
        return switch (op) {
            case "==" -> equalsLoose(left, right);
            case "!=" -> !equalsLoose(left, right);
            case ">" -> ln != null && rn != null && ln > rn;
            case ">=" -> ln != null && rn != null && ln >= rn;
            case "<" -> ln != null && rn != null && ln < rn;
            case "<=" -> ln != null && rn != null && ln <= rn;
            case "contains" -> left != null && right != null
                    && String.valueOf(left).contains(String.valueOf(right));
            default -> throw new IllegalArgumentException("Unknown condition op '" + op + "'");
        };
    }

    private boolean equalsLoose(Object a, Object b) {
        Double an = asNumber(a);
        Double bn = asNumber(b);
        if (an != null && bn != null) {
            return an.doubleValue() == bn.doubleValue();
        }
        return Objects.equals(a == null ? null : String.valueOf(a),
                b == null ? null : String.valueOf(b));
    }

    private Double asNumber(Object o) {
        if (o instanceof Number n) {
            return n.doubleValue();
        }
        try {
            return o == null ? null : Double.parseDouble(o.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
