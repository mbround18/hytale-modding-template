# Hytale Modding Template

This template splits mod work into two parts:

- **plugin/**: Java plugin project (commands, gameplay tweaks, etc.).
- **assets/**: Packaged data such as `manifest.json`, `Server/`, and `Common/` content that ships with the plugin.

## Prerequisites

- Docker and Docker Compose (v2 syntax).
- Git with access to `git@github.com:Ranork/Hytale-Server-Unpacked.git`.
- Java 25 installed (for Gradle wrapper).
- `unzip` available on PATH.

## Setup

Run the setup task from the repo root (wrapper downloads Gradle 8.7 automatically):

```sh
./gradlew setup
```

What `setup` does:

- Ensures `data/server`, `data/assets`, and `data/unpacked` exist and are owned by `1000:1000`.
- If `data/server/Server/HytaleServer.jar` is missing, starts `docker compose -f compose.yml up` and waits until the jar is produced, then tears the stack down.
- Unzips `data/server/Assets.zip` into `data/assets` (overwrites existing files).
- Clones `git@github.com:Ranork/Hytale-Server-Unpacked.git` into `data/unpacked` (skips if a repo already exists there).

## Working in the template

- Place your Java plugin sources under `plugin/`. Configure your Gradle build there to produce the plugin jar.
- Place Hytale data that should be bundled (e.g., `manifest.json`, `Server/`, `Common/`) under `assets/`.
- The `data/` directory is for local provisioning only and is ignored from version control; it is recreated by `setup`.

## Build and distribution

- Run `./gradlew build` to produce distributables and install them into the local server mods directory.
- Outputs land in `dist/`: `HelloWorld-<version>.jar` and `assets.zip` (zip root contains `manifest.json`, `Server/`, `Common/` — no leading `assets/`).
- The same jar and zip are copied into `data/server/Server/mods/` to replace any existing copies for quick local testing.

## Local testing

- Run `./gradlew start` to build everything and launch `docker compose up` in the foreground so you can watch logs and interact.
- In-game, use Direct Connect to `127.0.0.1` to hit the locally running server.
- Stop with `Ctrl+C` once you're done testing; rerun `./gradlew start` after code or asset changes.

## HelloWorld example

- Starter plugin lives at `plugin/src/main/java/com/example/hytale/helloworld/HelloWorldPlugin.java` and logs a hello message on startup and shutdown.
- Plugin metadata is in `plugin/src/main/resources/plugin.properties` and jar manifest entries are filled via Gradle.
- Use this as a minimal, well-documented base to wire in your own commands, listeners, and content.

## Common tasks

- Refresh server files: delete `data/server/Server/HytaleServer.jar` then rerun `gradle setup`.
- Refresh assets: delete `data/assets` and rerun `gradle setup` to re-unzip from `Assets.zip`.
- Update API docs: remove `data/unpacked` and rerun `gradle setup` to reclone.
