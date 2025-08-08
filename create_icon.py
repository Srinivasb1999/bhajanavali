#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    """Create a simple app icon with lotus flower design."""
    
    # Create assets directory
    os.makedirs("assets", exist_ok=True)
    
    # Create a 1024x1024 image with a gradient background
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (orange to yellow)
    for y in range(size):
        r = int(255 * (1 - y/size) + 255 * (y/size))
        g = int(107 * (1 - y/size) + 217 * (y/size))
        b = int(53 * (1 - y/size) + 61 * (y/size))
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # Draw lotus petals
    center_x, center_y = size // 2, size // 2
    
    # Main petal colors
    colors = [
        (255, 255, 255, 230),  # White center
        (139, 92, 246, 200),   # Purple
        (6, 182, 212, 200),    # Cyan
        (16, 185, 129, 200),   # Green
    ]
    
    # Draw petals
    petal_positions = [
        (center_x, center_y, 200, 280, 0),      # Center
        (center_x - 200, center_y, 180, 240, 1), # Left
        (center_x + 200, center_y, 180, 240, 1), # Right
        (center_x, center_y - 200, 240, 180, 2), # Top
        (center_x, center_y + 200, 240, 180, 2), # Bottom
        (center_x - 100, center_y - 100, 200, 200, 3), # Top-left
        (center_x + 100, center_y - 100, 200, 200, 3), # Top-right
        (center_x - 100, center_y + 100, 200, 200, 3), # Bottom-left
        (center_x + 100, center_y + 100, 200, 200, 3), # Bottom-right
    ]
    
    for x, y, w, h, color_idx in petal_positions:
        color = colors[color_idx]
        draw.ellipse([x - w//2, y - h//2, x + w//2, y + h//2], fill=color)
    
    # Draw center circle
    center_radius = 120
    draw.ellipse([
        center_x - center_radius, center_y - center_radius,
        center_x + center_radius, center_y + center_radius
    ], fill=(124, 58, 237, 255))  # Purple
    
    # Draw Om symbol (simplified as a circle with text)
    try:
        # Try to use a system font that supports Devanagari
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 120)
    except:
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 120)
        except:
            font = ImageFont.load_default()
    
    # Draw Om symbol
    om_text = "ॐ"
    bbox = draw.textbbox((0, 0), om_text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    text_x = center_x - text_width // 2
    text_y = center_y - text_height // 2
    draw.text((text_x, text_y), om_text, fill=(255, 255, 255, 255), font=font)
    
    # Draw musical notes in corners
    note_color = (245, 158, 11, 200)  # Orange
    note_positions = [
        (200, 200), (824, 200), (200, 824), (824, 824)
    ]
    
    for x, y in note_positions:
        # Note head
        draw.ellipse([x-15, y-20, x+15, y+20], fill=note_color)
        # Note stem
        draw.rectangle([x+15, y, x+19, y+60], fill=note_color)
        # Note flag
        draw.ellipse([x+19, y+60, x+27, y+66], fill=note_color)
    
    # Save the icon
    img.save("assets/app_icon.png", "PNG")
    print("✅ App icon created: assets/app_icon.png")
    
    return True

if __name__ == "__main__":
    create_app_icon()
