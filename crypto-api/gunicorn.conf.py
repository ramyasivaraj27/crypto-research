# Gunicorn configuration for crypto-api (2 vCPU, 8 GB RAM reference)
import os

bind = "0.0.0.0:8000"
backlog = 1024
workers = 3
worker_class = "sync"
max_requests = 1000
max_requests_jitter = 100
timeout = 60
graceful_timeout = 45
keepalive = 10
preload_app = False
worker_tmp_dir = "/tmp"
reuse_port = True
limit_request_line = 8192
limit_request_fields = 200
limit_request_field_size = 8192
proc_name = "crypto-api"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'
accesslog = "/app/logs/gunicorn-access.log"
errorlog = "/app/logs/gunicorn-error.log"
loglevel = "info"
capture_output = True
pidfile = "/app/logs/gunicorn.pid"

if os.getenv("GUNICORN_LOG_STDOUT", "false").lower() in {"1", "true", "yes"}:
    accesslog = "-"
    errorlog = "-"

forwarded_allow_ips = "*"
proxy_protocol = False
