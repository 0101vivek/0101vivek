package com.flexforge.engine.api.realtime;

import com.flexforge.engine.realtime.EntityEvent;
import com.flexforge.engine.realtime.RealtimeService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;

/**
 * Real-time HTTP surfaces over the same change-event stream:
 * <ul>
 *   <li>{@code GET /realtime/stream} — Server-Sent Events live feed of changes.</li>
 *   <li>{@code GET /realtime/recent} — the recent-events buffer (pull, easy to consume/test).</li>
 * </ul>
 * (WebSocket clients get the same stream at {@code /ws/events}.)
 */
@RestController
public class RealtimeController {

    private final RealtimeService realtime;

    public RealtimeController(RealtimeService realtime) {
        this.realtime = realtime;
    }

    @GetMapping(value = "/realtime/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream() {
        return realtime.subscribe();
    }

    @GetMapping(value = "/realtime/recent", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<EntityEvent> recent(@RequestParam(required = false) String entity) {
        return realtime.recent(entity);
    }
}
