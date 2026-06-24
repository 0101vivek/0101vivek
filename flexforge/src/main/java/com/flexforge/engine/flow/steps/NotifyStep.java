package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import com.flexforge.engine.notify.NotificationService;
import org.springframework.stereotype.Component;

import java.util.Map;

/** "notify" step: sends a notification. params: {channel, to, subject, message}. */
@Component
public class NotifyStep implements FlowStep {

    private final NotificationService notifications;

    public NotifyStep(NotificationService notifications) {
        this.notifications = notifications;
    }

    @Override
    public String type() {
        return "notify";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        NotificationService.Notification n = notifications.send(
                str(p.get("channel")), str(p.get("to")), str(p.get("subject")), str(p.get("message")));
        return Map.of("sent", true, "channel", n.channel());
    }

    private String str(Object o) {
        return o == null ? null : String.valueOf(o);
    }
}
