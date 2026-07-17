const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const mysql = require('mysql2/promise');

dotenv.config({ path: path.join(__dirname, '..', '.env') });
dotenv.config({ path: path.join(__dirname, '..', 'env') });

const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'kenios_hax',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

async function setupDatabase() {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    const bootstrapConnection = await mysql.createConnection({
        host: dbConfig.host,
        port: dbConfig.port,
        user: dbConfig.user,
        password: dbConfig.password,
        multipleStatements: true
    });

    try {
        await bootstrapConnection.query(schemaSql);
        console.log('Database setup completed successfully.');
    } finally {
        await bootstrapConnection.end();
    }
}

if (require.main === module) {
    setupDatabase()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error('Database setup failed:', error.message);
            process.exit(1);
        });
}

module.exports = pool;
