from flask import Flask, request, jsonify
import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np
from PIL import Image
import io

app = Flask(__name__)

# Modeli yükle
model_path = "trained_cataract_model.h5"
model = tf.keras.models.load_model(model_path)

# Tahmin fonksiyonu
def predict_cataract(img_path):
    img = image.load_img(img_path, target_size=(128, 128))
    img_array = image.img_to_array(img)
    img_array = img_array / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    predictions = model.predict(img_array)
    predicted_class = np.argmax(predictions, axis=-1)
    
    return "Normal Göz" if predicted_class == 0 else "Katarakt Var"

# Fotoğrafı alıp tahmin yapma endpoint'i
@app.route('/predict', methods=['POST'])
def predict():
    file = request.files['file']
    img = Image.open(file.stream)
    
    # Tahmin yap
    result = predict_cataract(img)
    
    return jsonify({"result": result})

if __name__ == "__main__":
    app.run(debug=True)
