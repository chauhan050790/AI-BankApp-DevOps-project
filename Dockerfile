# syntax=docker/dockerfile:1
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /workspace

# Resolve dependencies before copying application sources to maximize layer reuse.
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw -B -ntp dependency:go-offline

COPY src/ src/
COPY k8s/ k8s/
COPY helm/ helm/
COPY .github/ .github/
COPY docker-compose.yml ./
RUN ./mvnw -B -ntp clean verify

FROM eclipse-temurin:25-jre-alpine AS runtime
WORKDIR /app

RUN addgroup -S -g 10001 bankapp \
    && adduser -S -D -H -u 10001 -G bankapp bankapp

COPY --from=build --chown=10001:10001 /workspace/target/*.jar /app/app.jar

USER 10001:10001
EXPOSE 8080 8081

ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir=/tmp"

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD wget -q -O - http://127.0.0.1:8081/actuator/health/liveness | grep -q '"status":"UP"' || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
