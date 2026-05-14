# 🥑 Avocado Hook for Claude Code

Make kawaii avocados rain down your screen every time Claude finishes a task.

---

## Requirements

- [Claude Code](https://claude.ai/code) installed
- **Mac:** macOS 12 or later + Xcode Command Line Tools (free — see note below)
- **Windows:** PowerShell (built into Windows 10/11)

---

## Install (3 steps)

### 🍎 Mac

1. [Download ZIP](https://github.com/fangfangkrkt/avocado-hook/archive/refs/heads/main.zip) and unzip
2. Double-click `install.command`
3. Restart Claude Code — done! 🥑

> **macOS blocked it?** Right-click `install.command` → **Open** → **Open** to bypass the warning the first time.

> **No Xcode tools yet?** Open Terminal and run `xcode-select --install`, then try again.

---

### 🪟 Windows

1. [Download ZIP](https://github.com/fangfangkrkt/avocado-hook/archive/refs/heads/main.zip) and unzip
2. Double-click `install-windows.bat`
3. Restart Claude Code — done! 🎆

---

## Uninstall

**Mac:**
```bash
rm -rf ~/.claude/avocado-hook
```
Then open `~/.claude/settings.json` and remove the `avocado-hook` line. Your backup is at `settings.json.bak`.

**Windows:** Delete `%USERPROFILE%\.claude\avocado-hook\`, then open `%USERPROFILE%\.claude\settings.json` and remove the `avocado-hook` line.

---

## What the installer actually does

Before running any script from the internet, you should know exactly what it touches:

**Mac:**
1. Compiles `fireworks.swift` into a local `.app` using your own `swiftc` — **no pre-built binary downloaded**
2. Copies `avocado.html` to `~/.claude/avocado-hook/`
3. Backs up `~/.claude/settings.json` to `settings.json.bak`
4. Adds one `Stop` hook to `settings.json`
5. Asks for your confirmation before making any changes

**Windows:**
1. Saves a small PowerShell script to `~\.claude\avocado-hook\`
2. Backs up `settings.json` to `settings.json.bak`
3. Adds one `Stop` hook to `settings.json`

---

## How it works

Claude Code supports [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) — shell commands that fire at specific moments. This adds a `Stop` hook that triggers every time Claude finishes responding.
