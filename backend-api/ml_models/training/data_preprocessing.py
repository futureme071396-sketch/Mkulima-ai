
import os
import zipfile
import numpy as np
import tensorflow as tf

BASE_PATH = '/content/drive/My Drive/backend'
DATASET_ZIP_PATH = '/content/archive.zip'
DATASET_EXTRACT_PATH = '/content/dataset'

def unzip_dataset(zip_path, extract_path):
    if not os.path.exists(extract_path):
        print(f"Unzipping {zip_path} to {extract_path}...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_path)
        print("Dataset unzipped successfully.")
    else:
        print(f"Dataset already exists at {extract_path}. Skipping unzipping.")

def load_image_dataset(dataset_path, image_size, batch_size, shuffle, seed):
    print(f"Loading dataset from {dataset_path}...")
    dataset = tf.keras.utils.image_dataset_from_directory(
        dataset_path,
        labels='inferred',
        label_mode='int',
        image_size=image_size,
        interpolation='nearest',
        batch_size=batch_size,
        shuffle=shuffle,
        seed=seed
    )
    print("Dataset loaded successfully.")
    return dataset

def get_rescaling_layer():
    return tf.keras.layers.Rescaling(1./255)

def apply_preprocessing(dataset, rescale_layer):
    AUTOTUNE = tf.data.AUTOTUNE
    def preprocess(image, label):
        return rescale_layer(image), label
    dataset = dataset.map(preprocess).cache().prefetch(buffer_size=AUTOTUNE)
    return dataset

if __name__ == '__main__':
    # Example usage (for testing purposes, not part of the main script execution flow)
    # This part will be executed only when data_preprocessing.py is run directly.
    SEED = 123
    np.random.seed(SEED)
    tf.random.set_seed(SEED)

    unzip_dataset(DATASET_ZIP_PATH, DATASET_EXTRACT_PATH)

    IMAGE_SIZE = (224, 224)
    BATCH_SIZE = 32

    full_dataset = load_image_dataset(DATASET_EXTRACT_PATH, IMAGE_SIZE, BATCH_SIZE, shuffle=True, seed=SEED)
    rescale_layer = get_rescaling_layer()
    preprocessed_dataset = apply_preprocessing(full_dataset, rescale_layer)

    print("Data preprocessing utilities successfully created and tested.")
