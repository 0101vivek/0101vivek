package com.flexforge.engine.notify;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

/**
 * Sends notifications. v0 records them to a bounded buffer and the log (so flows and tests
 * work with no external services); real email/SMS/push transports (SMTP, Twilio, FCM) plug
 * in behind the same {@code send} call as connectors.
 */
@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger("flexforge.notify");
    private static final int BUFFER = 200;

    public record Notification(String at, String channel, String to, String subject, String message) {
    }

    private final Deque<Notification> sent = new ArrayDeque<>();

    public synchronized Notification send(String channel, String to, String subject, String message) {
        Notification n = new Notification(Instant.now().toString(),
                channel == null ? "log" : channel, to, subject, message);
        sent.addLast(n);
        while (sent.size() > BUFFER) {
            sent.removeFirst();
        }
        log.info("[notify:{}] to={} subject={} :: {}", n.channel(), to, subject, message);
        return n;
    }

    public synchronized List<Notification> recent() {
        return new ArrayList<>(sent);
    }
}
