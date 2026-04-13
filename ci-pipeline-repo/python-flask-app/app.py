from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route("/")
def home():
    """Return a greeting and current server time."""
    return jsonify({
        "message": "Hello from Dockerized Flask App!",
        "current_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    })

if __name__ == "__main__":
    try:
        # Run on all interfaces so Docker can expose it
        app.run(host="0.0.0.0", port=5000, debug=False)
    except Exception as e:
        print(f"Error starting Flask app: {e}")