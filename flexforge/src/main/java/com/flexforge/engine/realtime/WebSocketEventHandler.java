package com.flexforge.engine.realtime;

import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

/** Broadcasts entity-change events to all connected WebSocket clients at /ws/events. */
@Component
public class WebSocketEventHandler extends TextWebSocketHandler {

    private final RealtimeService realtime;
    private final Set<WebSocketSession> sessions = new CopyOnWriteArraySet<>();

    public WebSocketEventHandler(RealtimeService realtime) {
        this.realtime = realtime;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        sessions.add(session);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        sessions.remove(session);
    }

    @EventListener
    public void onEvent(EntityEvent event) {
        TextMessage message = new TextMessage(realtime.toJson(event));
        for (WebSocketSession session : sessions) {
            try {
                if (session.isOpen()) {
                    session.sendMessage(message);
                }
            } catch (Exception e) {
                sessions.remove(session);
            }
        }
    }
}
