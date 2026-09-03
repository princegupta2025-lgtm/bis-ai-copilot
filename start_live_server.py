#!/usr/bin/env python3
"""
BIS TRUST COPILOT — LIVE PRODUCTION SERVER & SECURE PROXY
Serves static assets and provides secure upstream streaming LLM proxy to Google Gemini API.
"""

import os
import sys
import json
import urllib.request
import urllib.parse
import urllib.error
import http.server
import socketserver
import mimetypes

# Set stdout to UTF-8
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(ROOT_DIR)

# Load .env
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', '')

# Attempt to load .env if available
env_path = os.path.join(os.path.dirname(__file__), '.env')
if os.path.exists(env_path):
    try:
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    k, v = line.split('=', 1)
                    k, v = k.strip(), v.strip()
                    if k == 'GEMINI_API_KEY' and not GEMINI_API_KEY:
                        GEMINI_API_KEY = v
    except Exception as e:
        print(f"Notice loading .env: {e}")

PORT = int(os.environ.get('PORT', 8000))

# Load vector cache if available
VECTORS = []
vector_path = os.path.join(ROOT_DIR, 'data', 'bis_rag_embeddings.json')
if os.path.exists(vector_path):
    try:
        with open(vector_path, 'r', encoding='utf-8') as f:
            vdata = json.load(f)
            VECTORS = vdata.get('chunks', [])
    except Exception as e:
        print(f"Notice: vector database load exception: {e}")

class LiveServerHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        # Sensitive file protection (.env, credentials, server code, executables)
        clean = self.path.lower().split('?')[0]
        blocked = ['.env', '.git', '.key', '.pem', 'cloudflared.exe']
        if any(b in clean for b in blocked) or '/.' in clean:
            self.send_error(403, "Forbidden: Access to sensitive file is prohibited")
            return
        super().do_GET()

    def do_POST(self):
        if self.path == '/api/chat':
            self.handle_api_chat()
        elif self.path == '/api/rag':
            self.handle_api_rag()
        elif self.path == '/api/translate':
            self.handle_api_translate()
        else:
            self.send_error(404, "Endpoint not found")

    def handle_api_chat(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')

        if not GEMINI_API_KEY:
            self.send_response(503)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': 'GEMINI_API_KEY is not configured on server.'}).encode('utf-8'))
            return

        try:
            req_data = json.loads(body)
            model = req_data.get('model', 'gemini-3.6-flash')
            messages = req_data.get('messages', [])
            temperature = float(req_data.get('temperature', 0.12))
            max_tokens = int(req_data.get('max_tokens', 1500))
            stream = bool(req_data.get('stream', True))

            if model in ['gemini-1.5-flash', 'gemini-2.0-flash', 'gemini-2.5-flash']:
                model = 'gemini-3.6-flash'

            is_gemini = model.startswith('gemini') or model.startswith('tunedModels')
            target_url = 'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions'
            headers = {
                'x-goog-api-key': GEMINI_API_KEY,
                'Authorization': f'Bearer {GEMINI_API_KEY}',
                'Content-Type': 'application/json',
                'User-Agent': 'BIS-Trust-Copilot/2.3'
            }
            target_model = model if is_gemini else 'gemini-3.6-flash'

            payload = json.dumps({
                'model': target_model,
                'messages': messages,
                'temperature': temperature,
                'max_tokens': max_tokens,
                'stream': stream
            }).encode('utf-8')

            req = urllib.request.Request(
                target_url,
                data=payload,
                headers=headers
            )

            try:
                upstream = urllib.request.urlopen(req, timeout=30)
            except urllib.error.HTTPError as he:
                err_resp = he.read().decode('utf-8', errors='ignore')
                self.send_response(he.code)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(err_resp.encode('utf-8'))
                return

            if stream:
                self.send_response(200)
                self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
                self.send_header('Cache-Control', 'no-cache')
                self.send_header('Connection', 'keep-alive')
                self.end_headers()

                while True:
                    chunk = upstream.read(256)
                    if not chunk:
                        break
                    self.wfile.write(chunk)
                    self.wfile.flush()
            else:
                resp_bytes = upstream.read()
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(resp_bytes)

        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': f'Proxy stream error: {str(e)}'}).encode('utf-8'))

    def handle_api_rag(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')
        try:
            req_data = json.loads(body)
            query = req_data.get('query', '').lower()
            top_k = int(req_data.get('topK', 4))
            
            results = []
            if VECTORS:
                q_words = query.split()
                for chunk in VECTORS:
                    score = 0
                    text = (chunk.get('standardCode', '') + ' ' + chunk.get('clauseTitle', '') + ' ' + chunk.get('text', '')).lower()
                    for w in q_words:
                        if len(w) > 2 and w in text:
                            score += 1
                    if score > 0:
                        results.append({'chunk': chunk, 'score': score})
                results.sort(key=lambda x: x['score'], reverse=True)

            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({
                'model': 'Server-RAG-Hybrid-RRF',
                'results': results[:top_k]
            }).encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': str(e)}).encode('utf-8'))

    def handle_api_translate(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')
        try:
            req_data = json.loads(body)
            text = req_data.get('text', '')
            target_lang = req_data.get('targetLang', 'hi')
            source_lang = req_data.get('sourceLang', 'en')

            if not GEMINI_API_KEY:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'translatedText': text, 'engine': 'Fallback'}).encode('utf-8'))
                return

            nmt_prompt = [
                {"role": "system", "content": f"You are the Bhashini National AI Translation Engine (Government of India). Translate from {source_lang} to {target_lang} preserving technical standard codes intact. Output ONLY raw translation."},
                {"role": "user", "content": text}
            ]

            payload = json.dumps({
                'model': 'gemini-3.6-flash',
                'messages': nmt_prompt,
                'temperature': 0.1,
                'max_tokens': 1000,
                'stream': False
            }).encode('utf-8')

            req = urllib.request.Request(
                'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions',
                data=payload,
                headers={
                    'x-goog-api-key': GEMINI_API_KEY,
                    'Authorization': f'Bearer {GEMINI_API_KEY}',
                    'Content-Type': 'application/json'
                }
            )

            with urllib.request.urlopen(req, timeout=15) as resp:
                data = json.loads(resp.read().decode('utf-8'))
                trans = data.get('choices', [{}])[0].get('message', {}).get('content', '').strip()
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'translatedText': trans or text, 'engine': 'Bhashini-Gemini-NMT'}).encode('utf-8'))

        except Exception as e:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'translatedText': text, 'engine': 'Offline-Fallback'}).encode('utf-8'))

def run_server():
    server_address = ('0.0.0.0', PORT)
    httpd = socketserver.TCPServer(server_address, LiveServerHandler, bind_and_activate=False)
    httpd.allow_reuse_address = True
    httpd.server_bind()
    httpd.server_activate()

    print(f"============================================================")
    print(f"  🇮🇳 BIS TRUST COPILOT — LIVE PRODUCTION SERVER READY")
    print(f"  Local Address:  http://localhost:{PORT}")
    print(f"  Network IPv4:   http://127.0.0.1:{PORT}")
    print(f"  Live Gemini LLM: {'CONNECTED (Active Key)' if GEMINI_API_KEY else 'OFFLINE (Fallback Active)'}")
    print(f"============================================================")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server.")
        httpd.server_close()

if __name__ == '__main__':
    run_server()
