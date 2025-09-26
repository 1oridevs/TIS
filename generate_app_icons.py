#!/usr/bin/env python3
"""
TIS App Icon Generator
Generates app icons for all required sizes using a simple design.
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon(size, filename):
    """Create an app icon with the specified size."""
    # Create a new image with a blue background
    img = Image.new('RGBA', (size, size), (0, 100, 200, 255))
    draw = ImageDraw.Draw(img)
    
    # Create a white circle in the center
    margin = size // 8
    circle_bbox = [margin, margin, size - margin, size - margin]
    draw.ellipse(circle_bbox, fill=(255, 255, 255, 255))
    
    # Add a clock icon in the center
    clock_size = size // 3
    clock_x = size // 2 - clock_size // 2
    clock_y = size // 2 - clock_size // 2
    
    # Draw clock face
    clock_bbox = [clock_x, clock_y, clock_x + clock_size, clock_y + clock_size]
    draw.ellipse(clock_bbox, outline=(0, 100, 200, 255), width=3)
    
    # Draw clock hands
    center_x = size // 2
    center_y = size // 2
    hand_length = clock_size // 3
    
    # Hour hand
    draw.line([center_x, center_y, center_x, center_y - hand_length], 
              fill=(0, 100, 200, 255), width=3)
    
    # Minute hand
    draw.line([center_x, center_y, center_x + hand_length, center_y], 
              fill=(0, 100, 200, 255), width=2)
    
    # Save the image
    img.save(filename, 'PNG')
    print(f"Generated {filename} ({size}x{size})")

def main():
    """Generate all required app icon sizes."""
    # Create the AppIcon.appiconset directory
    icon_dir = "TIS/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(icon_dir, exist_ok=True)
    
    # Define all required sizes
    sizes = [
        (20, "appicon-20.png"),
        (29, "appicon-29.png"),
        (40, "appicon-40.png"),
        (58, "appicon-58.png"),
        (60, "appicon-60.png"),
        (76, "appicon-76.png"),
        (80, "appicon-80.png"),
        (87, "appicon-87.png"),
        (120, "appicon-120.png"),
        (152, "appicon-152.png"),
        (167, "appicon-167.png"),
        (180, "appicon-180.png"),
        (1024, "appicon-1024.png")
    ]
    
    # Generate all icons
    for size, filename in sizes:
        filepath = os.path.join(icon_dir, filename)
        create_app_icon(size, filepath)
    
    print("\n✅ All app icons generated successfully!")
    print("📱 Icons are ready for use in the TIS app.")

if __name__ == "__main__":
    main()
