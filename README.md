# PALWORLD Save Pal

> **Note**: This project was put together for fun and to kick the tires on Sveltekit 5 and Skeleton UI Next. Things may be broken or not work as expected.

⚠️ **Backup your save files before using this tool!!** ⚠️

Palworld Save Pal is a tool for managing and analyzing save files.

## 📋 Table of Contents

- [PALWORLD Save Pal](#palworld-save-pal)
  - [📋 Table of Contents](#-table-of-contents)
  - [🚀 Installation](#-installation)
  - [🎮 Usage](#-usage)
  - [🐳 Docker](#-docker)
  - [👨‍💻 Developer Guide](#-developer-guide)
    - [Web](#web)
    - [Desktop App](#desktop-app)
    - [Build Desktop App](#build-desktop-app)
      - [Using build script](#using-build-script)
      - [Manual build](#manual-build)
  - [🔥 Features](#-features)
    - [General](#general)
    - [Pals](#pals)
    - [Players](#players)
    - [Guilds](#guilds)
    - [Extras](#extras)
  - [📜 License](#-license)
  - [➡️ Related Projects](#️-related-projects)
  - [☕ Buy me a Coffee](#-buy-me-a-coffee)

## 🚀 Installation

Grab the latest release from the [releases](https://github.com/oMaN-Rod/palworld-save-pal/releases) page and extract it to a folder of your choice.

## 🎮 Usage

Details for using Palworld Save Pal can be found in the [User Guide](https://github.com/oMaN-Rod/palworld-save-pal/wiki/%F0%9F%8E%AE-Usage)

## 🐳 Docker

To run Palworld Save Pal using Docker:

1. Clone this repository:

   ```bash
   git clone https://github.com/oMaN-Rod/palworld-save-pal.git
   ```

2. Run the build script based on your environment, these scripts capture the system IP address and set the environment variable for the svelte SPA:

   > Linux

   ```bash
   ./build-docker.sh
   ```

   > Windows

   ```powershell
   .\build-docker.ps1
   ```

3. Or you can follow these steps:

   1. Modify the `docker-compose.yml` file to set the IP/URL address of your docker host:

      ```yaml
      services:
        backend:
          build:
            context: .
            dockerfile: Dockerfile
            args:
              # Change this to the URL of your public server
              - PUBLIC_WS_URL=127.0.0.1:5174/ws
          ports:
            - "5174:5174"
          volumes:
            - ./data:/app/data
            - ./palworld_save_pal:/app/palworld_save_pal
          environment:
            - PORT=5174
          command: python psp.py
      ```

   2. Build the docker container:

      ```bash
      docker compose up --build -d
      ```

## 👨‍💻 Developer Guide

For developers who want to contribute to Palworld Save Pal:

### Web

1. Set up the development environment:

   ```bash
   uv sync
   source .venv/bin/activate
   ```

2. Run the application in development mode:

   ```bash
   cd ui
   bun install
   bun run dev:web
   ```

3. Open your browser and navigate to `http://127.0.0.1:5173`

### Desktop App

1. Set the environment variable for the svelte SPA `ui/.env`.

   ```env
   PUBLIC_WS_URL=127.0.0.1:5174/ws
   PUBLIC_DESKTOP_MODE=true
   ```

2. Activate python environment

   ```powershell
   uv sync
   .venv\Scripts\activate
   ```

3. Run the desktop app:

   ```powershell
   cd ui
   bun install
   bun run dev:desktop
   ```

### Build Desktop App

> Activate the environment

```powershell
uv sync
.venv\Scripts\activate
```

#### Using build script

```powershell
.\build-desktop.ps1
```

#### Manual build

1. Set the environment variable for the svelte SPA `ui/.env`.

   ```env
   PUBLIC_WS_URL=127.0.0.1:5174/ws
   PUBLIC_DESKTOP_MODE=true
   ```

2. Build the SPA (replace bun with your package manager of choice). This will create a build directory in the project root containing the static files for the SPA:

   ```powershell
   cd ui
   bun install
   bun run build
   cd ..
   mkdir dist
   ```

3. Build standalone executable:

   ```powershell
   python setup.py build
   ```

or

3. Build installer:

   ```powershell
   python setup.py bdist_msi
   ```

> **Note:** The `dist` folder will contain the executable and the SPA build files, the data folder contains json files with game data, all need to be distributed together.

## 🔥 Features

### General

- [x] Filter/Sort Pals by name, nickname, character ID, Boss, Lucky, Human, Level, Paldeck #, Predator, Oil Rig, Summon, or Element type
- [x] Gamepass & Steam support (solo/coop/dedicated)
- [x] Localization; supports Deutsch, English, Español, Français, Italiano, 한국어, Português, Русский, 简体中文, and 繁體中文

### Pals

- [x] Edit Pal box, Base, and Dimensional Pal Storage Pals
- [x] Edit Nickname
- [x] Edit Gender
- [x] Edit Active Skills / Learned Skills
- [x] Edit Passive Skills
- [x] Edit Level
- [x] Edit Rank
- [x] Edit Souls
- [x] Edit Trust
- [x] Set/Unset Lucky
- [x] Set/Unset Boss
- [x] Add/Remove/Clone Pals
- [x] Edit Work Suitability
- [x] Heal Pals - edit health and stomach (Modified pals are automatically healed)
- [x] Create your own Active/Passive Skill presets, making it easy af to apply skills.
- [x] Apply Pal preset on multiple Pals, e.g., max out all Dragon types with a specific profile.

### Players

- [x] Edit Name
- [x] Edit Level
- [x] Edit Stats (Health, Stamina, Attack, Work Speed, and Weight)
- [x] Heal Player - edit health and stomach
- [x] Edit Inventory
- [x] Edit Technologies
- [x] Create your own inventory presets/load outs and apply them across players and saves.
- [x] Edit Technology Tree, Technology Points, and Ancient Technology points
- [x] Delete Players (Deletes all map objects, items, and pals)

### Guilds

- [x] Edit Guild Name
- [x] Edit Guild Chest
- [x] Edit Base Pals
- [x] Edit Base Inventory
- [x] Edit Lab Research
- [x] Delete Guilds (Deletes all players, map objects, items, and pals)

### Extras

- [x] Data Explorer / Debug Mode (Read Only)
- [x] Map integration
- [x] Preset management

## 📜 License

MIT License (do whatever you want with it).

## ➡️ Related Projects

These are projects I've found that specifically target Palworld save files, each was helpful in some way during the development of this project:

- [PalEdit](https://github.com/EternalWraith/PalEdit) - PSP was inspired by it.
- [palworld-save-tools](https://github.com/cheahjs/palworld-save-tools) - PSP uses this tool for handling save files, can be used directly to convert to/from json.
- [palworld-uesave-rs](https://github.com/DKingAlpha/palworld-uesave-rs) - I originally considered building this app using Tauri, opted for using Python, but this project was helpful.
- [Palworld Pal Editor](https://github.com/KrisCris/Palworld-Pal-Editor) - Also served as a reference for Palworld Save Pal, adopted some of this projects approach.
- [PalWorldSaveTools](https://github.com/deafdudecomputers/PalWorldSaveTools) - Has a bunch of useful features for parsing, editing, and converting save files.

## ☕ Buy me a Coffee

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/i_am_o)
