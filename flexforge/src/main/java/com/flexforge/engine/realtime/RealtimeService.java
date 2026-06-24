package com.flexforge.engine.realtime;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Fan-out hub for {@link EntityEvent}s. Keeps a bounded buffer of recent events (queryable
 * over REST) and pushes live events to SSE subscribers. The WebSocket handler subscribes
 * to the same events independently, so one change reaches every real-time transport.
 */
@Service
public class RealtimeService {

    private static final Logger log = LoggerFactory.getLogger(RealtimeService.class);
    private static final int BUFFER = 100;

    private final ObjectMapper objectMapper;
    private final Deque<EntityEvent> recent = new ArrayDeque<>();
    private final List<SseEmitter> emitters = new CopyOnWriteArrayList<>();

    public RealtimeService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @EventListener
    public synchronized void onEvent(EntityEvent event) {
        recent.addLast(event);
        while (recent.size() > BUFFER) {
            recent.removeFirst();
        }
        for (SseEmitter emitter : emitters) {
            try {
                emitter.send(SseEmitter.event().name("change").data(event));
            } catch (IOException | RuntimeException e) {
                emitters.remove(emitter);
            }
        }
    }

    public SseEmitter subscribe() {
        SseEmitter emitter = new SseEmitter(0L); // no timeout
        emitters.add(emitter);
        emitter.onCompletion(() -> emitters.remove(emitter));
        emitter.onTimeout(() -> emitters.remove(emitter));
        try {
            emitter.send(SseEmitter.event().name("ready").data("subscribed"));
        } catch (IOException ignored) {
            // client gone already
        }
        return emitter;
    }

    public synchronized List<EntityEvent> recent(String entity) {
        List<EntityEvent> out = new ArrayList<>();
        for (EntityEvent e : recent) {
            if (entity == null || entity.equalsIgnoreCase(e.entity())) {
                out.add(e);
            }
        }
        return out;
    }

    public String toJson(EntityEvent event) {
        try {
            return objectMapper.writeValueAsString(event);
        } catch (Exception e) {
            return "{}";
        }
    }
}
