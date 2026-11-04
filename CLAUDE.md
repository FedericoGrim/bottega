# Bottega

## Overview
Terminal development environment. The `dev` command opens, in tmux: LazyVim, an AI agent (Claude Code or OpenCode),
lazygit, a container panel and terminals, either on the PC or inside a dev container (Podman or Docker).
Four entry points: `dev`, `dev-o`, `dev-c-c`, `dev-c-o`. The owner is the only user; the goal is the same setup on every machine.

## Tech stack
- Bash scripts and Python 3 (standard library only).
- tmux 3.2 or newer, fzf, jq, Neovim with LazyVim, lazygit.
- Podman or Docker, the `devcontainer` CLI.
- mise manages the command-line tools (bat, eza, delta, direnv, uv, starship); see `docs/decisions.md`.

## Architecture
- `bin/`: the scripts, copied to `~/.local/bin` by `install.sh`. `dev-docs` and `dev-guard` are Python, the rest is Bash.
- `tmux/`: the three tmux configurations (main, side panel, terminals).
- `install.sh`: interactive installer that writes `~/.config/bottega/config`.
- `dev-env.sh`: `export` and `install` to move the whole setup to another machine (Debian, Ubuntu, Mint).
- `cheatsheet/*.md`: one topic per file, parsed by `bin/dev-docs` (the `Ctrl+b g` popup).
- `docs/decisions.md`: decision log. `tests/`: test suites.
- Everything runs in three tmux servers: the main one, `-L side` (agent, lazygit, container panel) and `-L terminals`.

## Commands
- All tests: `python3 -m unittest discover -s tests` and `for suite in tests/test_*.sh; do bash "$suite"; done`.
- Lint: `shellcheck -x -P SCRIPTDIR <file>`; hooks: `pre-commit run --all-files`.
- Enable the hooks once per clone: `pre-commit install --hook-type pre-commit --hook-type commit-msg`.
- Try the installer: `./install.sh --help`; `./dev-env.sh export` then `./dev-env.sh install` on a clean machine.
- `dev --help` lists every command.

## Environment
Variable names are in `.env.example`; the saved choices live in `~/.config/bottega/config`.
Any variable can be set for a single command (`DEV_ENGINE=docker dev-c-c`).
Tests must run with a temporary `HOME` and fake programs, never against the real one.

## Domain glossary
- **side panel**: the right-hand tmux session with the agent, lazygit and the container panel.
- **terminals**: the bottom tmux session; `Alt+n` opens a new tab.
- **personal dir** (`dev-personal`): copy of Neovim, its config and the agents, mounted into dev containers.
- **dev-guard**: Claude Code hook that blocks commands which must run inside the container.
- **cheatsheet topic**: one Markdown file in `cheatsheet/`, one table per section.

## Project conventions
- Cheatsheet rows: the command column is at most 48 characters, and `|` is written as `\|`.
- The installer prints what is missing instead of installing silently, except where `README.md` says so.
- Keep `README.md` in sync: the number of checks in the Test section and the list of cheatsheet topics.

## Security & constraints
- Exports and archives never contain credentials, SSH keys, tokens or the `[env]` section of the mise config.
- Remote scripts (`curl | sh`) only from the official site of the tool, over HTTPS.
- Git settings that call a program (such as `core.pager`) are applied only if that program exists.
- Never commit `.env` files or `dev-env-*.tar.gz` archives.

## Definition of Done (extra)
- `pre-commit run --all-files` is clean and every test suite passes.
- A new installer step has a test with fake `apt-get`, `sudo`, `mise` and `curl`.
- A new tool or option is documented in `README.md` and, if it has commands, in a cheatsheet topic.
- Installer changes are tried on a clean Ubuntu container (Podman) before the PR.

## Decisions
See [docs/decisions.md](docs/decisions.md).

## Do not
- Do not run tests or the installer against the real `HOME`.
- Do not push to `main` or `develop`; open a PR.
- Do not change the user's shell, Git or editor configuration without saying so.
- Do not add Docker-only assumptions: Podman is the default engine.
