# Rust

## Progetto

| Comando | Cosa fa |
| --- | --- |
| `rustc --version` | versione del compilatore |
| `rustup update` | aggiorna Rust |
| `cargo new mio-progetto` | crea un'app |
| `cargo new --lib mia-libreria` | crea una libreria |
| `cargo add nome` | aggiunge una dipendenza |
| `cargo remove nome` | rimuove una dipendenza |
| `cargo update` | aggiorna le dipendenze in Cargo.lock |

## Esecuzione e build

| Comando | Cosa fa |
| --- | --- |
| `cargo run` | compila e avvia |
| `cargo run -- argomenti` | avvia passando argomenti al programma |
| `cargo build` | compila in debug |
| `cargo build --release` | compila ottimizzato in target/release/ |
| `cargo check` | controlla gli errori senza compilare (più veloce) |
| `cargo clean` | cancella target/ |
| `cargo install nome` | installa un programma da crates.io |

## Test e qualità

| Comando | Cosa fa |
| --- | --- |
| `cargo test` | esegue i test |
| `cargo test nome` | esegue solo i test che contengono nome |
| `cargo test -- --nocapture` | mostra l'output dei test |
| `cargo fmt` | formatta il codice |
| `cargo clippy` | suggerimenti e avvisi sul codice |
| `cargo doc --open` | genera e apre la documentazione |
| `cargo tree` | albero delle dipendenze |
| `cargo outdated` | dipendenze da aggiornare (serve cargo-outdated) |
