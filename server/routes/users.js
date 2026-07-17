const express = require('express');
const router = express.Router();
const db = require('../database/db');

router.get('/list', async (req, res) => {
    try {
        const [users] = await db.query('SELECT id, username, email, role, is_active, created_at FROM admin_users ORDER BY created_at DESC');
        res.json(users);
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
