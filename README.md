# 🎮 Anime FPS Game

A modular, scalable FPS (First Person Shooter) kit for Roblox, built with a modern development workflow using **Rojo + VS Code + Wally**.

This project is designed for developers who want a clean, maintainable codebase outside of Roblox Studio, with support for professional tooling and fast iteration.

---

## ✨ Features

- 🔫 Weapon system (modular & extendable)
- 🎥 Viewmodel system (FPS arms & weapons)
- 🎯 Shooting & hit detection
- 🔄 Reload mechanics
- 🧠 Clean architecture (client/server separation)
- 📦 Wally package management
- 🔗 Rojo syncing for external development
- ⚛️ (Optional) React UI support (if used in your project)

---

```bash
## 📁 Project Structure
Anime-FPS-Game/
│
├── src/ # Main source code
│ ├── client/ # Client-side scripts
│ ├── server/ # Server-side scripts
│ ├── shared/ # Shared modules (configs, utilities)
│
├── Packages/ # Wally dependencies
├── default.project.json
├── wally.toml
└── README.md
```

---

## 📦 Requirements

Make sure you have the following installed:

- **Roblox Studio**
- **Rojo** → https://rojo.space/
- **Wally** → https://wally.run/
- **Rokit** → https://github.com/rojo-rbx/rokit
- **VS Code** (recommended)
- **Rojo Studio Plugin**


---

## ⚙️ Installation & Setup

Follow these steps carefully:

---

### 1️⃣ Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/anime-fps-game.git
cd anime-fps-game


rokit add wally
rokit add wally-packages-types
wally install

rojo build -o "Anime FPS Game.rbxlx"

rojo serve
```
