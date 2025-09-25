#!/usr/bin/env python3
"""
Simple TIS App Icon Creator
Creates a basic app icon for the TIS app
"""

from PIL import Image, ImageDraw, ImageFont
import math

def create_tis_icon(size):
    """Create a TIS app icon"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    primary_color = (52, 152, 219, 255)  # Blue
    success_color = (46, 204, 113, 255)  # Green
    white = (255, 255, 255, 255)
    
    # Calculate dimensions
    center = size // 2
    clock_radius = size // 3
    
    # Draw background circle with gradient effect
    for i in range(clock_radius):
        alpha = int(255 * (1 - i / clock_radius))
        color = (primary_color[0], primary_color[1], primary_color[2], alpha)
        draw.ellipse([center - clock_radius + i, center - clock_radius + i,
                      center + clock_radius - i, center + clock_radius - i],
                     fill=color)
    
    # Draw clock face
    draw.ellipse([center - clock_radius, center - clock_radius,
                  center + clock_radius, center + clock_radius],
                 outline=white, width=max(2, size // 64))
    
    # Draw clock hands
    hand_width = max(2, size // 64)
    hour_hand_length = clock_radius // 2
    minute_hand_length = int(clock_radius * 0.7)
    
    # Hour hand (pointing to 3 o'clock)
    hour_end_x = center + int(hour_hand_length * math.cos(0))
    hour_end_y = center + int(hour_hand_length * math.sin(0))
    draw.line([center, center, hour_end_x, hour_end_y], fill=white, width=hand_width)
    
    # Minute hand (pointing to 3 o'clock)
    minute_end_x = center + int(minute_hand_length * math.cos(0))
    minute_end_y = center + int(minute_hand_length * math.sin(0))
    draw.line([center, center, minute_end_x, minute_end_y], fill=white, width=hand_width)
    
    # Center dot
    dot_radius = max(2, size // 32)
    draw.ellipse([center - dot_radius, center - dot_radius,
                  center + dot_radius, center + dot_radius], fill=white)
    
    # Draw dollar sign in bottom right
    try:
        font_size = max(12, size // 8)
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    # Position dollar sign
    text_x = center + size // 4
    text_y = center + size // 4
    
    # Add shadow
    draw.text((text_x + 2, text_y + 2), "$", font=font, fill=(0, 0, 0, 128))
    draw.text((text_x, text_y), "$", font=font, fill=success_color)
    
    return img

def main():
    """Create the app icon"""
    sizes = [20, 29, 40, 60, 76, 120, 152, 167, 180, 1024]
    
    for size in sizes:
        print(f"Creating {size}x{size} icon...")
        icon = create_tis_icon(size)
        icon.save(f"appicon-{size}.png", "PNG")
        print(f"Saved appicon-{size}.png")

if __name__ == "__main__":
    main()
