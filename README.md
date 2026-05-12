# 🥑 Avocado Hook for Claude Code

Make kawaii avocados rain down your screen every time Claude finishes a task.

![avocado confetti demo](demo.gif)

---

## Requirements

- Mac (macOS 12 or later)
- [Claude Code](https://claude.ai/code) installed
- Xcode Command Line Tools (free — see step 1 below)

---

## Install (3 steps)

### Step 1 — Install Xcode Command Line Tools
Open **Terminal** and run:
```bash
xcode-select --install
```
A popup will appear — click **Install**. Takes a few minutes. Skip this if you've done it before.

### Step 2 — Clone this repo
```bash
git clone https://github.com/fangfangkrkt/avo-hook.git
cd avo-hook
```

### Step 3 — Run the installer
```bash
chmod +x install.sh
./install.sh
```

The script will ask for confirmation, compile the animation, and add the hook. That's it 🥑

---

## If macOS blocks the app

On first run, macOS might show *"cannot be opened because the developer cannot be verified."*
The installer handles this automatically. If you ever see it anyway, run:
```bash
xattr -dr com.apple.quarantine ~/.claude/avocado-hook/Fireworks.app
```
Then try again.

---

## Uninstall

```bash
rm -rf ~/.claude/avocado-hook
```
Then open `~/.claude/settings.json` and remove the `avocado-hook` line. Your backup is at `settings.json.bak`.

---

## What the installer actually does

Before running any script from the internet, you should know exactly what it touches:

1. Compiles `fireworks.swift` into a local `.app` using your own `swiftc` — **no pre-built binary downloaded**
2. Copies `avocado.html` to `~/.claude/avocado-hook/`
3. **Backs up** `~/.claude/settings.json` to `settings.json.bak`
4. Adds one `Stop` hook to `settings.json` that runs `osascript` (notification), `afplay` (sound), and `open` (the animation)
5. Asks for your **confirmation** before making any changes

The animation has no network access and no external dependencies — pure SVG/CSS in a sandboxed WebKit view.

---

## How it works

Claude Code supports [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) — shell commands that fire at specific moments. This adds a `Stop` hook that triggers every time Claude finishes responding.

macOS only. No Windows support planned.
