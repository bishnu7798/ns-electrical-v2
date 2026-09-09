const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8000;

// MIME types for different file extensions
const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.wav': 'audio/wav',
  '.mp4': 'video/mp4',
  '.woff': 'application/font-woff',
  '.ttf': 'application/font-ttf',
  '.eot': 'application/vnd.ms-fontobject',
  '.otf': 'application/font-otf',
  '.wasm': 'application/wasm'
};

// Function to serve static files
function serveStaticFile(res, pathname) {
  // Default to index.html if pathname is a directory
  if (pathname.endsWith('/')) {
    pathname += 'index.html';
  }

  // Resolve the file path
  const filePath = path.join(__dirname, 'web', pathname);

  // Get the file extension
  const extname = String(path.extname(filePath)).toLowerCase();
  const contentType = MIME_TYPES[extname] || 'application/octet-stream';

  // Read and serve the file
  fs.readFile(filePath, (error, content) => {
    if (error) {
      if (error.code === 'ENOENT') {
        // File not found
        fs.readFile(path.join(__dirname, 'web', 'index.html'), (error, content) => {
          if (error) {
            res.writeHead(500);
            res.end(`Server Error: ${error.code}`);
          } else {
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(content, 'utf-8');
          }
        });
      } else {
        // Server error
        res.writeHead(500);
        res.end(`Server Error: ${error.code}`);
      }
    } else {
      // Success
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
}

// Create the HTTP server
const server = http.createServer((req, res) => {
  console.log(`Request received: ${req.method} ${req.url}`);
  
  // Serve static files
  serveStaticFile(res, req.url);
});

// Start the server
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
  console.log('Press Ctrl+C to stop the server');
});