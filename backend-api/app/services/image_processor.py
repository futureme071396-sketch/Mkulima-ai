# backend-api/app/services/image_processor.py
from PIL import Image
import numpy as np
import io

class ImageProcessor:
    def __init__(self):
        self.target_size = (224, 224)  # Standard size for most models
    
    def preprocess(self, image_file):
        """
        Preprocess uploaded image for AI model
        """
        try:
            # Read image file
            image = Image.open(image_file.stream)
            
            # Convert to RGB if necessary
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Resize image
            image = image.resize(self.target_size, Image.Resampling.LANCZOS)
            
            # Convert to numpy array
            image_array = np.array(image)
            
            # Normalize pixel values to [0, 1]
            image_array = image_array / 255.0
            
            # Add batch dimension
            image_array = np.expand_dims(image_array, axis=0)
            
            return image_array
            
        except Exception as e:
            raise Exception(f"Image processing failed: {str(e)}")
    
    def validate_image(self, image_file):
        """
        Validate image file
        """
        try:
            image = Image.open(image_file.stream)
            
            # Check image dimensions
            if image.size[0] < 100 or image.size[1] < 100:
                return "Image too small. Minimum size is 100x100 pixels."
            
            # Check file size (approximately)
            image_file.stream.seek(0, 2)  # Seek to end
            file_size = image_file.stream.tell()
            image_file.stream.seek(0)  # Reset stream position
            
            if file_size > 10 * 1024 * 1024:  # 10MB
                return "Image too large. Maximum size is 10MB."
            
            return None
            
        except Exception as e:
            return f"Invalid image file: {str(e)}"
