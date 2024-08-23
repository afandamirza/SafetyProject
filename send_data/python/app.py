from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import firebase_admin
from firebase_admin import credentials, firestore, storage
import os
import uuid

# Inisialisasi Firebase Admin SDK
cred_path = os.path.join(os.path.dirname(__file__), '../safetyreportproject-firebase-adminsdk-fhskx-a449059455.json')
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred, {
    'storageBucket': 'safetyreportproject.appspot.com'
})

db = firestore.client()
bucket = storage.bucket()
app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_file():
    try:
        # Cek apakah ada file yang diupload
        if 'Image' not in request.files:
            return jsonify({'error': 'No file part'}), 400

        file = request.files['Image']
        if file.filename == '':
            return jsonify({'error': 'No selected file'}), 400

        # Generate unique filename untuk file yang akan diupload
        filename = f"{uuid.uuid4()}-{secure_filename(file.filename)}"

        # Upload file ke Firebase Storage
        blob = bucket.blob(filename)
        blob.upload_from_string(file.read(), content_type=file.mimetype)

        # Dapatkan URL publik dari file yang diupload
        photo_url = blob.generate_signed_url(
            expiration=datetime.timedelta(days=365*100),  # Atur tanggal kedaluwarsa yang sesuai
            method='GET'
        )

        # Ambil parameter lainnya dari request body
        latitude = request.form.get('Latitude')
        longitude = request.form.get('Longitude')
        date = request.form.get('Date')
        time = request.form.get('Time')
        details = request.form.get('Details')

        # Simpan data ke Firestore
        doc_ref = db.collection('SafetyReport').document()
        doc_ref.set({
            'photoURL': photo_url,
            'Latitude': latitude,
            'Longitude': longitude,
            'Date': date,
            'Time': time,
            'Details': details,
        })

        return jsonify({
            'message': 'Data added successfully',
            'id': doc_ref.id,
            'photoURL': photo_url,
        }), 200

    except Exception as e:
        print(f"Error uploading file and saving data: {e}")
        return jsonify({'error': 'Failed to upload file and save data', 'details': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7000, debug=True)
