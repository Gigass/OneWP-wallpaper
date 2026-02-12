#!/bin/bash
set -e

# DMG 打包脚本 - 将 OneWP 打包为 macOS .dmg 分发包

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="OneWP"
BUNDLE_ID="com.cosmicflow.wallpaper"
VERSION="1.0.0"

BUILD_DIR="$PROJECT_ROOT/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"

echo "🚀 开始构建 $APP_NAME DMG..."

# 清理旧的构建产物
echo "🧹 清理旧构建..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 1. 编译 Release 版本
echo "🔨 编译 Release 版本..."
cd "$PROJECT_ROOT"
swift build -c release

# 2. 生成 .icns 图标
echo "🎨 生成应用图标..."
ICON_SRC="$PROJECT_ROOT/icon.png"
ICONSET_DIR="$BUILD_DIR/AppIcon.iconset"

if [ -f "$ICON_SRC" ]; then
    mkdir -p "$ICONSET_DIR"
    sips -z 16 16     "$ICON_SRC" --out "$ICONSET_DIR/icon_16x16.png"      > /dev/null
    sips -z 32 32     "$ICON_SRC" --out "$ICONSET_DIR/icon_16x16@2x.png"   > /dev/null
    sips -z 32 32     "$ICON_SRC" --out "$ICONSET_DIR/icon_32x32.png"      > /dev/null
    sips -z 64 64     "$ICON_SRC" --out "$ICONSET_DIR/icon_32x32@2x.png"   > /dev/null
    sips -z 128 128   "$ICON_SRC" --out "$ICONSET_DIR/icon_128x128.png"    > /dev/null
    sips -z 256 256   "$ICON_SRC" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
    sips -z 256 256   "$ICON_SRC" --out "$ICONSET_DIR/icon_256x256.png"    > /dev/null
    sips -z 512 512   "$ICON_SRC" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
    sips -z 512 512   "$ICON_SRC" --out "$ICONSET_DIR/icon_512x512.png"    > /dev/null
    sips -z 1024 1024 "$ICON_SRC" --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null
    iconutil -c icns "$ICONSET_DIR" -o "$BUILD_DIR/AppIcon.icns"
    rm -rf "$ICONSET_DIR"
else
    echo "⚠️  警告: 未找到 icon.png，跳过图标生成"
fi

# 3. 创建 .app bundle 目录结构
echo "📦 创建 .app bundle..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 4. 复制可执行文件
echo "📋 复制可执行文件..."
cp ".build/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# 5. 复制 SPM 资源 bundle
echo "📋 复制资源 bundle..."
RESOURCE_BUNDLE=".build/release/${APP_NAME}_${APP_NAME}.bundle"
if [ -d "$RESOURCE_BUNDLE" ]; then
    cp -R "$RESOURCE_BUNDLE" "$APP_BUNDLE/Contents/Resources/"
else
    echo "⚠️  警告: 未找到资源 bundle: $RESOURCE_BUNDLE"
fi

# 6. 复制图标
if [ -f "$BUILD_DIR/AppIcon.icns" ]; then
    cp "$BUILD_DIR/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# 7. 复制 Info.plist
echo "📋 复制 Info.plist..."
cp "Sources/$APP_NAME/Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# 8. 创建 PkgInfo
echo "📋 创建 PkgInfo..."
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

# 9. 设置可执行权限
echo "🔐 设置权限..."
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# 10. Ad-hoc 签名
echo "✍️  签名 app bundle..."
codesign --deep --force --sign - "$APP_BUNDLE"

# 11. 创建临时 DMG 挂载目录
echo "💿 创建 DMG..."
TMP_DMG_DIR="$BUILD_DIR/dmg_tmp"
mkdir -p "$TMP_DMG_DIR"

# 复制 app 到临时目录
cp -R "$APP_BUNDLE" "$TMP_DMG_DIR/"

# 创建 /Applications 快捷方式
ln -s /Applications "$TMP_DMG_DIR/Applications"

# 12. 生成 DMG
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$TMP_DMG_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

# 清理临时目录
rm -rf "$TMP_DMG_DIR"

echo "✅ 构建完成!"
echo "📍 DMG 位置: $DMG_PATH"
echo ""
echo "验证命令:"
echo "  open $DMG_PATH"
