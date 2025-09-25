#!/usr/bin/env python3
"""
TIS App Icon Generator
Generates app icons for all required sizes
"""

import os
import json
from PIL import Image, ImageDraw, ImageFont
import math

# Icon sizes and their specifications
ICON_SIZES = [
    {"name": "appicon-1024", "size": 1024, "scale": "1x", "idiom": "ios-marketing"},
    {"name": "appicon-180", "size": 180, "scale": "3x", "idiom": "iphone"},
    {"name": "appicon-120", "size": 120, "scale": "2x", "idiom": "iphone"},
    {"name": "appicon-167", "size": 167, "scale": "2x", "idiom": "ipad"},
    {"name": "appicon-152", "size": 152, "scale": "2x", "idiom": "ipad"},
    {"name": "appicon-76", "size": 76, "scale": "1x", "idiom": "ipad"},
    {"name": "appicon-40", "size": 40, "scale": "2x", "idiom": "iphone"},
    {"name": "appicon-29", "size": 29, "scale": "1x", "idiom": "iphone"},
    {"name": "appicon-20", "size": 20, "scale": "1x", "idiom": "iphone"}
]

# Color scheme (matching TIS app colors)
PRIMARY_COLOR = (52, 152, 219)  # Blue
SUCCESS_COLOR = (46, 204, 113)  # Green
WARNING_COLOR = (241, 196, 15)  # Yellow
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

def create_gradient_background(size, color1, color2):
    """Create a gradient background"""
    image = Image.new('RGB', (size, size), color1)
    draw = ImageDraw.Draw(image)
    
    # Create gradient effect
    for y in range(size):
        ratio = y / size
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    return image

def draw_clock_face(draw, center, radius, size):
    """Draw a clock face"""
    # Outer circle
    draw.ellipse([center[0] - radius, center[1] - radius, 
                  center[0] + radius, center[1] + radius], 
                 outline=WHITE, width=max(2, size // 128))
    
    # Inner circle
    inner_radius = int(radius * 0.8)
    draw.ellipse([center[0] - inner_radius, center[1] - inner_radius, 
                  center[0] + inner_radius, center[1] + inner_radius], 
                 fill=(*WHITE, 30))
    
    # Clock hands
    hand_width = max(2, size // 128)
    hour_hand_length = int(radius * 0.4)
    minute_hand_length = int(radius * 0.6)
    
    # Hour hand (pointing to 3 o'clock)
    hour_end_x = center[0] + int(hour_hand_length * math.cos(math.radians(0)))
    hour_end_y = center[1] + int(hour_hand_length * math.sin(math.radians(0)))
    draw.line([center[0], center[1], hour_end_x, hour_end_y], 
              fill=WHITE, width=hand_width)
    
    # Minute hand (pointing to 3 o'clock)
    minute_end_x = center[0] + int(minute_hand_length * math.cos(math.radians(0)))
    minute_end_y = center[1] + int(minute_hand_length * math.sin(math.radians(0)))
    draw.line([center[0], center[1], minute_end_x, minute_end_y], 
              fill=WHITE, width=hand_width)
    
    # Center dot
    dot_radius = max(2, size // 64)
    draw.ellipse([center[0] - dot_radius, center[1] - dot_radius, 
                  center[0] + dot_radius, center[1] + dot_radius], 
                 fill=WHITE)

def draw_currency_symbol(draw, center, size):
    """Draw a currency symbol"""
    # Dollar sign
    font_size = max(12, size // 8)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    # Position the dollar sign in bottom right
    text_x = center[0] + size // 4
    text_y = center[1] + size // 4
    
    # Add shadow
    draw.text((text_x + 2, text_y + 2), "$", font=font, fill=BLACK)
    draw.text((text_x, text_y), "$", font=font, fill=SUCCESS_COLOR)

def generate_icon(size):
    """Generate an app icon of the specified size"""
    # Create gradient background
    image = create_gradient_background(size, PRIMARY_COLOR, 
                                     (PRIMARY_COLOR[0] - 20, PRIMARY_COLOR[1] - 20, PRIMARY_COLOR[2] - 20))
    draw = ImageDraw.Draw(image)
    
    # Draw clock face
    center = (size // 2, size // 2)
    clock_radius = size // 3
    draw_clock_face(draw, center, clock_radius, size)
    
    # Draw currency symbol
    draw_currency_symbol(draw, center, size)
    
    return image

def main():
    """Generate all app icons"""
    # Create output directory
    output_dir = "TIS/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)
    
    print("Generating TIS app icons...")
    
    # Generate each icon size
    for icon_spec in ICON_SIZES:
        size = icon_spec["size"]
        filename = f"{icon_spec['name']}.png"
        filepath = os.path.join(output_dir, filename)
        
        print(f"Generating {filename} ({size}x{size})...")
        
        # Generate the icon
        icon = generate_icon(size)
        
        # Save the icon
        icon.save(filepath, "PNG")
        print(f"Saved {filepath}")
    
    # Update Contents.json
    contents = {
        "images": [
            {
                "filename": f"{spec['name']}.png",
                "idiom": spec["idiom"],
                "platform": "ios",
                "size": f"{spec['size']}x{spec['size']}" if spec["idiom"] == "ios-marketing" else f"{spec['size']//2}x{spec['size']//2}",
                "scale": spec["scale"] if spec["idiom"] != "ios-marketing" else None
            }
            for spec in ICON_SIZES
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    # Remove None values
    for image in contents["images"]:
        if image.get("scale") is None:
            del image["scale"]
    
    # Write Contents.json
    contents_path = os.path.join(output_dir, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    
    print(f"Updated {contents_path}")
    print("App icon generation complete!")

if __name__ == "__main__":
    main()
