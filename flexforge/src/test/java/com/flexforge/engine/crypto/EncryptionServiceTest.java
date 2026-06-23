package com.flexforge.engine.crypto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class EncryptionServiceTest {

    private final EncryptionService enc = new EncryptionService("unit-test-secret");

    @Test
    void roundTripsAndCiphertextDiffersFromPlaintext() {
        String plain = "123-45-6789";
        String cipher = enc.encrypt(plain);
        assertThat(cipher).isNotEqualTo(plain);
        assertThat(enc.decrypt(cipher)).isEqualTo(plain);
    }

    @Test
    void sameInputEncryptsDifferentlyEachTime() {
        // random IV → non-deterministic ciphertext, both decrypt back to the same value
        String a = enc.encrypt("secret");
        String b = enc.encrypt("secret");
        assertThat(a).isNotEqualTo(b);
        assertThat(enc.decrypt(a)).isEqualTo("secret");
        assertThat(enc.decrypt(b)).isEqualTo("secret");
    }

    @Test
    void base64RoundTrips() {
        byte[] data = {1, 2, 3, 4, 5};
        assertThat(EncryptionService.base64Decode(EncryptionService.base64Encode(data))).isEqualTo(data);
    }
}
