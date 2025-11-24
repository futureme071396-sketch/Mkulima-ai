# backend-api/app/utils/helpers.py
import os
from werkzeug.utils import secure_filename

def allowed_file(filename):
    """
    Check if file extension is allowed
    """
    allowed_extensions = {'png', 'jpg', 'jpeg', 'gif'}
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in allowed_extensions

def validate_image(image_file):
    """
    Validate uploaded image
    """
    if not allowed_file(image_file.filename):
        return "Invalid file type. Only PNG, JPG, JPEG, GIF allowed."
    
    # Check file size
    image_file.stream.seek(0, 2)  # Seek to end
    file_size = image_file.stream.tell()
    image_file.stream.seek(0)  # Reset stream position
    
    if file_size > 10 * 1024 * 1024:  # 10MB
        return "File too large. Maximum size is 10MB."
    
    if file_size == 0:
        return "File is empty."
    
    return None

def save_uploaded_file(file, upload_folder):
    """
    Save uploaded file securely
    """
    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)
    
    filename = secure_filename(file.filename)
    file_path = os.path.join(upload_folder, filename)
    file.save(file_path)
    
    return file_path
