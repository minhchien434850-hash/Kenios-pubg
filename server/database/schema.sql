CREATE DATABASE IF NOT EXISTS kenios_hax;
USE kenios_hax;

CREATE TABLE license_keys (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_hash VARCHAR(64) NOT NULL UNIQUE,
    key_prefix VARCHAR(10) NOT NULL,
    plan_type ENUM('trial','weekly','monthly','lifetime','admin') DEFAULT 'trial',
    is_active BOOLEAN DEFAULT TRUE,
    is_banned BOOLEAN DEFAULT FALSE,
    max_devices INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    last_used_at TIMESTAMP NULL,
    created_by INT,
    features_json TEXT,
    notes TEXT
);

CREATE TABLE device_bindings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_id INT NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    ios_version VARCHAR(20),
    ip_address VARCHAR(45),
    is_active BOOLEAN DEFAULT TRUE,
    first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (key_id) REFERENCES license_keys(id)
);

CREATE TABLE key_usage_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_id INT NOT NULL,
    device_id VARCHAR(255),
    action VARCHAR(50),
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (key_id) REFERENCES license_keys(id)
);

CREATE TABLE admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    role ENUM('admin','moderator') DEFAULT 'moderator',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE security_alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_id INT,
    device_id VARCHAR(255),
    alert_type VARCHAR(50),
    details TEXT,
    severity ENUM('low','medium','high','critical') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (key_id) REFERENCES license_keys(id)
);

-- Insert default admin
INSERT INTO admin_users (username, password_hash, email, role) VALUES ('admin', '$2a$12$LJ3m4ys3GZkYq8HxVwRnYOJvLk5mN8xQpZsBcDeFgHiJkLmNoPqRs', 'admin@kenios-hax.dev', 'admin');
