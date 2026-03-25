# 🎮 Anime FPS Game

A modular, scalable FPS (First Person Shooter) kit for Roblox, built with a modern workflow using **Rojo + VS Code + Wally**.

This project is designed for developers who prefer working outside Roblox Studio with a clean architecture, fast iteration, and professional tooling.

---

## ✨ Features

- 🔫 Modular weapon system  
- 🎥 FPS viewmodel system  
- 🎯 Shooting & hit detection  
- 🔄 Reload mechanics  
- 🧠 Clean client/server architecture  
- 📦 Wally package management  
- 🔗 Rojo live syncing  
- ⚛️ Optional React UI support  

---

## 📁 Project Structure

```
Anime-FPS-Game/
│
├── src/
│   ├── client/        # Client-side scripts
│   ├── server/        # Server-side scripts
│   ├── shared/        # Shared modules (configs, utils)
│
├── Packages/          # Wally dependencies
├── default.project.json
├── wally.toml
└── README.md
```

---

## 📦 Requirements

- Roblox Studio  
- Rojo → https://rojo.space/  
- Wally → https://wally.run/  
- Rokit → https://github.com/rojo-rbx/rokit  
- VS Code (recommended)  
- Rojo Studio Plugin  

---

## ⚙️ Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/anime-fps-game.git
cd anime-fps-game
```

### 2. Install dependencies

```bash
rokit add wally
rokit add wally-packages-types
wally install
```

### 3. Build the place file

```bash
rojo build -o "Anime FPS Game.rbxlx"
```

### 4. Open in Roblox Studio

Open:
Anime FPS Game.rbxlx

### 5. Start Rojo server

```bash
rojo serve
```

### 6. Connect in Roblox Studio

- Install Rojo Plugin  
- Click Connect  
- Sync with VS Code  

---

## 🔁 Development Workflow

1. Edit scripts in VS Code  
2. Rojo syncs changes instantly  
3. Test in Roblox Studio  

---

## 🔫 FPS System Overview

### Weapon System
- Config-driven weapons  
- Easy to extend  

### Viewmodel System
- Attached to camera  
- Smooth animations  

### Shooting System
- Client input  
- Server validation  
- RemoteEvents communication  

---

## ⚠️ Common Issues

### Rojo not connecting
- Run `rojo serve`  
- Restart Studio  

### Packages missing
```bash
wally install
```

### Build issues
```bash
rojo build -o "Anime FPS Game.rbxlx"
```

---

## 🧪 Future Plans

- Recoil system  
- Attachments  
- Multiplayer improvements  
- UI polish  

---

## 🤝 Contributing

1. Fork  
2. Branch  
3. Commit  
4. Pull Request  

---

## 📜 License

Open-source (add MIT if needed)

---

## 📌 Status

🚧 Work in progress  

---

## ⭐ Support

- Star the repo  
- Fork it  
- Contribute  

---

## 📚 Links

- https://rojo.space/docs  
- https://wally.run/docs  
- https://create.roblox.com/docs  
