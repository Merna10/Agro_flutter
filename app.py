from flask import Flask
import firebase_admin
from firebase_admin import credentials, firestore

app = Flask(__name__)

# Initialize Firebase Admin SDK
cred = credentials.Certificate('G:/mobile/basic-8dee0-firebase-adminsdk-5ebmy-95b01378d2.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

@app.route('/')
def index():
    return 'heloo'

if __name__ == '__main__':
    app.run(debug=True)
