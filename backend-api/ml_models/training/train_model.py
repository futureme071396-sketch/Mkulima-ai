
import os
import zipfile
import json
import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report

# Import utility functions from data_preprocessing.py
# When train_model.py is executed, its directory is automatically added to sys.path,
# so a direct import of data_preprocessing will work.
from data_preprocessing import unzip_dataset, load_image_dataset, get_rescaling_layer, apply_preprocessing

# 3. Define the base path for your project and the dataset path
BASE_PATH = '/content/drive/My Drive/backend'
DATASET_ZIP_PATH = '/content/archive.zip'
DATASET_EXTRACT_PATH = '/content/dataset'
MODEL_SAVE_PATH = os.path.join(BASE_PATH, 'ml_models', 'trained_models', 'plant_disease_model.h5')
LABELS_SAVE_PATH = os.path.join(BASE_PATH, 'knowledge_base', 'disease_labels.txt')
METRICS_SAVE_PATH = os.path.join(BASE_PATH, 'ml_models', 'trained_models', 'training_metrics.json')

if __name__ == '__main__':
    # 4. Set a reproducible random seed
    SEED = 123
    np.random.seed(SEED)
    tf.random.set_seed(SEED)

    print("Starting plant disease model training...")
    # 5. Call the unzip_dataset function to extract the dataset
    unzip_dataset(DATASET_ZIP_PATH, DATASET_EXTRACT_PATH)

    # 6. Load the image dataset
    IMAGE_SIZE = (224, 224)
    BATCH_SIZE = 32

    full_dataset = load_image_dataset(
        DATASET_EXTRACT_PATH,
        image_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        shuffle=True,
        seed=SEED
    )

    # 7. Determine the number of classes and print class names
    class_names = full_dataset.class_names
    num_classes = len(class_names)
    print(f"Found {num_classes} classes: {class_names}")

    # 8. Split the dataset into training, validation, and test sets (80/10/10 ratio)
    DATASET_SIZE = tf.data.experimental.cardinality(full_dataset).numpy()
    train_size = int(0.8 * DATASET_SIZE)
    val_size = int(0.1 * DATASET_SIZE)
    test_size = DATASET_SIZE - train_size - val_size

    train_dataset = full_dataset.take(train_size)
    val_dataset = full_dataset.skip(train_size).take(val_size)
    test_dataset = full_dataset.skip(train_size + val_size).take(test_size)

    print(f"Dataset split: Train batches={tf.data.experimental.cardinality(train_dataset).numpy()}, "
          f"Validation batches={tf.data.experimental.cardinality(val_dataset).numpy()}, "
          f"Test batches={tf.data.experimental.cardinality(test_dataset).numpy()}")

    # 9. Apply image preprocessing (rescaling) to all datasets
    rescale_layer = get_rescaling_layer()

    train_dataset = apply_preprocessing(train_dataset, rescale_layer)
    val_dataset = apply_preprocessing(val_dataset, rescale_layer)
    test_dataset = apply_preprocessing(test_dataset, rescale_layer)

    # 10. Implement data augmentation
    data_augmentation = tf.keras.Sequential([
        tf.keras.layers.RandomRotation(factor=0.1, seed=SEED),
        tf.keras.layers.RandomFlip("horizontal_and_vertical", seed=SEED),
        tf.keras.layers.RandomZoom(height_factor=0.2, width_factor=0.2, seed=SEED),
        tf.keras.layers.RandomBrightness(factor=0.2, value_range=(0.0, 1.0), seed=SEED)
    ], name="data_augmentation")

    # 11. Build the MobileNetV2 model
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=IMAGE_SIZE + (3,),
        include_top=False,
        weights='imagenet',
        alpha=1.0 # tunable parameter
    )

    # Freeze the layers of the base MobileNetV2 model
    base_model.trainable = False

    # 12. Create a tf.keras.Sequential model for the classification head
    classification_head = tf.keras.Sequential([
        tf.keras.layers.GlobalAveragePooling2D(),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.2, seed=SEED),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dropout(0.2, seed=SEED),
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ], name="classification_head")

    # 13. Combine the base model, data augmentation, and classification head
    model = tf.keras.Sequential([
        data_augmentation,
        base_model,
        classification_head
    ], name="plant_disease_classifier")

    # 14. Compile the model
    model.compile(
        optimizer=tf.keras.optimizers.Adam(),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(), # Use SparseCategoricalCrossentropy for integer labels
        metrics=['accuracy']
    )
    model.summary()

    # 15. Define callbacks for training
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            patience=10,
            restore_best_weights=True,
            monitor='val_accuracy'
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=MODEL_SAVE_PATH,
            save_best_only=True,
            monitor='val_accuracy',
            mode='max',
            verbose=1
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_accuracy',
            factor=0.2,
            patience=5,
            min_lr=0.00001,
            verbose=1
        )
    ]

    # 16. Train the model
    EPOCHS = 50 # You can adjust the number of epochs
    print(f"Training model for {EPOCHS} epochs...")
    history = model.fit(
        train_dataset,
        validation_data=val_dataset,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )

    # 17. Evaluate the trained model on the test dataset
    print("Evaluating model on test dataset...")
    test_loss, test_accuracy = model.evaluate(test_dataset, verbose=1)
    print(f"Test Loss: {test_loss:.4f}")
    print(f"Test Accuracy: {test_accuracy:.4f}")

    # 18. Save the class labels
    print(f"Saving class labels to {LABELS_SAVE_PATH}...")
    with open(LABELS_SAVE_PATH, 'w') as f:
        for class_name in class_names:
            f.write(f"{class_name}
")
    print("Class labels saved.")

    # 19. Calculate and save per-class metrics
    print("Calculating per-class metrics...")
    # To get predictions and true labels for classification report
    all_test_labels = []
    all_test_predictions = []

    for images, labels in test_dataset.unbatch():
        all_test_labels.append(labels.numpy())
        # Expand dimensions to mimic batch size 1 for prediction
        # Ensure the image is preprocessed before prediction, similar to model input
        preprocessed_image = rescale_layer(tf.expand_dims(images, 0))
        pred = model.predict(preprocessed_image, verbose=0)
        all_test_predictions.append(np.argmax(pred, axis=1)[0])

    true_labels = np.array(all_test_labels)
    predicted_labels = np.array(all_test_predictions)

    report = classification_report(true_labels, predicted_labels, target_names=class_names, output_dict=True)

    print(f"Saving training metrics to {METRICS_SAVE_SAVE_PATH}...")
    with open(METRICS_SAVE_PATH, 'w') as f:
        json.dump(report, f, indent=4)
    print("Training metrics saved.")

    print("Model training and evaluation complete.")
