package com.flexforge.engine.api.notify;

import com.flexforge.engine.notify.NotificationService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** Exposes recently sent notifications: {@code GET /__notifications} (demo/inspection). */
@RestController
public class NotificationController {

    private final NotificationService notifications;

    public NotificationController(NotificationService notifications) {
        this.notifications = notifications;
    }

    @GetMapping(value = "/__notifications", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<NotificationService.Notification> recent() {
        return notifications.recent();
    }
}
