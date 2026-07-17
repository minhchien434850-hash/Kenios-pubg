const rateLimit = require('express-rate-limit');

const keyValidationLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10,
    message: { error: 'Too many key validation attempts', code: 429 }
});

const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: { error: 'Rate limit exceeded', code: 429 }
});

module.exports = { keyValidationLimiter, apiLimiter };
