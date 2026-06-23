# Reference Dockerfile. The recommended path is Google Jib (no Dockerfile, no source in
# the image): `mvn compile jib:build -Dimage=...`. This file is the documented fallback.
#
# Note: the engine image is generic. A per-app artifact mounts/bakes a config bundle and
# supplies DB connection details via environment variables at deploy time.

FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -q -B package -DskipTests || mvn -q -B package -DskipTests

FROM eclipse-temurin:21-jre AS runtime
WORKDIR /app
COPY --from=build /src/target/flexforge-engine-*.jar /app/engine.jar
EXPOSE 8080
# Override at deploy time:
#   -e DB_ENGINE=postgres -e DB_URL=... -e DB_USERNAME=... -e DB_PASSWORD=...
#   -e FLEXFORGE_CONFIG_PATH=/config/app.yaml  (with a mounted /config volume)
ENTRYPOINT ["java", "-jar", "/app/engine.jar"]
