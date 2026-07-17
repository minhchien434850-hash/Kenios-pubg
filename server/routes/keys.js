const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const crypto = require('crypto');
const db = require('../database/db');

// Generate key
router.post('/generate', async (req, res) => {
    const { plan_type, max_devices, duration_days, created_by } = req.body;
    try {
        const keyCode = 'KEN-' + uuidv4().substring(0, 12).toUpperCase().replace(/-/g, '').match(/.{1,4}/g).join('-');
        const keyHash = crypto.createHash('sha256').update(keyCode).digest('hex');
        const expiresAt = duration_days ? new Date(Date.now() + duration_days * 86400000) : null;
        
        await db.query('INSERT INTO license_keys (key_hash, key_prefix, plan_type, max_devices, expires_at, created_by) VALUES (?, ?, ?, ?, ?, ?)',
            [keyHash, 'KEN-', plan_type || 'monthly', max_devices || 1, expiresAt, created_by || 1]);
        
        res.json({ key: keyCode, plan_type, expires_at: expiresAt });
    } catch (err) {
        res.status(500).json({ error: 'Failed to generate key' });
    }
});

// List all keys
router.get('/list', async (req, res) => {
    try {
        const [keys] = await db.query('SELECT id, plan_type, is_active, is_banned, max_devices, created_at, expires_at, last_used_at FROM license_keys ORDER BY created_at DESC LIMIT 100');
        res.json(keys);
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Get key details
router.get('/:id', async (req, res) => {
    try {
        const [keys] = await db.query('SELECT * FROM license_keys WHERE id = ?', [req.params.id]);
        if (keys.length === 0) return res.status(404).json({ error: 'Key not found' });
        
        const [devices] = await db.query('SELECT * FROM device_bindings WHERE key_id = ?', [req.params.id]);
        const [logs] = await db.query('SELECT * FROM key_usage_log WHERE key_id = ? ORDER BY created_at DESC LIMIT 50', [req.params.id]);
        
        res.json({ key: keys[0], devices, logs });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Ban/Unban key
router.post('/:id/toggle', async (req, res) => {
    try {
        const [keys] = await db.query('SELECT is_banned FROM license_keys WHERE id = ?', [req.params.id]);
        if (keys.length === 0) return res.status(404).json({ error: 'Key not found' });
        
        await db.query('UPDATE license_keys SET is_banned = ? WHERE id = ?', [!keys[0].is_banned, req.params.id]);
        res.json({ success: true, is_banned: !keys[0].is_banned });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Delete key
router.delete('/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM device_bindings WHERE key_id = ?', [req.params.id]);
        await db.query('DELETE FROM key_usage_log WHERE key_id = ?', [req.params.id]);
        await db.query('DELETE FROM license_keys WHERE id = ?', [req.params.id]);
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
