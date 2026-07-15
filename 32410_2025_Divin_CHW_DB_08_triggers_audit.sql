-- =====================================================================
-- PHASE VII: ADVANCED DATABASE PROGRAMMING
-- Database/User : 32410_2025_Divin_CHW_DB
-- Business Rule : block INSERT/UPDATE/DELETE on VISITS and REFERRALS
--                 during weekdays (Mon-Fri) AND on public holidays.
--                 (Allowed only on Saturday/Sunday that is not a holiday.)
-- =====================================================================

SET SERVEROUTPUT ON;

-- ---------------------------------------------------------------------
-- Helper function used by the compound triggers below.
-- Reads SYSTEM_CONFIG so you can flip the rule OFF for development/demo
-- via: EXEC pkg_chw_outreach.set_dml_restriction('N');
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_is_modification_allowed RETURN VARCHAR2 IS
    v_enforce       system_config.config_value%TYPE;
    v_day           VARCHAR2(3);
    v_holiday_count NUMBER;
BEGIN
    SELECT config_value INTO v_enforce
      FROM system_config
     WHERE config_key = 'ENFORCE_DML_RESTRICTION';

    IF v_enforce = 'N' THEN
        RETURN 'Y';
    END IF;

    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    IF v_day IN ('MON','TUE','WED','THU','FRI') THEN
        RETURN 'N';
    END IF;

    SELECT COUNT(*) INTO v_holiday_count
      FROM public_holidays
     WHERE holiday_date = TRUNC(SYSDATE);

    IF v_holiday_count > 0 THEN
        RETURN 'N';
    END IF;

    RETURN 'Y';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Y'; -- fail open if the config row is missing
END fn_is_modification_allowed;
/

-- ---------------------------------------------------------------------
-- COMPOUND TRIGGER 1: business rule on VISITS
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_visits_business_rule
FOR INSERT OR UPDATE OR DELETE ON visits
COMPOUND TRIGGER

    v_allowed VARCHAR2(1) := 'Y';

    BEFORE STATEMENT IS
    BEGIN
        v_allowed := fn_is_modification_allowed;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF v_allowed = 'N' THEN
            RAISE_APPLICATION_ERROR(-20030,
                'VISITS cannot be modified on weekdays or public holidays. Allowed only on weekends.');
        END IF;
    END BEFORE EACH ROW;

END trg_visits_business_rule;
/

-- ---------------------------------------------------------------------
-- COMPOUND TRIGGER 2: business rule on REFERRALS
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_referrals_business_rule
FOR INSERT OR UPDATE OR DELETE ON referrals
COMPOUND TRIGGER

    v_allowed VARCHAR2(1) := 'Y';

    BEFORE STATEMENT IS
    BEGIN
        v_allowed := fn_is_modification_allowed;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        IF v_allowed = 'N' THEN
            RAISE_APPLICATION_ERROR(-20031,
                'REFERRALS cannot be modified on weekdays or public holidays. Allowed only on weekends.');
        END IF;
    END BEFORE EACH ROW;

END trg_referrals_business_rule;
/

-- ---------------------------------------------------------------------
-- AUDIT TRIGGER: row-level AFTER trigger on REFERRALS
-- Captures who changed what and when into AUDIT_LOG.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_referrals_audit
AFTER INSERT OR UPDATE OR DELETE ON referrals
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_value VARCHAR2(1000);
    v_new_value VARCHAR2(1000);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_value := 'STATUS=' || :NEW.status || ', FACILITY_ID=' || :NEW.facility_id;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_value := 'STATUS=' || :OLD.status;
        v_new_value := 'STATUS=' || :NEW.status;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_value := 'STATUS=' || :OLD.status || ', FACILITY_ID=' || :OLD.facility_id;
    END IF;

    INSERT INTO audit_log (audit_id, table_name, operation, record_id, changed_by, changed_date, old_value, new_value)
    VALUES (
        audit_seq.NEXTVAL, 'REFERRALS', v_operation,
        NVL(TO_CHAR(:NEW.referral_id), TO_CHAR(:OLD.referral_id)),
        USER, SYSDATE, v_old_value, v_new_value
    );
END trg_referrals_audit;
/

-- ---------------------------------------------------------------------
-- HOW TO TEST
-- ---------------------------------------------------------------------
-- 1) Rule is OFF by default (system_config = 'N'), so normal INSERTs/UPDATEs
--    work every day while you build and test the project.
-- 2) To demonstrate the rule live during presentation:
--       EXEC pkg_chw_outreach.set_dml_restriction('Y');
--    Then try an UPDATE on a weekday -> it will raise ORA-20030/20031.
--    Turn it back off afterwards:
--       EXEC pkg_chw_outreach.set_dml_restriction('N');
-- 3) The audit trail is always active (independent of the toggle):
--       UPDATE referrals SET status = 'COMPLETED' WHERE referral_id = 2;
--       SELECT * FROM audit_log ORDER BY changed_date DESC;
