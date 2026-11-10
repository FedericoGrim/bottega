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

---

## 002 — Roslyn language server instead of OmniSharp for C#
- **Date:** 2026-11-04
- **Status:** Accepted
- **Context:** The default LazyVim `lang.dotnet` extra uses OmniSharp, which supports new C# features (for example `required` members) late. The machine runs .NET 10.
- **Decision:** `roslyn.nvim` with the Microsoft Roslyn language server, installed by Mason from the `Crashdummyy/mason-registry` registry; OmniSharp is disabled in `lua/plugins/dotnet.lua`. `dev-env.sh` installs `roslyn` and, if the registry points to a release that does not exist, retries with the pinned version `5.14.0-1.26552.12`.
- **Alternatives:** OmniSharp, rejected for the delay on new C# features; `csharp-ls`, rejected because it has fewer features.
- **Consequences:** The pin must be updated by hand when the registry catches up. The first start of a C# solution is slow because Roslyn analyses the whole solution.

---

## 003 — mise manages the command-line tools and its config travels with the export
- **Date:** 2026-11-04
- **Status:** Accepted
- **Context:** A new machine must get the same tools as this one (bat, eza, delta, direnv, uv, starship). Installing each one with apt or a script gives different versions on each machine, and apt does not carry some of them.
- **Decision:** `dev-env.sh export` saves the `[tools]` section of `~/.config/mise/config.toml` (never `[env]`, which can hold secrets) and `install` runs `mise install`, then `mise use -g bat eza delta direnv uv starship`. Language toolchains are opt-in with `--languages`: Java, Maven, Python and .NET through apt; Go, Node and pnpm through mise; Rust through `rustup`. Corepack is not used because Node 26 no longer ships it.
- **Alternatives:** One apt or curl installer per tool, rejected for version drift; Homebrew, rejected as an extra package manager for a Debian-based setup.
- **Consequences:** Tools follow `latest` unless a version is pinned in the exported `config.toml`. The Git pager is set only when delta exists, so a failed install never leaves Git without output.

---

## 004 — Neovim configuration versioned in `nvim/`, without `lazy-lock.json`
- **Date:** 2026-11-05
- **Status:** Accepted
- **Context:** The LazyVim extras (Python, Java, Go, Rust, C#, TypeScript and others) and the custom plugins lived only in `~/.config/nvim`, which is not a Git repository. On a new machine `dev-env.sh install` without an export archive got the plain LazyVim starter.
- **Decision:** The configuration is copied into `nvim/` (`init.lua`, `lazyvim.json`, `lua/config`, `lua/plugins/dotnet.lua`, `lua/plugins/neotest.lua`). `install_nvim_config` uses, in order, the config already in `~/.config/nvim`, then `nvim/`, then the starter. `lazy-lock.json` is ignored by Git.
- **Alternatives:** Versioning `lazy-lock.json`, rejected: the setup should follow the latest plugins, and the lock file changes on every `:Lazy sync`, filling the history with noise.
- **Consequences:** Changes made in `~/.config/nvim` must be copied to `nvim/` by hand to reach the repository. Plugin versions can differ between machines.
