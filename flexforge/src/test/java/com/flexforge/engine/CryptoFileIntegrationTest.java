package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Covers field-level encryption (transparent encrypt-at-rest / decrypt-on-read) and the
 * file module (upload, base64 retrieval, raw download).
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class CryptoFileIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void encryptedFieldRoundTripsTransparently() {
        ResponseEntity<Map> created = rest.postForEntity("/api/Customer",
                Map.of("email", "enc@example.com", "fullName", "Encrypted", "ssn", "123-45-6789"),
                Map.class);
        assertThat(created.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        Object id = created.getBody().get("id");

        // read back: the engine decrypts on the way out, so the caller sees plaintext
        ResponseEntity<Map> fetched = rest.getForEntity("/api/Customer/" + id, Map.class);
        assertThat(fetched.getBody().get("ssn")).isEqualTo("123-45-6789");
    }

    @Test
    void fileUploadDownloadAndBase64() {
        ResponseEntity<Map> doc = rest.postForEntity("/api/Document",
                Map.of("title", "spec"), Map.class);
        Object id = doc.getBody().get("id");

        byte[] content = "hello flexforge file".getBytes(StandardCharsets.UTF_8);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        ByteArrayResource resource = new ByteArrayResource(content) {
            @Override
            public String getFilename() {
                return "note.txt";
            }
        };
        MultiValueMap<String, Object> form = new LinkedMultiValueMap<>();
        form.add("file", resource);

        ResponseEntity<Map> uploaded = rest.postForEntity(
                "/api/Document/" + id + "/file/attachment",
                new HttpEntity<>(form, headers), Map.class);
        assertThat(uploaded.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(uploaded.getBody().get("filename")).isEqualTo("note.txt");

        // base64 form returns the stored content
        ResponseEntity<Map> b64 = rest.getForEntity(
                "/api/Document/" + id + "/file/attachment?format=base64", Map.class);
        byte[] decoded = Base64.getDecoder().decode((String) b64.getBody().get("dataBase64"));
        assertThat(decoded).isEqualTo(content);

        // raw download returns the bytes
        ResponseEntity<byte[]> raw = rest.getForEntity(
                "/api/Document/" + id + "/file/attachment", byte[].class);
        assertThat(raw.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(raw.getBody()).isEqualTo(content);
    }
}
