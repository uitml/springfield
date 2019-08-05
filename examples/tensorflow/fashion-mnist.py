from __future__ import absolute_import, division, print_function

# TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras

# Helper libraries
import matplotlib.pyplot as plt
import numpy as np

# Dataset alias
from tensorflow.keras.datasets.fashion_mnist import load_data

print(tf.__version__)

# Load data
# fashion_mnist = keras.datasets.fashion_mnist
(train_images, train_labels), (test_images, test_labels) = load_data()

# Dataset class names.
class_names = ['T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
               'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot']

# Pre-process images by scaling them to a maximum value of 1.
train_images = train_images / 255.0
test_images = test_images / 255.0

# Build a trivial model.
model = keras.Sequential([
    keras.layers.Flatten(input_shape=(28, 28)),
    keras.layers.Dense(128, activation=tf.nn.relu),
    keras.layers.Dense(10, activation=tf.nn.softmax)
])

# Compile the model.
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# Define model training callbacks.
callbacks = [
    # Save model checkpoints are specified epoch intervals/periods.
    keras.callbacks.ModelCheckpoint(
        'weights.{epoch:02d}-{acc:.2f}.hdf5',
        monitor='acc',
        period=1,
    ),
    # Save training summary stuff used by TensorBoard.
    keras.callbacks.TensorBoard(
        log_dir='./logs',
    ),
]

# Train the model.
model.fit(train_images, train_labels, epochs=5, callbacks=callbacks)

# Evaluate the model.
test_loss, test_acc = model.evaluate(test_images, test_labels)
print('Test accuracy:', test_acc)


# -----------------------------------------------------------------------------


def plot_image(i, predictions, true_label, img):
    predictions, true_label, img = predictions[i], true_label[i], img[i]
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])

    plt.imshow(img, cmap=plt.cm.binary)

    predicted_label = np.argmax(predictions)
    if predicted_label == true_label:
        color = 'blue'
    else:
        color = 'red'

    plt.xlabel('{} {:2.0f}% ({})'.format(class_names[predicted_label],
                                         100*np.max(predictions),
                                         class_names[true_label]),
               color=color)


def plot_value_array(i, predictions, true_label):
    predictions, true_label = predictions[i], true_label[i]
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    thisplot = plt.bar(range(10), predictions, color='#777777')
    plt.ylim([0, 1])
    predicted_label = np.argmax(predictions)

    thisplot[predicted_label].set_color('red')
    thisplot[true_label].set_color('blue')


# -----------------------------------------------------------------------------


# Make predictions on the test images.
predictions = model.predict(test_images)

# Plot the first X test images, their predicted label, and the true label.
# Color correct predictions in blue, incorrect predictions in red.
num_rows = 5
num_cols = 3
num_images = num_rows * num_cols
plt.figure(figsize=(2 * 2 * num_cols, 2 * num_rows))
for i in range(num_images):
    plt.subplot(num_rows, 2 * num_cols, 2 * i + 1)
    plot_image(i, predictions, test_labels, test_images)
    plt.subplot(num_rows, 2 * num_cols, 2 * i + 2)
    plot_value_array(i, predictions, test_labels)
plt.savefig('fashion-mnist.png')
