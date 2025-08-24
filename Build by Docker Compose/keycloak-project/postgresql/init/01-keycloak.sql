-- 01-keycloak.sql
-- Idempotent DB extensions + basic hardening

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- جلوگیری از ایجاد آبجکت در public توسط همه
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
