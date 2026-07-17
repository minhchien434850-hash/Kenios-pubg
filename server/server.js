require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const path = require('path');

const app = express();

app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(',') || '*' }));
app.use(express.json({ limit: '10mb' }));
app.use(morgan('combined'));

const limiter = rateLimit({ windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000, max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100 });
app.use('/api/', limiter);

// Admin Panel
app.use('/admin', express.static(path.join(__dirname, 'admin')));
app.get('/admin', (req, res) => res.sendFile(path.join(__dirname, 'admin', 'login.html')));
app.get('/admin/dashboard', (req, res) => res.sendFile(path.join(__dirname, 'admin', 'dashboard.html')));
app.get('/admin/keys', (req, res) => res.sendFile(path.join(__dirname, 'admin', 'keys.html')));
app.get('/admin/users', (req, res) => res.sendFile(path.join(__dirname, 'admin', 'users.html')));

// API Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/keys', require('./routes/keys'));
app.use('/api/users', require('./routes/users'));
app.use('/api/stats', require('./routes/stats'));

// Key Validation
app.post('/api/validate-key', async (req, res) => {
    const { key, device_id, ipa_checksum } = req.body;
    if (!key || !device_id) return res.status(400).json({ valid: false, error: 'Missing fields', code: 'MISSING_FIELDS' });
    
    // Simple validation (replace with DB check)
    if (key.startsWith('KEN-') && key.length === 19) {
        return res.json({
            valid: true,
            token: 'jwt_token_here',
            expires_at: new Date(Date.now() + 30*24*60*60*1000).toISOString(),
            plan: 'monthly',
            features: { aimbot: true, esp: true, magic_bullet: true, skin_changer: true, bomb_alert: true, vehicle_master: true }
        });
    }
    
    return res.status(403).json({ valid: false, error: 'Invalid key', code: 'INVALID_KEY' });
});

// Heartbeat
app.post('/api/heartbeat', (req, res) => {
    res.json({ status: 'ok', server_time: new Date().toISOString() });
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', version: '1.0.0', ios_support: '16.0-26.5', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`KENIOS HAX Server running on port ${PORT}`));
