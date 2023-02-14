const host = require('./server/host.js');
const cert = require('./server/cert.js');
const app = require('./server/app.js');
const http = require('http');
const https = require('https');

// const server = https.createServer(cert.cert, app.app);

const server = http.createServer(app.app);

server.listen(host.port, host.hostname, () => {
    console.log(`Server running at http://${host.hostname}:${host.port}`)
});