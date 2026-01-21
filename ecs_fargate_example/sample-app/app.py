from flask import Flask, jsonify
import os
import time
import random

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from ECS Fargate!',
        'service': os.getenv('DD_SERVICE', 'unknown'),
        'env': os.getenv('DD_ENV', 'unknown'),
        'version': os.getenv('DD_VERSION', 'unknown')
    })

@app.route('/api/users')
def get_users():
    time.sleep(random.uniform(0.01, 0.05))
    users = [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
        {'id': 3, 'name': 'Charlie'}
    ]
    return jsonify(users)

@app.route('/api/process')
def process_data():
    time.sleep(random.uniform(0.02, 0.1))
    result = {
        'status': 'processed',
        'records': random.randint(10, 100),
        'duration_ms': random.randint(50, 200)
    }
    return jsonify(result)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
