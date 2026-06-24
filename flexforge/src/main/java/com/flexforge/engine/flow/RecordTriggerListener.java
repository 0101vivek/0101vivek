package com.flexforge.engine.flow;

import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.config.model.FlowConfig;
import com.flexforge.engine.config.model.TriggerConfig;
import com.flexforge.engine.realtime.EntityEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * Runs flows whose trigger is "record" — automatically, when a matching entity is
 * created/updated/deleted. This is the record-change trigger for the no-code automation
 * layer (e.g. "when a LoanApplication is created, notify ops").
 *
 * <p>A re-entrancy guard prevents trigger storms: db writes performed inside a trigger
 * flow do not themselves fire further record triggers.
 */
@Component
public class RecordTriggerListener {

    private static final Logger log = LoggerFactory.getLogger(RecordTriggerListener.class);
    private static final ThreadLocal<Boolean> IN_TRIGGER = ThreadLocal.withInitial(() -> false);

    private final MetadataRegistry registry;
    private final FlowEngine engine;

    public RecordTriggerListener(MetadataRegistry registry, FlowEngine engine) {
        this.registry = registry;
        this.engine = engine;
    }

    @EventListener
    public void onEvent(EntityEvent event) {
        if (IN_TRIGGER.get()) {
            return; // a write inside a trigger flow must not re-trigger
        }
        for (FlowConfig flow : registry.config().flows) {
            TriggerConfig t = flow.trigger;
            if (t == null || !"record".equalsIgnoreCase(t.type)) {
                continue;
            }
            if (t.entity == null || !t.entity.equalsIgnoreCase(event.entity())) {
                continue;
            }
            if (t.on != null && !t.on.isEmpty() && !t.on.contains(event.op())) {
                continue;
            }
            IN_TRIGGER.set(true);
            try {
                Map<String, Object> input = new HashMap<>();
                input.put("op", event.op());
                input.put("entity", event.entity());
                input.put("id", event.id());
                input.put("record", event.data());
                engine.run(flow.name, input);
            } catch (Exception e) {
                log.warn("[record-trigger] flow '{}' failed: {}", flow.name, e.getMessage());
            } finally {
                IN_TRIGGER.set(false);
            }
        }
    }
}
