#!/usr/bin/env python3
from PIL import Image
import os

def create_macos_icons():
    """Create macOS app icons from the main icon."""
    
    # macOS icon sizes
    macos_sizes = {
        "app_icon_16.png": 16,
        "app_icon_32.png": 32,
        "app_icon_64.png": 64,
        "app_icon_128.png": 128,
        "app_icon_256.png": 256,
        "app_icon_512.png": 512,
        "app_icon_1024.png": 1024,
    }
    
    # Load the main icon
    try:
        main_icon = Image.open("assets/app_icon.png")
        print("✅ Loaded main icon: assets/app_icon.png")
    except Exception as e:
        print(f"❌ Error loading main icon: {e}")
        return False
    
    # Create macOS icons directory
    macos_icon_dir = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(macos_icon_dir, exist_ok=True)
    
    # Generate each size
    for filename, size in macos_sizes.items():
        output_path = os.path.join(macos_icon_dir, filename)
        
        # Resize the icon
        resized_icon = main_icon.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save the icon
        resized_icon.save(output_path, "PNG")
        print(f"  Generated {filename} ({size}x{size})")
    
    print("✅ All macOS icons generated successfully!")
    return True

if __name__ == "__main__":
    create_macos_icons()
