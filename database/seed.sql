-- ============================================================================
-- AI-Rescue: Sample Seed Data for Testing & Demonstration
-- Target: PostgreSQL 16+
-- ============================================================================

-- 1. ROLES
INSERT INTO role (role_name, description) VALUES
('ADMIN', 'Full system administration, settings, and user access control'),
('OFFICER', 'Emergency coordinator, incident verifier, AI reviewer, and resource dispatcher'),
('RESPONDER', 'Field rescue worker, team lead, ambulance paramedic, or volunteer responder'),
('CITIZEN', 'General public user reporting incidents and receiving local advisories');

-- 2. USERS (passwords hashed with BCrypt for 'Admin@123', 'Officer@123', 'Responder@123', 'Citizen@123')
INSERT INTO users (role_id, full_name, email, phone, password_hash, address, city, state, status) VALUES
(1, 'System Administrator', 'admin@airescue.org', '+919820011223', '$2a$12$e8hYqXqN0L9f9gL7sY1H.O7eH1gR8w5q3J.xN2pZ7uV9lKm5b8qXe', 'Disaster Control HQ', 'Mumbai', 'Maharashtra', 'ACTIVE'),
(2, 'Chief Officer Rajesh Sharma', 'officer.sharma@airescue.org', '+919820022334', '$2a$12$e8hYqXqN0L9f9gL7sY1H.O7eH1gR8w5q3J.xN2pZ7uV9lKm5b8qXe', 'Emergency Response Centre, Ward F', 'Mumbai', 'Maharashtra', 'ACTIVE'),
(3, 'Rescue Lead Vikram Patil', 'responder.vikram@airescue.org', '+919820033445', '$2a$12$e8hYqXqN0L9f9gL7sY1H.O7eH1gR8w5q3J.xN2pZ7uV9lKm5b8qXe', 'NDRF Battalion Base', 'Mumbai', 'Maharashtra', 'ACTIVE'),
(4, 'Aarav Mehta (Citizen)', 'aarav.mehta@gmail.com', '+919820044556', '$2a$12$e8hYqXqN0L9f9gL7sY1H.O7eH1gR8w5q3J.xN2pZ7uV9lKm5b8qXe', 'Flat 402, Sea View Apartments, Dadar', 'Mumbai', 'Maharashtra', 'ACTIVE');

-- 3. DISASTER TYPES
INSERT INTO disaster_type (type_name, description, is_active) VALUES
('Urban Flooding', 'Severe waterlogging, submerged roads, trapped civilians due to heavy rainfall', TRUE),
('Building Collapse', 'Structural failure of residential or commercial complexes requiring rubble clearance', TRUE),
('Fire Emergency', 'Commercial, industrial, or residential structure fire requiring fire tenders', TRUE),
('Cyclone / Severe Storm', 'High-velocity windstorm causing uprooted trees, power grid failure, and structural damage', TRUE),
('Chemical / Industrial Leak', 'Hazardous toxic material emission requiring specialized HAZMAT containment', TRUE);

-- 4. HOSPITALS (Mumbai Real Coordinates)
INSERT INTO hospital (hospital_name, address, latitude, longitude, contact_number, emergency_capacity, available_beds, status) VALUES
('KEM Hospital (King Edward Memorial)', 'Parel, Mumbai', 18.9984000, 72.8427000, '+912224107000', 250, 45, 'OPERATIONAL'),
('Sion Hospital (Lokmanya Tilak Memorial)', 'Sion, Mumbai', 19.0380000, 72.8600000, '+912224076381', 200, 28, 'OPERATIONAL'),
('Lilavati Hospital & Research Centre', 'Bandra West, Mumbai', 19.0514000, 72.8295000, '+912226751000', 120, 15, 'OPERATIONAL'),
('Cooper Hospital (H.B.T. Medical College)', 'Juhu, Vile Parle, Mumbai', 19.1075000, 72.8360000, '+912226207254', 180, 35, 'OPERATIONAL');

-- 5. SHELTERS
INSERT INTO shelter (shelter_name, address, latitude, longitude, contact_number, capacity, current_occupancy, status) VALUES
('Dadar Municipal Sports Complex', 'Dadar West, Mumbai', 19.0178000, 72.8478000, '+912224301122', 500, 60, 'ACTIVE'),
('Kurla Relief Camp & Community Hall', 'Kurla West, Mumbai', 19.0726000, 72.8797000, '+912225032233', 350, 110, 'ACTIVE'),
('Andheri Sports Complex Relief Hall', 'Andheri West, Mumbai', 19.1302000, 72.8272000, '+912226733344', 600, 0, 'STANDBY');

-- 6. RESOURCES (Consumables & Relief Packs)
INSERT INTO resource (resource_name, resource_type, description, quantity_available, location, status, contact_number) VALUES
('Emergency Food & Ration Packets', 'Consumable Ration', '72-hour non-perishable high-protein ration boxes', 1500, 'Central Warehouse Kurla', 'AVAILABLE', '+912225010011'),
('Purified Drinking Water 20L Cans', 'Potable Water', 'Sealed safe drinking water containers', 800, 'Central Warehouse Kurla', 'AVAILABLE', '+912225010012'),
('Emergency Medical Trauma First-Aid Kits', 'Medical Supplies', 'Dressings, burn creams, tourniquets, antiseptic', 250, 'KEM Hospital Relief Depot', 'AVAILABLE', '+912224107050'),
('Thermal Fleece Blankets', 'Bedding / Shelter', 'Cold and rain protection blankets for evacuees', 1200, 'Dadar Relief Depot', 'AVAILABLE', '+912224301199');

-- 7. VEHICLES
INSERT INTO vehicle (vehicle_number, vehicle_type, capacity, current_location, status, assigned_team) VALUES
('MH-01-AX-1001', 'Advanced Life Support Ambulance', 4, 'KEM Hospital Base', 'AVAILABLE', 'Paramedic Unit Alpha'),
('MH-01-AX-1002', 'Advanced Life Support Ambulance', 4, 'Sion Hospital Base', 'AVAILABLE', 'Paramedic Unit Bravo'),
('MH-02-EZ-2020', 'Inflatable Rubber Rescue Boat (IRB)', 8, 'Dadar Disaster Control Depot', 'AVAILABLE', 'NDRF Water Rescue Team 1'),
('MH-03-FD-5050', 'Heavy Fire Tender & Water Bowser', 6, 'Byculla Fire Command Station', 'AVAILABLE', 'Fire Brigade Squad 4');

-- 8. EQUIPMENT
INSERT INTO equipment (equipment_name, equipment_type, quantity_total, quantity_available, condition_status, location) VALUES
('High-Capacity Dewatering Water Pump', 'Flood Control', 12, 10, 'OPERATIONAL', 'Dadar Pumping Station'),
('Hydraulic Concrete Cutter & Spreader', 'Urban Search & Rescue', 6, 6, 'OPERATIONAL', 'Byculla Fire Command Station'),
('Heavy-Duty Portable Diesel Generator (15kVA)', 'Power Generation', 15, 12, 'OPERATIONAL', 'Central Warehouse Kurla'),
('Inflatable Life Jackets & Rescue Ropes Set', 'Water Rescue Gear', 100, 90, 'OPERATIONAL', 'Dadar Disaster Control Depot');

-- 9. SYSTEM SETTINGS
INSERT INTO system_settings (updated_by, setting_key, setting_value, description) VALUES
(1, 'AI_AUTO_ANALYSIS_ENABLED', 'true', 'Automatically triggers AI severity scoring upon officer verification'),
(1, 'MAX_REPORT_RADIUS_METERS', '500', 'Radius in meters for clustering duplicate incident reports'),
(1, 'EMERGENCY_DISPATCH_TIMEOUT_SECONDS', '300', 'Maximum wait time for responder acknowledgement before escalation'),
(1, 'SMS_GATEWAY_ACTIVE', 'false', 'Enable or disable outbound citizen SMS notification gateway');
