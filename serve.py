#!/usr/bin/env python3
"""Serve Flutter web build on port 5000."""
import http.server
import os

os.chdir("build/web")

class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # silence request logs

    def end_headers(self):
        # Needed for CanvasKit SharedArrayBuffer on some browsers
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    def do_GET(self):
        # SPA fallback: serve index.html for unknown paths
        path = self.translate_path(self.path)
        if not os.path.exists(path) or os.path.isdir(path):
            self.path = "/index.html"
        super().do_GET()

server = http.server.HTTPServer(("0.0.0.0", 5000), Handler)
print("UP Police HRMS running at http://0.0.0.0:5000")
server.serve_forever()
