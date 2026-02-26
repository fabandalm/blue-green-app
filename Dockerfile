# Multi-stage build
# Stage 1: Build the application
FROM gradle:8.5-jdk17 AS build
WORKDIR /app
COPY . .
RUN gradle :app:build -x test --no-daemon

# Stage 2: Run the application
FROM eclipse-temurin:17-jre
WORKDIR /app
# Copy only the executable fat jar (not the plain jar)
COPY --from=build /app/app/build/libs/app-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
