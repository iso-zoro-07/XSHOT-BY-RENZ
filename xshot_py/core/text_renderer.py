"""
Advanced text rendering system for XShot.
Handles headers, footers, and custom text elements with comprehensive styling options.
"""

from PIL import Image, ImageDraw, ImageFont, ImageColor
from typing import Dict, Any, List, Tuple, Optional
from datetime import datetime
import os
import platform


class TextRenderer:
    """
    Advanced text rendering system with comprehensive styling and positioning options.
    Supports headers, footers, shadows, outlines, backgrounds, and multiple custom elements.
    """
    
    def __init__(self, config: Dict[str, Any], theme_data: Dict[str, Any]):
        """
        Initialize the text renderer.
        
        Args:
            config: Configuration dictionary
            theme_data: Theme data dictionary
        """
        self.config = config
        self.theme_data = theme_data
        
        # Position mappings for more comprehensive placement options
        self.position_mappings = {
            # Header positions
            "top": "top-center",
            "top-left": "top-left", 
            "top-right": "top-right",
            "top-center": "top-center",
            
            # Footer positions
            "bottom": "bottom-center",
            "bottom-left": "bottom-left",
            "bottom-right": "bottom-right", 
            "bottom-center": "bottom-center",
            
            # Center positions
            "center": "center-center",
            "center-left": "center-left",
            "center-right": "center-right",
            
            # Legacy compatibility
            "center-center": "center-center"
        }
        
        # Font style mappings
        self.font_styles = {
            "normal": {"weight": "normal", "style": "normal"},
            "bold": {"weight": "bold", "style": "normal"},
            "italic": {"weight": "normal", "style": "italic"},
            "bold-italic": {"weight": "bold", "style": "italic"}
        }
    
    def _get_fonts_directory(self) -> str:
        """
        Get fonts directory with enhanced cross-platform support.
        Same method as ImageProcessor for consistency.
        
        Returns:
            Path to fonts directory
        """
        try:
            # Method 1: Try package structure first
            import xshot_py
            package_dir = os.path.dirname(os.path.dirname(xshot_py.__file__))
            fonts_dir = os.path.join(package_dir, "xshot_py", "assets", "fonts")
            if os.path.exists(fonts_dir):
                return fonts_dir
        except ImportError:
            pass
        
        # Method 2: Try relative to current file
        current_dir = os.path.dirname(os.path.abspath(__file__))
        fonts_dir = os.path.join(current_dir, "..", "assets", "fonts")
        fonts_dir = os.path.abspath(fonts_dir)
        if os.path.exists(fonts_dir):
            return fonts_dir
        
        # Method 3: Try relative to main file location
        fonts_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "fonts")
        fonts_dir = os.path.abspath(fonts_dir)
        if os.path.exists(fonts_dir):
            return fonts_dir
        
        # Method 4: Create a default fonts directory in user config
        config_dir = os.path.expanduser("~/.config/xshot/fonts")
        os.makedirs(config_dir, exist_ok=True)
        return config_dir
    
    def _load_font(self, family: str, size: int, style: str = "normal"):
        """
        Load font with enhanced cross-platform support and style options.
        
        Args:
            family: Font family (mono, sans, serif, modern, classic, minimal)
            size: Font size in pixels
            style: Font style (normal, bold, italic, bold-italic)
            
        Returns:
            PIL ImageFont object
        """
        try:
            system = platform.system().lower()
            style_info = self.font_styles.get(style, self.font_styles["normal"])
            
            # Get the proper fonts directory
            fonts_dir = self._get_fonts_directory()
            
            # Enhanced font family mappings with style support
            font_paths = {
                "mono": {
                    "linux": [
                        os.path.join(fonts_dir, "JetBrains Mono Medium Nerd Font Complete.ttf"),
                        os.path.join(fonts_dir, "DejaVuSansMono.ttf"),
                        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
                        "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf",
                        "/usr/share/fonts/TTF/DejaVuSansMono.ttf",
                        "/System/Library/Fonts/Monaco.ttf"
                    ],
                    "darwin": [
                        os.path.join(fonts_dir, "JetBrains Mono Medium Nerd Font Complete.ttf"),
                        os.path.join(fonts_dir, "DejaVuSansMono.ttf"),
                        "/System/Library/Fonts/Monaco.ttf",
                        "/Library/Fonts/JetBrainsMono-Regular.ttf"
                    ],
                    "windows": [
                        os.path.join(fonts_dir, "JetBrains Mono Medium Nerd Font Complete.ttf"),
                        os.path.join(fonts_dir, "DejaVuSansMono.ttf"),
                        "C:/Windows/Fonts/consola.ttf"
                    ]
                },
                "sans": {
                    "linux": [
                        os.path.join(fonts_dir, "DejaVuSans.ttf"),
                        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
                        "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf", 
                        "/usr/share/fonts/TTF/DejaVuSans.ttf"
                    ],
                    "darwin": [
                        os.path.join(fonts_dir, "DejaVuSans.ttf"),
                        "/System/Library/Fonts/Helvetica.ttc"
                    ],
                    "windows": [
                        os.path.join(fonts_dir, "DejaVuSans.ttf"),
                        "C:/Windows/Fonts/arial.ttf"
                    ]
                },
                "serif": {
                    "linux": [
                        os.path.join(fonts_dir, "DejaVuSerif.ttf"),
                        "/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf",
                        "/usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf"
                    ],
                    "darwin": [
                        os.path.join(fonts_dir, "DejaVuSerif.ttf"),
                        "/System/Library/Fonts/Times.ttc"
                    ],
                    "windows": [
                        os.path.join(fonts_dir, "DejaVuSerif.ttf"),
                        "C:/Windows/Fonts/times.ttf"
                    ]
                },
                "modern": {
                    "linux": [os.path.join(fonts_dir, "DejaVuSans.ttf")],
                    "darwin": [os.path.join(fonts_dir, "DejaVuSans.ttf")],
                    "windows": [os.path.join(fonts_dir, "DejaVuSans.ttf")]
                },
                "classic": {
                    "linux": [os.path.join(fonts_dir, "DejaVuSerif.ttf")],
                    "darwin": [os.path.join(fonts_dir, "DejaVuSerif.ttf")],
                    "windows": [os.path.join(fonts_dir, "DejaVuSerif.ttf")]
                },
                "minimal": {
                    "linux": [os.path.join(fonts_dir, "DejaVuSans-ExtraLight.ttf")],
                    "darwin": [os.path.join(fonts_dir, "DejaVuSans-ExtraLight.ttf")],
                    "windows": [os.path.join(fonts_dir, "DejaVuSans-ExtraLight.ttf")]
                }
            }
            
            # Try to load fonts for the specified family and style
            font_list = font_paths.get(family, font_paths["mono"]).get(system, font_paths["mono"]["linux"])
            
            for font_path in font_list:
                try:
                    # Check if font file exists
                    if os.path.exists(font_path):
                        return ImageFont.truetype(font_path, size)
                except (OSError, IOError):
                    continue
            
            # Fallback to system default
            return ImageFont.load_default()
            
        except Exception:
            # Ultimate fallback
            return ImageFont.load_default()
    
    def _get_text_position(self, text: str, font, 
                          position: str, img_width: int, img_height: int, 
                          padding: int = 20) -> Tuple[int, int]:
        """
        Calculate text position based on alignment and image dimensions.
        
        Args:
            text: Text to position
            font: Font object
            position: Position string (e.g., "top-left", "bottom-center")
            img_width: Image width
            img_height: Image height
            padding: Padding from edges
            
        Returns:
            Tuple of (x, y) coordinates
        """
        # Get text dimensions
        bbox = font.getbbox(text)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # Normalize position
        normalized_pos = self.position_mappings.get(position, "bottom-center")
        
        # Calculate coordinates based on position
        if "top" in normalized_pos:
            y = padding
        elif "bottom" in normalized_pos:
            y = img_height - text_height - padding
        else:  # center
            y = (img_height - text_height) // 2
        
        if "left" in normalized_pos:
            x = padding
        elif "right" in normalized_pos:
            x = img_width - text_width - padding
        else:  # center
            x = (img_width - text_width) // 2
        
        return x, y
    
    def _get_color_from_theme(self, key: str) -> str:
        """
        Get color from theme data safely.
        
        Args:
            key: Color key
            
        Returns:
            Color value
        """
        # Default fallback colors
        defaults = {
            "header_bg": "#1E222B",
            "header_fg": "#F8F9FA",
            "footer_bg": "#1E222B",
            "footer_fg": "#F8F9FA",
            "background": "#1E222B",
            "foreground": "#F8F9FA",
            "accent": "#59d6ff",
            "border": "#3d465c",
        }
        
        # Safe dictionary access to prevent KeyError
        ui = self.theme_data.get("ui", {})
        colors = self.theme_data.get("colors", {})
        
        return ui.get(key) or colors.get(key) or defaults.get(key, "#000000")
    
    def _apply_text_effects(self, draw, text: str, position: Tuple[int, int],
                           font, config: Dict[str, Any]) -> None:
        """
        Apply advanced text effects like shadows, outlines, and backgrounds.
        
        Args:
            draw: PIL ImageDraw object
            text: Text to render
            position: Text position (x, y)
            font: Font object
            config: Text configuration
        """
        x, y = position
        
        # Draw background if enabled
        if config.get("background_enabled", False):
            self._draw_text_background(draw, text, position, font, config)
        
        # Draw text shadow if enabled
        if config.get("text_shadow", False):
            shadow_offset = config.get("shadow_offset", [2, 2])
            shadow_color = config.get("shadow_color", "#FFFFFF")
            shadow_x = x + shadow_offset[0]
            shadow_y = y + shadow_offset[1]
            draw.text((shadow_x, shadow_y), text, fill=shadow_color, font=font)
        
        # Draw text outline if enabled
        if config.get("text_outline", False):
            outline_color = config.get("outline_color", "#FFFFFF")
            outline_width = config.get("outline_width", 1)
            
            # Draw outline by drawing text multiple times with offset
            for dx in range(-outline_width, outline_width + 1):
                for dy in range(-outline_width, outline_width + 1):
                    if dx != 0 or dy != 0:
                        draw.text((x + dx, y + dy), text, fill=outline_color, font=font)
        
        # Draw main text
        text_color = config.get("color", "#000000")
        draw.text((x, y), text, fill=text_color, font=font)
    
    def _draw_text_background(self, draw, text: str, position: Tuple[int, int],
                             font, config: Dict[str, Any]) -> None:
        """
        Draw background rectangle behind text.
        
        Args:
            draw: PIL ImageDraw object
            text: Text to draw background for
            position: Text position
            font: Font object
            config: Text configuration
        """
        x, y = position
        
        # Get text dimensions
        bbox = font.getbbox(text)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # Get background settings
        bg_color = config.get("background_color", "#000000")
        bg_opacity = config.get("background_opacity", 128)
        padding = config.get("background_padding", [10, 5])
        
        # Calculate background rectangle
        bg_x1 = x - padding[0]
        bg_y1 = y - padding[1]
        bg_x2 = x + text_width + padding[0]
        bg_y2 = y + text_height + padding[1]
        
        # Convert color with opacity
        if isinstance(bg_color, str) and bg_color.startswith('#'):
            # Convert hex to RGBA
            color_rgb = ImageColor.getrgb(bg_color)
            bg_color_rgba = (*color_rgb, bg_opacity)
        else:
            bg_color_rgba = (*bg_color, bg_opacity) if isinstance(bg_color, tuple) else (0, 0, 0, bg_opacity)
        
        # Draw background rectangle
        draw.rectangle([(bg_x1, bg_y1), (bg_x2, bg_y2)], fill=bg_color_rgba)
        
        # Draw border if enabled
        if config.get("background_border", False):
            border_color = config.get("border_color", "#FFFFFF")
            border_width = config.get("border_width", 1)
            
            for i in range(border_width):
                draw.rectangle([(bg_x1 - i, bg_y1 - i), (bg_x2 + i, bg_y2 + i)], outline=border_color)
    
    def _check_text_bounds(self, x: int, y: int, text: str, font,
                          img_width: int, img_height: int, padding: int = 20) -> Tuple[int, int]:
        """
        Check and adjust text position to ensure it stays within image bounds.
        
        Args:
            x: X coordinate
            y: Y coordinate 
            text: Text string
            font: Font object
            img_width: Image width
            img_height: Image height
            padding: Minimum padding from edges
            
        Returns:
            Adjusted (x, y) coordinates
        """
        # Get text dimensions
        bbox = font.getbbox(text)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # Ensure text doesn't go outside image bounds
        if x < padding:
            x = padding
        elif x + text_width > img_width - padding:
            x = img_width - text_width - padding
        
        if y < padding:
            y = padding
        elif y + text_height > img_height - padding:
            y = img_height - text_height - padding
        
        return max(padding, x), max(padding, y)
    
    def render_header(self, img: Image.Image) -> Image.Image:
        """
        Render header text with advanced styling options.
        
        Args:
            img: PIL Image object
            
        Returns:
            Image with header added
        """
        if not self.config.get("header", {}).get("enabled", False):
            return img
        
        header_config = self.config["header"]
        width, height = img.size
        
        # Create draw object
        draw = ImageDraw.Draw(img)
        
        # Load font with style
        font_family = header_config.get("font_family", "sans")
        font_style = header_config.get("font_style", "normal")
        font_size = header_config.get("size", 22)
        font = self._load_font(font_family, font_size, font_style)
        
        # Get header text
        header_text = header_config.get("text", "XShot Screenshot")
        position = header_config.get("position", "top")
        
        # Calculate position
        text_x, text_y = self._get_text_position(header_text, font, position, width, height)
        
        # Check bounds
        text_x, text_y = self._check_text_bounds(text_x, text_y, header_text, font, width, height)
        
        # Apply text effects with theme color
        header_config_with_theme = header_config.copy()
        header_config_with_theme["color"] = self._get_color_from_theme("header_fg")
        self._apply_text_effects(draw, header_text, (text_x, text_y), font, header_config_with_theme)
        
        # Add timestamp if enabled
        if header_config.get("show_time", False):
            time_text = datetime.now().strftime(header_config.get("time_format", "%a %d.%b.%Y %H:%M"))
            time_font = self._load_font(font_family, header_config.get("time_size", 18), font_style)
            
            # Position time text relative to main header
            time_x, time_y = self._get_text_position(time_text, time_font, position, width, height)
            if "top" in position:
                time_y = text_y + font_size + 5
            else:
                time_y = text_y - header_config.get("time_size", 18) - 5
            
            time_x, time_y = self._check_text_bounds(time_x, time_y, time_text, time_font, width, height)
            self._apply_text_effects(draw, time_text, (time_x, time_y), time_font, header_config_with_theme)
        
        return img
    
    def render_footer(self, img: Image.Image) -> Image.Image:
        """
        Render footer text with advanced styling options.
        
        Args:
            img: PIL Image object
            
        Returns:
            Image with footer added
        """
        if not self.config.get("footer", {}).get("enabled", False):
            return img
        
        footer_config = self.config["footer"]
        width, height = img.size
        
        # Create draw object
        draw = ImageDraw.Draw(img)
        
        # Load font with style
        font_family = footer_config.get("font_family", "mono")
        font_style = footer_config.get("font_style", "normal")
        font_size = footer_config.get("size", 20)
        font = self._load_font(font_family, font_size, font_style)
        
        # Get footer text
        footer_text = footer_config.get("text", "Shot by XShot")
        position = footer_config.get("position", "bottom")
        
        # Calculate position
        text_x, text_y = self._get_text_position(footer_text, font, position, width, height)
        
        # Check bounds
        text_x, text_y = self._check_text_bounds(text_x, text_y, footer_text, font, width, height)
        
        # Apply text effects with theme color
        footer_config_with_theme = footer_config.copy()
        footer_config_with_theme["color"] = self._get_color_from_theme("footer_fg")
        self._apply_text_effects(draw, footer_text, (text_x, text_y), font, footer_config_with_theme)
        
        # Add timestamp if enabled
        if footer_config.get("show_time", False):
            time_text = datetime.now().strftime(footer_config.get("time_format", "%a %d.%b.%Y %H:%M"))
            time_font = self._load_font(font_family, footer_config.get("time_size", 15), font_style)
            
            # Position time text relative to main footer
            time_x, time_y = self._get_text_position(time_text, time_font, position, width, height)
            if "bottom" in position:
                time_y = text_y - footer_config.get("time_size", 15) - 5
            else:
                time_y = text_y + font_size + 5
            
            time_x, time_y = self._check_text_bounds(time_x, time_y, time_text, time_font, width, height)
            self._apply_text_effects(draw, time_text, (time_x, time_y), time_font, footer_config_with_theme)
        
        return img
    
    def render_custom_elements(self, img: Image.Image) -> Image.Image:
        """
        Render custom text elements with individual styling.
        
        Args:
            img: PIL Image object
            
        Returns:
            Image with custom elements added
        """
        # Render custom footer elements
        footer_elements = self.config.get("footer", {}).get("custom_elements", [])
        for element in footer_elements:
            img = self._render_custom_element(img, element)
        
        # Render custom header elements
        header_elements = self.config.get("header", {}).get("custom_elements", [])
        for element in header_elements:
            img = self._render_custom_element(img, element)
        
        return img
    
    def _render_custom_element(self, img: Image.Image, element: Dict[str, Any]) -> Image.Image:
        """
        Render a single custom text element.
        
        Args:
            img: PIL Image object
            element: Element configuration dictionary
            
        Returns:
            Image with custom element added
        """
        if not element.get("enabled", True):
            return img
        
        width, height = img.size
        draw = ImageDraw.Draw(img)
        
        # Load font
        font_family = element.get("font_family", "mono")
        font_style = element.get("font_style", "normal")
        font_size = element.get("size", 16)
        font = self._load_font(font_family, font_size, font_style)
        
        # Get text and position
        text = element.get("text", "Custom Text")
        position = element.get("position", "center")
        
        # Calculate position
        text_x, text_y = self._get_text_position(text, font, position, width, height)
        
        # Apply manual offset if specified
        offset = element.get("offset", [0, 0])
        text_x += offset[0]
        text_y += offset[1]
        
        # Check bounds
        text_x, text_y = self._check_text_bounds(text_x, text_y, text, font, width, height)
        
        # Apply text effects
        self._apply_text_effects(draw, text, (text_x, text_y), font, element)
        
        return img
    
    def render_all_text(self, img: Image.Image) -> Image.Image:
        """
        Render all text elements (header, footer, custom) on the image.
        
        Args:
            img: PIL Image object
            
        Returns:
            Image with all text elements added
        """
        # Render in order: header -> custom elements -> footer
        img = self.render_header(img)
        img = self.render_custom_elements(img)
        img = self.render_footer(img)
        
        return img