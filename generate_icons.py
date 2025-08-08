#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path

def generate_icon_sizes():
    """Generate all required app icon sizes from the SVG file."""
    
    # Create assets directory if it doesn't exist
    assets_dir = Path("assets")
    assets_dir.mkdir(exist_ok=True)
    
    # Check if rsvg-convert is available (for SVG to PNG conversion)
    try:
        subprocess.run(["rsvg-convert", "--version"], capture_output=True, check=True)
        converter = "rsvg-convert"
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("rsvg-convert not found. Please install librsvg2-bin:")
        print("  Ubuntu/Debian: sudo apt-get install librsvg2-bin")
        print("  macOS: brew install librsvg")
        print("  Windows: Download from https://github.com/GNOME/librsvg/releases")
        return False
    
    # Icon sizes for different platforms
    android_sizes = {
        "mipmap-mdpi/ic_launcher.png": 48,
        "mipmap-hdpi/ic_launcher.png": 72,
        "mipmap-xhdpi/ic_launcher.png": 96,
        "mipmap-xxhdpi/ic_launcher.png": 144,
        "mipmap-xxxhdpi/ic_launcher.png": 192,
    }
    
    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    
    macos_sizes = {
        "app_icon_16.png": 16,
        "app_icon_32.png": 32,
        "app_icon_64.png": 64,
        "app_icon_128.png": 128,
        "app_icon_256.png": 256,
        "app_icon_512.png": 512,
        "app_icon_1024.png": 1024,
    }
    
    # Generate Android icons
    print("Generating Android icons...")
    for filename, size in android_sizes.items():
        output_path = f"android/app/src/main/res/{filename}"
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        cmd = [
            converter,
            "-w", str(size),
            "-h", str(size),
            "assets/app_icon.svg",
            "-o", output_path
        ]
        subprocess.run(cmd, check=True)
        print(f"  Generated {filename}")
    
    # Generate iOS icons
    print("Generating iOS icons...")
    for filename, size in ios_sizes.items():
        output_path = f"ios/Runner/Assets.xcassets/AppIcon.appiconset/{filename}"
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        cmd = [
            converter,
            "-w", str(size),
            "-h", str(size),
            "assets/app_icon.svg",
            "-o", output_path
        ]
        subprocess.run(cmd, check=True)
        print(f"  Generated {filename}")
    
    # Generate macOS icons
    print("Generating macOS icons...")
    for filename, size in macos_sizes.items():
        output_path = f"macos/Runner/Assets.xcassets/AppIcon.appiconset/{filename}"
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        cmd = [
            converter,
            "-w", str(size),
            "-h", str(size),
            "assets/app_icon.svg",
            "-o", output_path
        ]
        subprocess.run(cmd, check=True)
        print(f"  Generated {filename}")
    
    print("\n✅ All app icons generated successfully!")
    print("\nNext steps:")
    print("1. Run: flutter clean")
    print("2. Run: flutter pub get")
    print("3. Rebuild your app to see the new icons")
    
    return True

if __name__ == "__main__":
    generate_icon_sizes()
