const host = require('./server/host.js');
const app = require('./server/app.js');
const http = require('http');

// const server = https.createServer(cert.cert, app.app);

const server = http.createServer(app.app);

server.listen(host.port, host.hostname, () => {
    console.log(`Server running at http://${host.hostname}:${host.port}`)
});