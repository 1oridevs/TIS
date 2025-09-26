#!/usr/bin/env python3
"""
Generate TIS app icons using Python PIL
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_gradient_background(size, color1=(59, 130, 246), color2=(99, 102, 241)):
    """Create a gradient background"""
    img = Image.new('RGB', size, color1)
    draw = ImageDraw.Draw(img)
    
    # Simple gradient effect
    for y in range(size[1]):
        ratio = y / size[1]
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        draw.line([(0, y), (size[0], y)], fill=(r, g, b))
    
    return img

def draw_clock_icon(img, size):
    """Draw a clock icon on the image"""
    draw = ImageDraw.Draw(img)
    center = (size[0] // 2, size[1] // 2)
    clock_radius = min(size) * 0.3
    
    # Clock face
    clock_rect = [
        center[0] - clock_radius,
        center[1] - clock_radius,
        center[0] + clock_radius,
        center[1] + clock_radius
    ]
    
    # Draw clock face
    draw.ellipse(clock_rect, fill=(255, 255, 255, 230), outline=(255, 255, 255, 255), width=max(1, size[0] // 40))
    
    # Clock hands
    hand_length = clock_radius * 0.7
    hand_width = max(1, size[0] // 20)
    
    # Hour hand (pointing to 3 o'clock)
    hour_end = (center[0] + hand_length * 0.6, center[1])
    draw.line([center, hour_end], fill=(59, 130, 246), width=hand_width)
    
    # Minute hand (pointing to 12 o'clock)
    minute_end = (center[0], center[1] - hand_length)
    draw.line([center, minute_end], fill=(99, 102, 241), width=hand_width-1)
    
    # Center dot
    dot_radius = max(1, size[0] // 30)
    draw.ellipse([
        center[0] - dot_radius,
        center[1] - dot_radius,
        center[0] + dot_radius,
        center[1] + dot_radius
    ], fill=(59, 130, 246))

def generate_app_icon(size, output_path):
    """Generate an app icon of the specified size"""
    img = create_gradient_background(size)
    draw_clock_icon(img, size)
    
    # Save the image
    img.save(output_path, 'PNG', optimize=True)
    print(f"Generated {output_path} ({size[0]}x{size[1]})")

def main():
    """Generate all required app icon sizes"""
    # Define all required sizes
    sizes = [
        ("appicon-20", 20),
        ("appicon-29", 29),
        ("appicon-40", 40),
        ("appicon-58", 58),
        ("appicon-60", 60),
        ("appicon-76", 76),
        ("appicon-80", 80),
        ("appicon-87", 87),
        ("appicon-120", 120),
        ("appicon-152", 152),
        ("appicon-167", 167),
        ("appicon-180", 180),
        ("appicon-1024", 1024)
    ]
    
    # Output directory
    output_dir = "TIS/Assets.xcassets/AppIcon.appiconset"
    
    # Generate each size
    for name, size in sizes:
        output_path = os.path.join(output_dir, f"{name}.png")
        generate_app_icon((size, size), output_path)
    
    print("All app icons generated successfully!")

if __name__ == "__main__":
    main()