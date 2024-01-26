from flask import Flask

app = Flask(__name__)

# Set up logging
gunicorn_logger = logging.getLogger('gunicorn.error')
app.logger.handlers = gunicorn_logger.handlers
app.logger.setLevel(gunicorn_logger.level)

@app.route("/")
def hello_world():
    return "<p>Hello World!</p>"

@app.route("/about")
def return_about():
    return "<h1>About this app:</h1>"

@app.route("/error")
def return_error():
    return "<h1>Error: Internal Server Error</h1>", 500

