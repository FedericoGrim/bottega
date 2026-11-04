# Flutter

## Comandi

| Comando | Cosa fa |
| --- | --- |
| `flutter --version` | versione installata |
| `flutter doctor` | dice cosa manca per compilare |
| `flutter upgrade` | aggiorna Flutter |
| `flutter create --platforms=windows,macos,linux mia_app` | crea una nuova app desktop |
| `flutter run -d linux` | avvia l'app su Linux |
| `flutter build linux` | compila la versione Linux |
| `flutter devices` | dispositivi collegati (telefono con debug USB) |
| `flutter emulators --create` | crea un emulatore Android |
| `adb reverse tcp:8000 tcp:8000` | dal telefono raggiunge il backend sul PC |
| `10.0.2.2` | dall'emulatore Android: indirizzo del PC |

## Dentro flutter run

| Tasto | Cosa fa |
| --- | --- |
| `r` | hot reload: applica le modifiche senza riavviare |
| `R` | hot restart: riavvia l'app |
| `q` | esce |

## In LazyVim (flutter-tools.nvim)

| Comando | Cosa fa |
| --- | --- |
| `:FlutterRun` | avvia l'app |
| `:FlutterDevices` | sceglie il dispositivo |
| `:FlutterEmulators` | avvia un emulatore |
| `:FlutterReload` | hot reload |
| `:FlutterRestart` | hot restart |
| `:FlutterQuit` | ferma l'app |
