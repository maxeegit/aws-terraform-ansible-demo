from flask import Flask, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import socket
import time

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "flask_http_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "flask_http_request_duration_seconds",
    "HTTP request latency",
    ["method", "endpoint"]
)


@app.before_request
def start_timer():
    from flask import g
    g.start_time = time.time()


@app.after_request
def record_metrics(response):
    from flask import request, g

    elapsed = time.time() - g.start_time

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()

    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.path
    ).observe(elapsed)

    return response


@app.route("/")
def home():
    return {
        "application": "AWS Quick Deploy",
        "status": "running",
        "server": socket.gethostname()
    }


@app.route("/health")
def health():
    return {"status": "healthy"}


@app.route("/metrics")
def metrics():
    return Response(
        generate_latest(),
        mimetype=CONTENT_TYPE_LATEST
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
