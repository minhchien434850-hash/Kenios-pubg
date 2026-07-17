const express = require('express');
const router = express.Router();
const db = require('../database/db');

router.get('/dashboard', async (req, res) => {
    try {
        const [totalKeys] = await db.query('SELECT COUNT(*) as count FROM license_keys');
        const [activeKeys] = await db.query('SELECT COUNT(*) as count FROM license_keys WHERE is_active = 1 AND is_banned = 0');
        const [totalDevices] = await db.query('SELECT COUNT(*) as count FROM device_bindings');
        const [recentLogs] = await db.query('SELECT * FROM key_usage_log ORDER BY created_at DESC LIMIT 20');
        
        res.json({
            total_keys: totalKeys[0].count,
            active_keys: activeKeys[0].count,
            total_devices: totalDevices[0].count,
            recent_logs: recentLogs
        });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
