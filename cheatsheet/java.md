# Java

## Compilare ed eseguire

| Comando | Cosa fa |
| --- | --- |
| `java -version` | versione di Java |
| `javac Main.java` | compila e crea Main.class |
| `java Main` | esegue la classe compilata |
| `java Main.java` | compila ed esegue un solo file in un colpo |
| `jshell` | console per provare codice al volo; /exit per uscire |
| `jar cfe app.jar Main *.class` | crea un jar eseguibile con Main come classe iniziale |
| `java -jar app.jar` | esegue il jar |
| `java -cp "lib/*:." Main` | esegue usando le librerie della cartella lib |

## Maven

| Comando | Cosa fa |
| --- | --- |
| `mvn -v` | versione di Maven e di Java usata |
| `mvn archetype:generate` | crea un progetto da un modello |
| `mvn compile` | compila |
| `mvn test` | esegue i test |
| `mvn test -Dtest=NomeTest` | esegue una sola classe di test |
| `mvn clean package` | ricompila da zero e crea il jar in target/ |
| `mvn clean package -DskipTests` | crea il jar senza eseguire i test |
| `mvn dependency:tree` | albero delle dipendenze |
| `mvn versions:display-dependency-updates` | dipendenze da aggiornare |
| `mvn -q exec:java -Dexec.mainClass=Main` | avvia la classe principale (serve il plugin exec) |

## In LazyVim (jdtls)

| Tasti | Cosa fa |
| --- | --- |
| `Spazio c o` | ordina gli import e toglie quelli inutilizzati |
| `Spazio c x v` | estrae il codice selezionato in una variabile |
| `Spazio c x c` | estrae il codice selezionato in una costante |
| `Spazio c x m` | estrae il codice selezionato in un metodo |
| `Spazio t r` | esegue il test più vicino |
| `Spazio t d` | esegue il test più vicino con il debugger |
| `Spazio d b` | punto di interruzione |

Il primo avvio di jdtls su un progetto è lento: indicizza tutto. Ha bisogno di un pom.xml o di un build.gradle nella cartella.
