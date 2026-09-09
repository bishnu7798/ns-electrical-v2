import http.server
import socketserver
import os

# Set the port for the server
PORT = 8000

# Change to the web directory
web_dir = os.path.join(os.path.dirname(__file__), 'web')
os.chdir(web_dir)

# Create the server
Handler = http.server.SimpleHTTPRequestHandler
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Server running at http://localhost:{PORT}/")
    print("Press Ctrl+C to stop the server")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")