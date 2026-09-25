-- ============================================================================
-- AI-Rescue: Intelligent Disaster Response & Resource Coordination Platform
-- PostgreSQL 16+ Database Schema (V1 Final Freeze - 16 Tables)
-- ============================================================================

-- Drop tables in reverse dependency order if re-running
DROP TABLE IF EXISTS system_settings CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS report_log CASCADE;
DROP TABLE IF EXISTS notification CASCADE;
DROP TABLE IF EXISTS resource_assignment CASCADE;
DROP TABLE IF EXISTS equipment CASCADE;
DROP TABLE IF EXISTS vehicle CASCADE;
DROP TABLE IF EXISTS resource CASCADE;
DROP TABLE IF EXISTS ai_recommendation CASCADE;
DROP TABLE IF EXISTS incident_media CASCADE;
DROP TABLE IF EXISTS incident CASCADE;
DROP TABLE IF EXISTS shelter CASCADE;
DROP TABLE IF EXISTS hospital CASCADE;
DROP TABLE IF EXISTS disaster_type CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS role CASCADE;

-- ============================================================================
-- 1. ROLE
-- Stores user authorization and system access roles.
-- ============================================================================
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_role_name CHECK (role_name IN ('CITIZEN', 'OFFICER', 'RESPONDER', 'ADMIN'))
);

-- ============================================================================
-- 2. USERS (Conceptual Entity: USER)
-- Stores registered citizens, emergency officers, responders, and administrators.
-- ============================================================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    role_id INTEGER NOT NULL REFERENCES role(role_id) ON DELETE RESTRICT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL,
    password_hash VARCHAR(255) NOT NULL,
    address VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    state VARCHAR(100) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMPTZ NULL,
    CONSTRAINT chk_user_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

-- Index for authentication lookup
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role_id);

-- ============================================================================
-- 3. DISASTER_TYPE
-- Catalog of natural and man-made disaster categories.
-- ============================================================================
CREATE TABLE disaster_type (
    disaster_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 4. INCIDENT
-- Core operational entity recording disaster events and lifecycle states.
-- ============================================================================
CREATE TABLE incident (
    incident_id SERIAL PRIMARY KEY,
    disaster_type_id INTEGER NOT NULL REFERENCES disaster_type(disaster_type_id) ON DELETE RESTRICT,
    reported_by INTEGER NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    verified_by INTEGER NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    location_address VARCHAR(255) NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    reported_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ NULL,
    severity_level VARCHAR(30) NULL,
    priority_level VARCHAR(30) NULL,
    people_affected INTEGER NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'REPORTED',
    resolution_notes TEXT NULL,
    resolved_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_incident_lat CHECK (latitude BETWEEN -90.0000000 AND 90.0000000),
    CONSTRAINT chk_incident_lon CHECK (longitude BETWEEN -180.0000000 AND 180.0000000),
    CONSTRAINT chk_incident_people CHECK (people_affected >= 0),
    CONSTRAINT chk_incident_status CHECK (status IN ('REPORTED', 'VERIFIED', 'AI_ANALYZED', 'DISPATCHED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REJECTED')),
    CONSTRAINT chk_incident_severity CHECK (severity_level IS NULL OR severity_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_incident_priority CHECK (priority_level IS NULL OR priority_level IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT'))
);

CREATE INDEX idx_incident_status ON incident(status);
CREATE INDEX idx_incident_disaster_type ON incident(disaster_type_id);
CREATE INDEX idx_incident_location ON incident(latitude, longitude);

-- ============================================================================
-- 5. INCIDENT_MEDIA
-- Evidence images, videos, and documents attached to an incident.
-- ============================================================================
CREATE TABLE incident_media (
    media_id SERIAL PRIMARY KEY,
    incident_id INTEGER NOT NULL REFERENCES incident(incident_id) ON DELETE CASCADE,
    uploaded_by INTEGER NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    media_type VARCHAR(30) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    caption VARCHAR(255) NULL,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_media_type CHECK (media_type IN ('IMAGE', 'VIDEO', 'DOCUMENT', 'AUDIO'))
);

CREATE INDEX idx_media_incident ON incident_media(incident_id);

-- ============================================================================
-- 6. AI_RECOMMENDATION
-- AI decision-support outputs with Human-in-the-Loop review fields.
-- ============================================================================
CREATE TABLE ai_recommendation (
    recommendation_id SERIAL PRIMARY KEY,
    incident_id INTEGER NOT NULL REFERENCES incident(incident_id) ON DELETE CASCADE,
    model_name VARCHAR(100) NOT NULL,
    severity_score DECIMAL(5, 2) NOT NULL,
    priority_level VARCHAR(30) NOT NULL,
    recommended_resources TEXT NULL,
    reasoning TEXT NULL,
    confidence_score DECIMAL(5, 2) NOT NULL,
    review_status VARCHAR(30) NOT NULL DEFAULT 'PENDING_REVIEW',
    reviewed_by INTEGER NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    reviewed_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ai_severity_score CHECK (severity_score BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_ai_confidence_score CHECK (confidence_score BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_ai_priority CHECK (priority_level IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    CONSTRAINT chk_ai_review_status CHECK (review_status IN ('PENDING_REVIEW', 'APPROVED', 'MODIFIED', 'REJECTED'))
);

CREATE INDEX idx_ai_rec_incident ON ai_recommendation(incident_id);

-- ============================================================================
-- 7. RESOURCE
-- General consumable supplies and relief provisions (food, water, kits).
-- ============================================================================
CREATE TABLE resource (
    resource_id SERIAL PRIMARY KEY,
    resource_name VARCHAR(150) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    quantity_available INTEGER NOT NULL DEFAULT 0,
    location VARCHAR(255) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
    contact_number VARCHAR(20) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_resource_qty CHECK (quantity_available >= 0),
    CONSTRAINT chk_resource_status CHECK (status IN ('AVAILABLE', 'DEPLETED', 'RESERVED', 'MAINTENANCE'))
);

-- ============================================================================
-- 8. VEHICLE
-- Emergency response vehicles (ambulances, rescue boats, fire tenders).
-- ============================================================================
CREATE TABLE vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_number VARCHAR(50) NOT NULL UNIQUE,
    vehicle_type VARCHAR(100) NOT NULL,
    capacity INTEGER NOT NULL DEFAULT 1,
    current_location VARCHAR(255) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
    assigned_team VARCHAR(150) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_vehicle_capacity CHECK (capacity >= 1),
    CONSTRAINT chk_vehicle_status CHECK (status IN ('AVAILABLE', 'DISPATCHED', 'ON_SCENE', 'MAINTENANCE', 'DECOMMISSIONED'))
);

-- ============================================================================
-- 9. EQUIPMENT
-- Specialized rescue gear and machinery (boats, cutters, generators).
-- ============================================================================
CREATE TABLE equipment (
    equipment_id SERIAL PRIMARY KEY,
    equipment_name VARCHAR(150) NOT NULL,
    equipment_type VARCHAR(100) NOT NULL,
    quantity_total INTEGER NOT NULL DEFAULT 1,
    quantity_available INTEGER NOT NULL DEFAULT 1,
    condition_status VARCHAR(50) NOT NULL DEFAULT 'OPERATIONAL',
    location VARCHAR(255) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_equipment_qty_total CHECK (quantity_total >= 0),
    CONSTRAINT chk_equipment_qty_avail CHECK (quantity_available >= 0),
    CONSTRAINT chk_equipment_qty_bounds CHECK (quantity_available <= quantity_total),
    CONSTRAINT chk_equipment_condition CHECK (condition_status IN ('OPERATIONAL', 'NEEDS_REPAIR', 'DAMAGED', 'UNDER_INSPECTION'))
);

-- ============================================================================
-- 10. RESOURCE_ASSIGNMENT
-- Operational dispatch of resources, vehicles, or equipment to incidents.
-- ============================================================================
CREATE TABLE resource_assignment (
    assignment_id SERIAL PRIMARY KEY,
    incident_id INTEGER NOT NULL REFERENCES incident(incident_id) ON DELETE CASCADE,
    resource_id INTEGER NULL REFERENCES resource(resource_id) ON DELETE RESTRICT,
    vehicle_id INTEGER NULL REFERENCES vehicle(vehicle_id) ON DELETE RESTRICT,
    equipment_id INTEGER NULL REFERENCES equipment(equipment_id) ON DELETE RESTRICT,
    quantity_assigned INTEGER NOT NULL DEFAULT 1,
    assigned_by INTEGER NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_time TIMESTAMPTZ NULL,
    end_time TIMESTAMPTZ NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ASSIGNED',
    notes TEXT NULL,
    CONSTRAINT chk_assignment_qty CHECK (quantity_assigned >= 1),
    CONSTRAINT chk_single_assignment_target CHECK (
        (resource_id IS NOT NULL)::INTEGER +
        (vehicle_id IS NOT NULL)::INTEGER +
        (equipment_id IS NOT NULL)::INTEGER = 1
    ),
    CONSTRAINT chk_assignment_status CHECK (status IN ('ASSIGNED', 'IN_TRANSIT', 'ON_SITE', 'RELEASED', 'CANCELLED'))
);

CREATE INDEX idx_assignment_incident ON resource_assignment(incident_id);

-- ============================================================================
-- 11. HOSPITAL
-- Medical centers, trauma emergency capacity, and available ICU/trauma beds.
-- ============================================================================
CREATE TABLE hospital (
    hospital_id SERIAL PRIMARY KEY,
    hospital_name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    contact_number VARCHAR(20) NULL,
    emergency_capacity INTEGER NOT NULL DEFAULT 0,
    available_beds INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'OPERATIONAL',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_hospital_lat CHECK (latitude BETWEEN -90.0000000 AND 90.0000000),
    CONSTRAINT chk_hospital_lon CHECK (longitude BETWEEN -180.0000000 AND 180.0000000),
    CONSTRAINT chk_hospital_capacity CHECK (emergency_capacity >= 0),
    CONSTRAINT chk_hospital_beds CHECK (available_beds >= 0),
    CONSTRAINT chk_hospital_bed_bounds CHECK (available_beds <= emergency_capacity),
    CONSTRAINT chk_hospital_status CHECK (status IN ('OPERATIONAL', 'NEAR_CAPACITY', 'FULL', 'DIVERTING', 'CLOSED'))
);

CREATE INDEX idx_hospital_location ON hospital(latitude, longitude);

-- ============================================================================
-- 12. SHELTER
-- Evacuation shelters, community relief camps, and safe zones.
-- ============================================================================
CREATE TABLE shelter (
    shelter_id SERIAL PRIMARY KEY,
    shelter_name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    contact_number VARCHAR(20) NULL,
    capacity INTEGER NOT NULL DEFAULT 0,
    current_occupancy INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_shelter_lat CHECK (latitude BETWEEN -90.0000000 AND 90.0000000),
    CONSTRAINT chk_shelter_lon CHECK (longitude BETWEEN -180.0000000 AND 180.0000000),
    CONSTRAINT chk_shelter_capacity CHECK (capacity >= 0),
    CONSTRAINT chk_shelter_occupancy CHECK (current_occupancy >= 0),
    CONSTRAINT chk_shelter_bounds CHECK (current_occupancy <= capacity),
    CONSTRAINT chk_shelter_status CHECK (status IN ('ACTIVE', 'FULL', 'INACTIVE', 'STANDBY'))
);

CREATE INDEX idx_shelter_location ON shelter(latitude, longitude);

-- ============================================================================
-- 13. NOTIFICATION
-- System alerts, emergency broadcasts, and operational dispatch orders.
-- ============================================================================
CREATE TABLE notification (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    incident_id INTEGER NULL REFERENCES incident(incident_id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMPTZ NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'UNREAD',
    CONSTRAINT chk_notification_type CHECK (notification_type IN ('INCIDENT_ALERT', 'DISPATCH_ORDER', 'STATUS_UPDATE', 'SYSTEM_ADVISORY')),
    CONSTRAINT chk_notification_status CHECK (status IN ('UNREAD', 'READ', 'FAILED'))
);

CREATE INDEX idx_notification_user ON notification(user_id, status);

-- ============================================================================
-- 14. REPORT_LOG
-- Audit records of generated formal disaster response and analytical reports.
-- ============================================================================
CREATE TABLE report_log (
    report_id SERIAL PRIMARY KEY,
    generated_by INTEGER NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    report_type VARCHAR(100) NOT NULL,
    report_title VARCHAR(200) NOT NULL,
    parameters TEXT NULL,
    file_path VARCHAR(500) NOT NULL,
    generated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_report_type CHECK (report_type IN ('INCIDENT_SUMMARY', 'RESOURCE_UTILIZATION', 'CASUALTY_REPORT', 'AUDIT_SUMMARY'))
);

-- ============================================================================
-- 15. AUDIT_LOG
-- Append-only system activity and security mutation tracking.
-- ============================================================================
CREATE TABLE audit_log (
    audit_id SERIAL PRIMARY KEY,
    user_id INTEGER NULL REFERENCES users(user_id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER NULL,
    old_values TEXT NULL,
    new_values TEXT NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_audit_action CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'SECURITY_OVERRIDE'))
);

CREATE INDEX idx_audit_table ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_time ON audit_log(created_at);

-- ============================================================================
-- 16. SYSTEM_SETTINGS
-- Configurable platform thresholds, API timeouts, and emergency triggers.
-- ============================================================================
CREATE TABLE system_settings (
    setting_id SERIAL PRIMARY KEY,
    updated_by INTEGER NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description VARCHAR(255) NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
