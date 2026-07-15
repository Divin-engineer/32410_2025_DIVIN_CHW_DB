-- =====================================================================
-- PHASE V: TABLE IMPLEMENTATION
-- Database/User : 32410_2025_Divin_CHW_DB
-- Project       : CHW Outreach & Referral Tracking System
-- Run as        : the project user (32410_2025_Divin_CHW_DB), Oracle 21c XE
-- =====================================================================

-- ---------------------------------------------------------------------
-- Clean start (safe to re-run). Ignore ORA-00942 the first time you run this.
-- ---------------------------------------------------------------------
DROP TABLE audit_log PURGE;
DROP TABLE referrals PURGE;
DROP TABLE visit_topics PURGE;
DROP TABLE visits PURGE;
DROP TABLE health_facilities PURGE;
DROP TABLE health_topics PURGE;
DROP TABLE households PURGE;
DROP TABLE chws PURGE;
DROP TABLE public_holidays PURGE;
DROP TABLE system_config PURGE;
DROP TABLE districts PURGE;

DROP SEQUENCE district_seq;
DROP SEQUENCE chw_seq;
DROP SEQUENCE household_seq;
DROP SEQUENCE topic_seq;
DROP SEQUENCE facility_seq;
DROP SEQUENCE visit_seq;
DROP SEQUENCE referral_seq;
DROP SEQUENCE holiday_seq;
DROP SEQUENCE audit_seq;

-- ---------------------------------------------------------------------
-- SEQUENCES
-- ---------------------------------------------------------------------
CREATE SEQUENCE district_seq  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE chw_seq       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE household_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE topic_seq     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE facility_seq  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE visit_seq     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE referral_seq  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE holiday_seq   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE audit_seq     START WITH 1 INCREMENT BY 1;

-- ---------------------------------------------------------------------
-- REFERENCE TABLES
-- ---------------------------------------------------------------------
CREATE TABLE districts (
    district_id     NUMBER          NOT NULL,
    district_name   VARCHAR2(100)   NOT NULL,
    CONSTRAINT pk_districts PRIMARY KEY (district_id),
    CONSTRAINT uq_district_name UNIQUE (district_name)
);

CREATE TABLE health_topics (
    topic_id        NUMBER          NOT NULL,
    topic_name      VARCHAR2(100)   NOT NULL,
    category        VARCHAR2(50),
    CONSTRAINT pk_health_topics PRIMARY KEY (topic_id),
    CONSTRAINT uq_topic_name UNIQUE (topic_name)
);

CREATE TABLE public_holidays (
    holiday_id      NUMBER          NOT NULL,
    holiday_date    DATE            NOT NULL,
    holiday_name    VARCHAR2(100),
    CONSTRAINT pk_public_holidays PRIMARY KEY (holiday_id),
    CONSTRAINT uq_holiday_date UNIQUE (holiday_date)
);

CREATE TABLE system_config (
    config_key      VARCHAR2(50)    NOT NULL,
    config_value    VARCHAR2(50)    NOT NULL,
    CONSTRAINT pk_system_config PRIMARY KEY (config_key)
);

-- ---------------------------------------------------------------------
-- CORE MASTER TABLES
-- ---------------------------------------------------------------------
CREATE TABLE chws (
    chw_id          NUMBER          NOT NULL,
    first_name      VARCHAR2(50)    NOT NULL,
    last_name       VARCHAR2(50)    NOT NULL,
    phone           VARCHAR2(15),
    date_joined     DATE            DEFAULT SYSDATE NOT NULL,
    status          VARCHAR2(10)    DEFAULT 'ACTIVE' NOT NULL,
    district_id     NUMBER          NOT NULL,
    CONSTRAINT pk_chws PRIMARY KEY (chw_id),
    CONSTRAINT uq_chw_phone UNIQUE (phone),
    CONSTRAINT ck_chw_status CHECK (status IN ('ACTIVE','INACTIVE')),
    CONSTRAINT fk_chw_district FOREIGN KEY (district_id) REFERENCES districts(district_id)
);

CREATE TABLE households (
    household_id    NUMBER          NOT NULL,
    head_name       VARCHAR2(100)   NOT NULL,
    phone           VARCHAR2(15),
    village         VARCHAR2(100),
    cell            VARCHAR2(100),
    sector          VARCHAR2(100),
    district_id     NUMBER          NOT NULL,
    CONSTRAINT pk_households PRIMARY KEY (household_id),
    CONSTRAINT fk_household_district FOREIGN KEY (district_id) REFERENCES districts(district_id)
);

CREATE TABLE health_facilities (
    facility_id     NUMBER          NOT NULL,
    facility_name   VARCHAR2(150)   NOT NULL,
    facility_type   VARCHAR2(50)    NOT NULL,
    phone           VARCHAR2(15),
    district_id     NUMBER          NOT NULL,
    CONSTRAINT pk_health_facilities PRIMARY KEY (facility_id),
    CONSTRAINT ck_facility_type CHECK (facility_type IN ('HEALTH_CENTER','HOSPITAL','CLINIC','DISPENSARY')),
    CONSTRAINT fk_facility_district FOREIGN KEY (district_id) REFERENCES districts(district_id)
);

-- ---------------------------------------------------------------------
-- TRANSACTIONAL TABLES
-- ---------------------------------------------------------------------
CREATE TABLE visits (
    visit_id        NUMBER          NOT NULL,
    chw_id          NUMBER          NOT NULL,
    household_id    NUMBER          NOT NULL,
    visit_date      DATE            DEFAULT SYSDATE NOT NULL,
    visit_notes     VARCHAR2(500),
    CONSTRAINT pk_visits PRIMARY KEY (visit_id),
    CONSTRAINT fk_visit_chw FOREIGN KEY (chw_id) REFERENCES chws(chw_id),
    CONSTRAINT fk_visit_household FOREIGN KEY (household_id) REFERENCES households(household_id),
    CONSTRAINT ck_visit_date CHECK (visit_date IS NOT NULL)
);

CREATE TABLE visit_topics (
    visit_id        NUMBER          NOT NULL,
    topic_id        NUMBER          NOT NULL,
    CONSTRAINT pk_visit_topics PRIMARY KEY (visit_id, topic_id),
    CONSTRAINT fk_vt_visit FOREIGN KEY (visit_id) REFERENCES visits(visit_id) ON DELETE CASCADE,
    CONSTRAINT fk_vt_topic FOREIGN KEY (topic_id) REFERENCES health_topics(topic_id)
);

CREATE TABLE referrals (
    referral_id     NUMBER          NOT NULL,
    visit_id        NUMBER          NOT NULL,
    facility_id     NUMBER          NOT NULL,
    referral_date   DATE            DEFAULT SYSDATE NOT NULL,
    reason          VARCHAR2(200)   NOT NULL,
    status          VARCHAR2(20)    DEFAULT 'PENDING' NOT NULL,
    follow_up_date  DATE,
    follow_up_notes VARCHAR2(500),
    CONSTRAINT pk_referrals PRIMARY KEY (referral_id),
    CONSTRAINT fk_referral_visit FOREIGN KEY (visit_id) REFERENCES visits(visit_id),
    CONSTRAINT fk_referral_facility FOREIGN KEY (facility_id) REFERENCES health_facilities(facility_id),
    CONSTRAINT ck_referral_status CHECK (status IN ('PENDING','COMPLETED','CANCELLED'))
);

-- ---------------------------------------------------------------------
-- AUDIT TABLE (Phase VII)
-- ---------------------------------------------------------------------
CREATE TABLE audit_log (
    audit_id        NUMBER          NOT NULL,
    table_name      VARCHAR2(30)    NOT NULL,
    operation       VARCHAR2(10)    NOT NULL,
    record_id       VARCHAR2(50),
    changed_by      VARCHAR2(50)    NOT NULL,
    changed_date    DATE            DEFAULT SYSDATE NOT NULL,
    old_value       VARCHAR2(1000),
    new_value       VARCHAR2(1000),
    CONSTRAINT pk_audit_log PRIMARY KEY (audit_id),
    CONSTRAINT ck_audit_operation CHECK (operation IN ('INSERT','UPDATE','DELETE'))
);

COMMIT;
