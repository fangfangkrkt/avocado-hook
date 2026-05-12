#!/bin/bash
set -euo pipefail

echo ""
echo "🥑 Avocado Hook for Claude Code"
echo ""
echo "This script will:"
echo "  • Compile a Swift animation app to ~/.claude/avocado-hook/"
echo "  • Add a Stop hook to ~/.claude/settings.json"
echo "  • Back up your settings.json before modifying it"
echo ""
echo "Review the source at https://github.com/YOUR_USERNAME/avo-hook before continuing."
echo ""
read -r -p "Continue? (y/n) " REPLY
echo ""
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Installation cancelled."
  exit 0
fi

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This only works on macOS, sorry!"
  exit 1
fi

# Check swiftc
if ! command -v swiftc &> /dev/null; then
  echo "❌ Xcode Command Line Tools not found."
  echo "   Run this first: xcode-select --install"
  exit 1
fi

# Check Claude Code
CLAUDE_DIR="$HOME/.claude"
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "❌ ~/.claude not found. Is Claude Code installed?"
  exit 1
fi

# Resolve real script dir (no symlink following)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Create hook directory
HOOK_DIR="$HOME/.claude/avocado-hook"
mkdir -p "$HOOK_DIR"

# Copy assets
cp "$SCRIPT_DIR/avocado.html" "$HOOK_DIR/avocado.html"

# Build app bundle structure
APP_DIR="$HOOK_DIR/Fireworks.app"
mkdir -p "$APP_DIR/Contents/MacOS"

cat > "$APP_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.claude.avocado-hook</string>
    <key>CFBundleName</key>
    <string>Fireworks</string>
    <key>CFBundleExecutable</key>
    <string>fireworks-bin</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Compile Swift binary
echo "⚙️  Compiling animation (~30 seconds)..."
swiftc -O "$SCRIPT_DIR/fireworks.swift" -o "$APP_DIR/Contents/MacOS/fireworks-bin"
xattr -dr com.apple.quarantine "$APP_DIR"
echo "✅ Compiled!"

# Patch settings.json
echo "📝 Adding hook to ~/.claude/settings.json..."
python3 << 'PYEOF'
import json, os, shlex, shutil, tempfile

settings_path = os.path.expanduser('~/.claude/settings.json')
home = os.path.expanduser('~')
app_path = os.path.join(home, '.claude', 'avocado-hook', 'Fireworks.app')

try:
    with open(settings_path) as f:
        settings = json.load(f)
except FileNotFoundError:
    settings = {}
except json.JSONDecodeError as e:
    print(f"❌ ~/.claude/settings.json is not valid JSON: {e}")
    print("   Please fix it manually before re-running.")
    raise SystemExit(1)

new_hook = {
    "type": "command",
    "command": (
        "osascript "
        "-e 'display notification \"Claude has finished\" with title \"Claude Code\"' "
        "-e 'tell application \"Claude\" to activate'; "
        f"afplay /System/Library/Sounds/Purr.aiff -v 3 & "
        f"open {shlex.quote(app_path)} &"
    ),
    "timeout": 5
}

hooks = settings.setdefault('hooks', {})
if not isinstance(hooks, dict):
    hooks = {}
    settings['hooks'] = hooks

stop_hooks = hooks.setdefault('Stop', [])
if not isinstance(stop_hooks, list):
    stop_hooks = []
    hooks['Stop'] = stop_hooks

for group in stop_hooks:
    for h in group.get('hooks', []):
        if 'avocado-hook' in h.get('command', ''):
            print("✅ Hook already installed, nothing to do!")
            raise SystemExit(0)

for group in stop_hooks:
    if group.get('matcher') == '':
        group.setdefault('hooks', []).append(new_hook)
        break
else:
    stop_hooks.append({"matcher": "", "hooks": [new_hook]})

# Back up before writing
if os.path.exists(settings_path):
    shutil.copy2(settings_path, settings_path + '.bak')

# Atomic write: temp file then rename
tmp_fd, tmp_path = tempfile.mkstemp(dir=os.path.dirname(settings_path))
try:
    with os.fdopen(tmp_fd, 'w') as f:
        json.dump(settings, f, indent=2)
    os.replace(tmp_path, settings_path)
except Exception:
    os.unlink(tmp_path)
    raise

print("✅ Hook added! (backup saved to settings.json.bak)")
PYEOF

echo ""
echo "🎉 All done! Avocados will rain down every time Claude finishes."
echo "   Move the Claude window aside to see them! 🥑🥑🥑"
echo ""
