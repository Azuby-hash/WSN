const fs = require('fs')

// Certificate for https ------------------------------------------

var cert = {
    key: fs.readFileSync('cert/key.pem'),
    cert: fs.readFileSync('cert/server.crt')
};

// ----------------------------------------------------------------

module.exports = {
    cert: cert,
}