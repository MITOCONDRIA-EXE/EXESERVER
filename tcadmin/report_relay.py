#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Relay local de reportes -> Discord
# Corre en la MISMA maquina del servidor CS. No necesita hosting externo.
#
# Uso:
#   python3 report_relay.py
#   (o en background:  nohup python3 report_relay.py >/dev/null 2>&1 &)
#
# Luego en server.cfg/amxx.cfg pon:
#   exe_report_url "http://127.0.0.1:8765/"
#

import json
import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.request import Request, urlopen

WEBHOOK_URL = "https://discord.com/api/webhooks/1538321086612246608/Ky1g5-0Q21aD2t9G06BzDdnQBd8T4Fo6TapuxvLWv-iMf7ZOUOQySvz7LRXGKALpeEnC"
HOST = "127.0.0.1"
PORT = 8765


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length).decode("utf-8", "ignore")
            data = json.loads(body)
        except Exception:
            self._reply(400)
            return

        message = data.get("message", "").strip()
        if not message:
            self._reply(400)
            return

        embed = {
            "title": "Nuevo reporte",
            "description": message,
            "color": 15548997,  # rojo
            "fields": [
                {"name": "Servidor", "value": data.get("server", "Desconocido"), "inline": True},
                {"name": "Mapa", "value": data.get("map", "Desconocido"), "inline": True},
                {"name": "Reportado por", "value": data.get("reporter", "Desconocido"), "inline": True},
                {"name": "SteamID", "value": data.get("steamid", "N/A"), "inline": True},
                {"name": "IP", "value": data.get("ip", "N/A"), "inline": True},
            ],
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
        }

        payload = json.dumps({"embeds": [embed]}).encode("utf-8")
        req = Request(WEBHOOK_URL, data=payload, headers={"Content-Type": "application/json"})

        try:
            urlopen(req, timeout=10)
            self._reply(200)
        except Exception:
            self._reply(500)

    def _reply(self, code):
        self.send_response(code)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", "2")
        self.end_headers()
        self.wfile.write(b"OK")

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    print("Relay de reportes -> Discord")
    print("Escuchando en http://%s:%d" % (HOST, PORT))
    HTTPServer((HOST, PORT), Handler).serve_forever()
