"""
File Watcher for XShot

This module handles watching directories for new files.
"""

import os
import time
import mimetypes
from typing import Dict, Any, List, Callable, Optional
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileCreatedEvent
from PIL import Image

class ScreenshotHandler(FileSystemEventHandler):
    """
    Event handler for new screenshot files.
    """
    
    def __init__(self, patterns: List[str], callback: Callable[[str], None]):
        """
        Initialize the screenshot handler.
        
        Args:
            patterns: List of file patterns to watch for
            callback: Function to call when a new file is detected
        """
        self.patterns = patterns
        self.callback = callback
        self.last_processed = set()
        
        # Supported image MIME types for validation (expanded list)
        self.supported_mime_types = {
            'image/png', 'image/jpeg', 'image/jpg', 'image/webp',
            'image/bmp', 'image/x-ms-bmp', 'image/tiff', 'image/gif', 
            'image/ico', 'image/x-icon', 'image/vnd.microsoft.icon',
            'image/svg+xml'
        }
        
        # Supported file extensions (fallback when MIME type fails)
        self.supported_extensions = {
            '.png', '.jpg', '.jpeg', '.webp', '.bmp', '.tiff', '.tif',
            '.gif', '.ico', '.svg'
        }
    
    def on_created(self, event):
        """
        Handle file creation events.
        
        Args:
            event: File system event
        """
        if not event.is_directory:
            # Ensure file_path is a string (fix type issue)
            file_path = str(event.src_path)
            
            # Check if the file matches any of the patterns  
            if any(Path(file_path).match(pattern) for pattern in self.patterns):
                # Avoid processing the same file multiple times
                if file_path not in self.last_processed:
                    # Wait a moment to ensure the file is fully written
                    time.sleep(2)  # Increased wait time for better file completion
                    
                    # Verify file still exists and is a valid image before processing
                    if os.path.exists(file_path) and os.path.isfile(file_path) and self._is_valid_image_file(file_path):
                        try:
                            # Call the callback with the file path (ensure string)
                            self.callback(str(file_path))
                            print(f"Auto-detected and processing: {os.path.basename(file_path)}")
                            
                            # Add to processed files
                            self.last_processed.add(file_path)
                            
                            # Limit the size of the set to avoid memory issues
                            if len(self.last_processed) > 100:
                                self.last_processed.pop()
                        except Exception as e:
                            print(f"Error processing file {file_path}: {e}")
    
    def _is_valid_image_file(self, file_path: str) -> bool:
        """
        Validate if the file is a valid image file.
        Enhanced validation that supports all image formats including SVG.
        
        Args:
            file_path: Path to the file to validate
            
        Returns:
            True if valid image file, False otherwise
        """
        try:
            # Check file size (allow very small files, only reject empty or huge files)
            file_size = os.path.getsize(file_path)
            if file_size < 10:  # Less than 10 bytes (essentially empty)
                return False
            if file_size > 100 * 1024 * 1024:  # Larger than 100MB (too big)
                return False
            
            # Get file extension
            _, ext = os.path.splitext(file_path.lower())
            
            # Check if extension is supported
            if ext not in self.supported_extensions:
                return False
            
            # Special handling for SVG files
            if ext == '.svg':
                return self._validate_svg_file(file_path)
            
            # For other formats, try PIL validation first
            try:
                with Image.open(file_path) as img:
                    img.verify()  # Verify the image is not corrupted
                    return True
            except Exception:
                # If PIL fails, try content-based validation
                return self._validate_by_content(file_path, ext)
                
        except Exception:
            return False
    
    def _validate_svg_file(self, file_path: str) -> bool:
        """
        Validate SVG files (PIL can't handle SVG, so we use text validation).
        
        Args:
            file_path: Path to the SVG file
            
        Returns:
            True if valid SVG file, False otherwise
        """
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read(4096)  # Read first 4KB to catch larger prolog
                # Check for SVG markers
                content_lower = content.lower()
                return ('<svg' in content_lower or 
                       content_lower.strip().startswith('<?xml') and '<svg' in content_lower)
        except Exception:
            return False
    
    def _validate_by_content(self, file_path: str, ext: str) -> bool:
        """
        Validate image file by content/signature when PIL fails.
        
        Args:
            file_path: Path to the file
            ext: File extension (lowercase)
            
        Returns:
            True if content matches expected format, False otherwise
        """
        try:
            # Read file header for signature checking
            with open(file_path, 'rb') as f:
                header = f.read(16)  # Read first 16 bytes
            
            if not header:
                return False
            
            # Check file signatures based on extension
            if ext in ['.png'] and header.startswith(b'\x89PNG\r\n\x1a\n'):
                return True
            elif ext in ['.jpg', '.jpeg'] and header.startswith(b'\xff\xd8\xff'):
                return True
            elif ext in ['.webp'] and b'RIFF' in header[:4] and b'WEBP' in header[8:12]:
                return True
            elif ext in ['.bmp'] and header.startswith(b'BM'):
                return True
            elif ext in ['.gif'] and (header.startswith(b'GIF87a') or header.startswith(b'GIF89a')):
                return True
            elif ext in ['.tiff', '.tif'] and (header.startswith(b'II*\x00') or header.startswith(b'MM\x00*')):
                return True
            elif ext in ['.ico'] and header.startswith(b'\x00\x00\x01\x00'):
                return True
            
            # STRICT: Reject if no signature matches - no permissive fallback
            return False
            
        except Exception:
            return False

class FileWatcher:
    """
    Watches directories for new files.
    """
    
    def __init__(self, config: Dict[str, Any], callback: Callable[[str], None]):
        """
        Initialize the file watcher.
        
        Args:
            config: Application configuration
            callback: Function to call when a new file is detected
        """
        self.config = config
        self.callback = callback
        self.observer = None
        self.handlers = []
    
    def start(self) -> bool:
        """
        Start watching for new files.
        
        Returns:
            True if started successfully, False otherwise
        """
        if not self.config["auto_detection"]["enabled"]:
            return False
            
        watch_dirs = self.config["auto_detection"]["watch_dirs"]
        patterns = self.config["auto_detection"]["file_patterns"]
        
        if not watch_dirs or not patterns:
            return False
            
        try:
            self.observer = Observer()
            
            # Add handlers for each directory
            for dir_path in watch_dirs:
                dir_path = os.path.expanduser(str(dir_path))  # Ensure string type
                
                # Create directory if it doesn't exist
                try:
                    os.makedirs(dir_path, exist_ok=True)
                except Exception as e:
                    print(f"Warning: Could not create directory {dir_path}: {e}")
                    continue
                
                if os.path.exists(dir_path) and os.path.isdir(dir_path):
                    handler = ScreenshotHandler(patterns, self.callback)
                    self.observer.schedule(handler, dir_path, recursive=True)  # Enable recursive watching
                    self.handlers.append(handler)
                    print(f"Watching directory: {dir_path}")  # Debug output
                else:
                    print(f"Warning: Directory does not exist or is not accessible: {dir_path}")
            
            # Start the observer
            self.observer.start()
            return True
        except Exception as e:
            print(f"Error starting file watcher: {e}")
            return False
    
    def stop(self) -> bool:
        """
        Stop watching for new files.
        
        Returns:
            True if stopped successfully, False otherwise
        """
        if self.observer:
            try:
                self.observer.stop()
                self.observer.join()
                self.observer = None
                self.handlers = []
                return True
            except Exception as e:
                print(f"Error stopping file watcher: {e}")
                return False
        return False
    
    def is_running(self) -> bool:
        """
        Check if the file watcher is running.
        
        Returns:
            True if running, False otherwise
        """
        return self.observer is not None and self.observer.is_alive()
