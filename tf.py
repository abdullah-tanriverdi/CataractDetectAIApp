import tensorflow as tf

# 1. Modeli yükle
model = tf.keras.models.load_model("C:\\Users\\abdul\\Desktop\\Cataract\\trained_cataract_model.h5")

# 2. Converter oluştur
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# 3. (İsteğe bağlı) Modeli optimize edelim
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# 4. TFLite modeli oluştur
tflite_model = converter.convert()

# 5. Kaydet
with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
