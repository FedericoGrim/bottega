# Decision Log

Significant decisions for this project. Newest at the bottom. Entries are never deleted.

---

## 001 — Container engine chosen in a config file
- **Date:** 2026-11-01
- **Status:** Accepted
- **Context:** The scripts only worked with Podman. Docker users need the same commands, and some machines have both engines installed.
- **Decision:** `install.sh` asks for the engine and writes `DEV_ENGINE` (plus `DEV_PANEL`, `DEV_SHELL`) to `~/.config/dev-variants/config`. Every script sources that file; an environment variable with the same name overrides it. The default stays `podman`.
- **Alternatives:** Detecting the engine at run time, rejected because it is ambiguous when both are installed and can switch engines silently between runs.
- **Consequences:** Changing engine means rerunning `install.sh` or editing the file. Containers created with one engine are not seen by the other.
