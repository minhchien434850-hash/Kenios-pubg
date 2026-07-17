const crypto = require('crypto');

function generateKey() {
    return 'KEN-' + crypto.randomBytes(8).toString('hex').toUpperCase().match(/.{1,4}/g).join('-');
}

function hashKey(key) {
    return crypto.createHash('sha256').update(key).digest('hex');
}

function encryptData(data, key) {
    const cipher = crypto.createCipher('aes-256-cbc', key);
    let encrypted = cipher.update(JSON.stringify(data), 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
}

function decryptData(encrypted, key) {
    const decipher = crypto.createDecipher('aes-256-cbc', key);
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return JSON.parse(decrypted);
}

module.exports = { generateKey, hashKey, encryptData, decryptData };
