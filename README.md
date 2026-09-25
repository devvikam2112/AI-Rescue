# AI-Rescue: Intelligent Disaster Response & Resource Coordination Platform

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Java](https://img.shields.io/badge/Java-21_LTS-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.x-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![React](https://img.shields.io/badge/React-18+-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://react.dev/)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)

**AI-Rescue** is an intelligent, mission-critical disaster management and emergency resource coordination platform designed to bridge the operational gap between citizen distress reporting, municipal emergency authorities, and on-ground rescue responders during natural and urban catastrophes.

---

## 📌 Executive Summary & Architecture Mindset

* **Developer & Architect**: Dev Vikam
* **Domain**: Municipal Disaster Management, Smart City Coordination & Emergency Logistics
* **Engineering Paradigm**: High-integrity relational architecture with a strict **Human-in-the-Loop (HITL)** AI decision-support pipeline. The AI serves as an advisory copilot for emergency commanders, evaluating hazard severity and recommending equipment/medical allocations without ever executing unverified, autonomous dispatches.

---

## 🏛️ System Architecture

AI-Rescue is architected as a modular, three-tier enterprise solution:

```
[ Citizen Web / Mobile Portal ]   [ Emergency Operations Command (EOC) ]   [ Responder Field App ]
                   \                              |                              /
                    \                             |                             /
                     ▼                            ▼                            ▼
                 =============================================================
                               Spring Boot 3.x REST API Gateway
                 =============================================================
                                  |                         |
                                  ▼                         ▼
                    [ Core Business Services ]    [ AI Advisory Engine ]
                    - Incident Verification        - Severity Indexing
                    - Atomic Resource Dispatch     - Priority Ranking
                    - Hospital/Shelter Routing     - Resource Estimation
                    - JWT / RBAC Security
                                  |
                                  ▼
                 =============================================================
                            PostgreSQL 16+ Relational Engine
                             (Strict 16-Table Frozen V1)
                 =============================================================
```

---

## 🗄️ Relational Database Architecture (16 Tables)

The database schema is strictly normalized and frozen across 16 foundational entities:

1. **`role`**: Security clearance levels (`ADMIN`, `OFFICER`, `RESPONDER`, `CITIZEN`).
2. **`users`**: User profiles with BCrypt password hashing and role assignments.
3. **`disaster_type`**: Master taxonomy of natural and urban hazard categories.
4. **`incident`**: Core operational incident records with GPS coordinates and lifecycle status tracking.
5. **`incident_media`**: Photographic and documentary evidence attached to distress reports.
6. **`ai_recommendation`**: Algorithmic severity scores, priority ratings, and human-in-the-loop review audits.
7. **`resource`**: Consumable relief materials, ration packets, and portable emergency kits.
8. **`vehicle`**: Motorized fleet units (ambulances, rescue boats, fire engines).
9. **`equipment`**: Specialized rescue gear, concrete cutters, and dewatering pumps.
10. **`resource_assignment`**: Atomic allocation tracking with single-target check constraints and quantity counters.
11. **`hospital`**: Emergency trauma medical centers, available bed counts, and surge capacities.
12. **`shelter`**: Evacuation centers, community relief halls, and safe zone capacities.
13. **`notification`**: Real-time dispatch alerts, hazard warnings, and citizen advisories.
14. **`report_log`**: Formal incident summary and resource utilization audit generation records.
15. **`audit_log`**: Append-only security mutation audit trail tracking data modifications.
16. **`system_settings`**: Dynamic operational thresholds, dispatch timeouts, and clustering radii.

---

## 🚀 Repository Layout

```
AI-Rescue/
├── backend/               # Spring Boot 3.x Java 21 REST API Microservice
├── frontend/              # React.js 18+ Vite Web Application
├── ai-service/            # Python 3.12 AI Severity & Priority Recommendation Service
├── database/              # PostgreSQL 16+ DDL scripts & sample seed data
│   ├── schema.sql         # Official 16-table schema with constraints & indexes
│   └── seed.sql           # Realistic operational test data
├── docs/                  # Academic specifications, IEEE test cases, diagrams
│   ├── chapters/          # Academic project report chapters 1 through 4
│   ├── TEST CASES.docx    # Formal master test specification (31+ test cases)
│   ├── table.csv          # Standardized PostgreSQL data dictionary
│   └── FlowChart_Readable.png
├── .gitignore             # Comprehensive build & secret protection file
└── README.md              # Engineering documentation & project handbook
```

---

## 🛠️ Getting Started Locally

### 1. Prerequisites
* **Java 21 LTS** (`java -version`)
* **Node.js v20+** & npm (`node -v`)
* **Python 3.12+** (`python --version`)
* **PostgreSQL 16+** (`psql -V`)

### 2. Database Initialization
```bash
# Connect to PostgreSQL and create database
psql -U postgres -c "CREATE DATABASE ai_rescue_db;"

# Execute schema and seed data
psql -U postgres -d ai_rescue_db -f database/schema.sql
psql -U postgres -d ai_rescue_db -f database/seed.sql
```

---

## 📋 Development Roadmap

- [x] **Phase 1**: Full System Audit & Legacy Architecture Rectification
- [x] **Phase 2**: Final 16-Table PostgreSQL Schema Freeze & Test Case Specification
- [ ] **Phase 3**: Clean Monorepo Scaffolding & Git Lifecycle Initialization
- [ ] **Phase 4**: Spring Security 6 & JWT Authentication Engine (RBAC)
- [ ] **Phase 5**: Citizen Incident Reporting & Evidence Upload Pipeline
- [ ] **Phase 6**: Officer Incident Verification & Human-in-the-Loop Review
- [ ] **Phase 7**: AI Decision-Support Microservice Integration
- [ ] **Phase 8**: Atomic Resource Dispatch & Inventory Decrementing
- [ ] **Phase 9**: Hospital & Evacuation Shelter Coordination
- [ ] **Phase 10**: Real-Time Operational Notifications
- [ ] **Phase 11**: Executive Analytics Dashboard & Report Generation
- [ ] **Phase 12**: Penetration Defense, Verification Testing & Viva Defense Preparation

---

## 📄 License & Intellectual Property
*Academic Major Field Project & Enterprise Prototype.*  
© 2026 Dev Vikam. All rights reserved.
