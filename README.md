# Cosmic Flow

Canvas-based particle flow wallpaper with real-time animation.

## Preview

Open `index.html` in a browser to see the live animation. Click the download button (top-right) to export static wallpapers in various resolutions or download the macOS live wallpaper app.

## OneWP — macOS Live Wallpaper

A native macOS app that renders the Cosmic Flow animation directly on your desktop, behind all windows and icons.

### Build

```bash
# Build DMG
./scripts/build-dmg.sh

# Or just build the executable
swift build -c release
```

### Install

1. Open `build/OneWP.dmg`
2. Drag `OneWP.app` to Applications
3. Launch — the app runs as a menu bar icon (no Dock icon)

Requires macOS 13+.

## License

[MIT](LICENSE)
