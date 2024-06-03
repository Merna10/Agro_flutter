import threading
from flask import Flask, request, jsonify
from flask_cors import CORS
from tensorflow.keras.preprocessing import image
import numpy as np
import tensorflow as tf
import pickle
import os
import h5py
import cv2
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from PIL import Image

app = Flask(__name__)
CORS(app)

# Loading the pickled model
with open('my_model.pkl', 'rb') as model_file:
    model_predict = pickle.load(model_file)

# Loading the Keras model
model = load_model('my_model.h5')

def preprocess_image(image_path):
    # Implement your preprocessing logic here
    img = image.load_img(image_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    processed_image = img_array / 255.0  # Normalize pixel values
    return processed_image

class_labels = ['Tomato___Bacterial_spot', 'Tomato___Early_blight',
       'Tomato___Late_blight', 'Tomato___Leaf_Mold',
       'Tomato___Septoria_leaf_spot',
       'Tomato___Spider_mites Two-spotted_spider_mite',
       'Tomato___Target_Spot', 'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
       'Tomato___Tomato_mosaic_virus', 'Tomato___healthy']

@app.route('/upload', methods=['POST'])
def predict():
    print("entered function")
    # Check if the POST request has the file part
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'})
    print(request.files)
    file = request.files['file']

    # If the user does not select a file, the browser submits an empty file without a filename
    if file.filename == '':
        return jsonify({'error': 'No selected file'})

    # Save the uploaded file to a temporary directory
    upload_folder = 'temp_uploads'
    os.makedirs(upload_folder, exist_ok=True)
    file_path = os.path.join(upload_folder, file.filename)
    file.save(file_path)
    print(file_path)

    # Preprocess the uploaded image
    processed_image = preprocess_image(file_path)

    # Make predictions using the loaded model
    result = model.predict(processed_image)
    print(result)
    # Get the maximum predicted class for each image in the test set
    predicted_classes = np.argmax(result, axis=1)

    # Map the predicted class indices to the class labels
    predicted_labels = class_labels[predicted_classes[0]]
    print(predicted_classes)
    # Print the predicted labels
    print(predicted_labels)
    # Return the prediction as JSON
    return jsonify({'prediction': predicted_labels})

def run_flask_app():
    app.run(debug=True, host='127.0.0.1', port=9000, threaded=True)

if __name__ == '__main__':
    run_flask_app()
