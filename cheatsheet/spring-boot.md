# Spring Boot

## Creare il progetto

| Comando | Cosa fa |
| --- | --- |
| `curl https://start.spring.io/starter.zip -d dependencies=web,data-jpa,postgresql -d type=maven-project -o demo.zip` | scarica un progetto da Spring Initializr |
| `curl https://start.spring.io` | mostra le opzioni di Initializr |
| `java -version` | versione di Java |

## Maven

| Comando | Cosa fa |
| --- | --- |
| `./mvnw spring-boot:run` | avvia l'app |
| `./mvnw spring-boot:run -Dspring-boot.run.profiles=dev` | avvia con il profilo dev |
| `./mvnw clean package` | compila e crea il jar in target/ |
| `./mvnw clean package -DskipTests` | crea il jar senza test |
| `./mvnw test` | esegue i test |
| `./mvnw test -Dtest=NomeTest` | esegue una sola classe di test |
| `./mvnw dependency:tree` | albero delle dipendenze |
| `./mvnw versions:display-dependency-updates` | dipendenze da aggiornare |
| `./mvnw spring-boot:build-image` | crea un'immagine container |

## Gradle

| Comando | Cosa fa |
| --- | --- |
| `./gradlew bootRun` | avvia l'app |
| `./gradlew bootRun --args='--spring.profiles.active=dev'` | avvia con il profilo dev |
| `./gradlew build` | compila e testa |
| `./gradlew bootJar` | crea il jar in build/libs/ |
| `./gradlew test` | esegue i test |
| `./gradlew test --tests NomeTest` | esegue una sola classe di test |
| `./gradlew dependencies` | albero delle dipendenze |
| `./gradlew bootBuildImage` | crea un'immagine container |

## Eseguire e configurare

| Comando | Cosa fa |
| --- | --- |
| `java -jar target/app.jar` | avvia il jar |
| `java -jar app.jar --server.port=9090` | cambia la porta |
| `SPRING_PROFILES_ACTIVE=prod java -jar app.jar` | sceglie il profilo con una variabile |
| `curl localhost:8080/actuator/health` | stato dell'app (serve Actuator) |
| `curl localhost:8080/actuator/env` | configurazione letta dall'app |
