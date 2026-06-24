package com.flexforge.engine.flow;

import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.config.model.FlowConfig;
import com.flexforge.engine.config.model.TriggerConfig;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.scheduling.support.CronTrigger;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.HashMap;

/**
 * Runs flows whose trigger is "schedule" — on a cron expression or a fixed rate. This is
 * the scheduled/cron trigger for the no-code automation layer (EOD jobs, reminders,
 * billing runs, etc.). Manual flows are unaffected.
 */
@Component
public class FlowScheduler {

    private static final Logger log = LoggerFactory.getLogger(FlowScheduler.class);

    private final MetadataRegistry registry;
    private final FlowEngine engine;
    private ThreadPoolTaskScheduler scheduler;

    public FlowScheduler(MetadataRegistry registry, FlowEngine engine) {
        this.registry = registry;
        this.engine = engine;
    }

    @PostConstruct
    public void start() {
        scheduler = new ThreadPoolTaskScheduler();
        scheduler.setPoolSize(2);
        scheduler.setThreadNamePrefix("flexforge-sched-");
        scheduler.initialize();

        for (FlowConfig flow : registry.config().flows) {
            TriggerConfig t = flow.trigger;
            if (t == null || !"schedule".equalsIgnoreCase(t.type)) {
                continue;
            }
            Runnable task = () -> {
                try {
                    engine.run(flow.name, new HashMap<>());
                } catch (Exception e) {
                    log.warn("[scheduler] flow '{}' failed: {}", flow.name, e.getMessage());
                }
            };
            if (t.cron != null && !t.cron.isBlank()) {
                scheduler.schedule(task, new CronTrigger(t.cron));
                log.info("[scheduler] flow '{}' scheduled with cron '{}'", flow.name, t.cron);
            } else if (t.fixedRateMs != null && t.fixedRateMs > 0) {
                scheduler.scheduleAtFixedRate(task, Duration.ofMillis(t.fixedRateMs));
                log.info("[scheduler] flow '{}' scheduled every {}ms", flow.name, t.fixedRateMs);
            }
        }
    }

    @PreDestroy
    public void stop() {
        if (scheduler != null) {
            scheduler.shutdown();
        }
    }
}
