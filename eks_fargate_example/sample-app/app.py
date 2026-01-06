from flask import Flask, jsonify
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.flask import FlaskInstrumentor
import os
import time
import random

# Configure OpenTelemetry
resource = Resource(attributes={
    "service.name": "sample-otel-app",
    "service.version": "1.0.0",
    "deployment.environment": "production"
})

# Set up the tracer provider
trace.set_tracer_provider(TracerProvider(resource=resource))
tracer_provider = trace.get_tracer_provider()

# Configure OTLP exporter to send to Datadog agent
otlp_exporter = OTLPSpanExporter(
    endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317"),
    insecure=True
)

# Add span processor
tracer_provider.add_span_processor(BatchSpanProcessor(otlp_exporter))

# Create Flask app
app = Flask(__name__)

# Auto-instrument Flask
FlaskInstrumentor().instrument_app(app)

# Get tracer
tracer = trace.get_tracer(__name__)

@app.route('/')
def hello():
    with tracer.start_as_current_span("hello-handler") as span:
        span.set_attribute("custom.attribute", "hello-world")
        return jsonify({
            "message": "Hello from OpenTelemetry instrumented app!",
            "service": "sample-otel-app"
        })

@app.route('/api/users')
def get_users():
    with tracer.start_as_current_span("get-users") as span:
        # Simulate some work
        time.sleep(random.uniform(0.01, 0.1))

        users = [
            {"id": 1, "name": "Alice"},
            {"id": 2, "name": "Bob"},
            {"id": 3, "name": "Charlie"}
        ]

        span.set_attribute("user.count", len(users))
        return jsonify(users)

@app.route('/api/process')
def process_data():
    with tracer.start_as_current_span("process-data") as span:
        # Simulate processing with nested spans
        with tracer.start_as_current_span("fetch-data"):
            time.sleep(random.uniform(0.02, 0.05))

        with tracer.start_as_current_span("transform-data"):
            time.sleep(random.uniform(0.01, 0.03))

        with tracer.start_as_current_span("save-data"):
            time.sleep(random.uniform(0.01, 0.02))

        span.set_attribute("processing.status", "success")
        return jsonify({"status": "processed"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
