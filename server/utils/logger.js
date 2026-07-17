const fs = require('fs');
const path = require('path');

const logDir = path.join(__dirname, '..', 'logs');
if (!fs.existsSync(logDir)) fs.mkdirSync(logDir);

const logger = {
    info: (msg) => {
        const log = `[INFO] ${new Date().toISOString()} - ${msg}\n`;
        fs.appendFileSync(path.join(logDir, 'server.log'), log);
        console.log(log.trim());
    },
    error: (msg, err) => {
        const log = `[ERROR] ${new Date().toISOString()} - ${msg} ${err ? err.stack : ''}\n`;
        fs.appendFileSync(path.join(logDir, 'error.log'), log);
        console.error(log.trim());
    }
};

module.exports = logger;
