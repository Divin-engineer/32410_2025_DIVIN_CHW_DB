-- =====================================================================
-- PHASE VI: PL/SQL PROGRAMMING (package)
-- Database/User : 32410_2025_Divin_CHW_DB
-- =====================================================================

SET SERVEROUTPUT ON;

-- ---------------------------------------------------------------------
-- PACKAGE SPEC
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_chw_outreach AS

    -- Register a referral for an existing visit
    PROCEDURE add_referral (
        p_visit_id    IN  referrals.visit_id%TYPE,
        p_facility_id IN  referrals.facility_id%TYPE,
        p_reason      IN  referrals.reason%TYPE,
        p_referral_id OUT referrals.referral_id%TYPE
    );

    -- Overall completion rate for one CHW (wraps the standalone function)
    FUNCTION get_completion_rate (p_chw_id IN chws.chw_id%TYPE) RETURN NUMBER;

    -- Cursor-driven report: referral totals grouped by district
    PROCEDURE district_summary_report;

    -- Demo helper: turn the Phase VII weekday/holiday business rule ON or OFF
    PROCEDURE set_dml_restriction (p_enabled IN VARCHAR2);

END pkg_chw_outreach;
/

-- ---------------------------------------------------------------------
-- PACKAGE BODY
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_chw_outreach AS

    PROCEDURE add_referral (
        p_visit_id    IN  referrals.visit_id%TYPE,
        p_facility_id IN  referrals.facility_id%TYPE,
        p_reason      IN  referrals.reason%TYPE,
        p_referral_id OUT referrals.referral_id%TYPE
    ) IS
        v_visit_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_visit_exists FROM visits WHERE visit_id = p_visit_id;

        IF v_visit_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Visit ID ' || p_visit_id || ' does not exist.');
        END IF;

        p_referral_id := referral_seq.NEXTVAL;

        INSERT INTO referrals (referral_id, visit_id, facility_id, referral_date, reason, status)
        VALUES (p_referral_id, p_visit_id, p_facility_id, SYSDATE, p_reason, 'PENDING');

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Referral ' || p_referral_id || ' created (PENDING).');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('add_referral failed: ' || SQLERRM);
            RAISE;
    END add_referral;


    FUNCTION get_completion_rate (p_chw_id IN chws.chw_id%TYPE) RETURN NUMBER IS
    BEGIN
        RETURN fn_referral_completion_rate(p_chw_id);
    END get_completion_rate;


    PROCEDURE district_summary_report IS
        CURSOR c_district_summary IS
            SELECT d.district_name,
                   COUNT(r.referral_id)                                              AS total_referrals,
                   SUM(CASE WHEN r.status = 'COMPLETED' THEN 1 ELSE 0 END)           AS completed,
                   SUM(CASE WHEN r.status = 'PENDING'   THEN 1 ELSE 0 END)           AS pending
              FROM districts d
              JOIN chws c        ON c.district_id = d.district_id
              JOIN visits v      ON v.chw_id = c.chw_id
              JOIN referrals r   ON r.visit_id = v.visit_id
             GROUP BY d.district_name
             ORDER BY total_referrals DESC;

        v_any_rows BOOLEAN := FALSE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Referral Summary by District ===');
        FOR rec IN c_district_summary LOOP
            v_any_rows := TRUE;
            DBMS_OUTPUT.PUT_LINE(
                rec.district_name || ' | Total: ' || rec.total_referrals ||
                ' | Completed: ' || rec.completed || ' | Pending: ' || rec.pending
            );
        END LOOP;

        IF NOT v_any_rows THEN
            DBMS_OUTPUT.PUT_LINE('No referral data available yet.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No referral data available yet.');
    END district_summary_report;


    PROCEDURE set_dml_restriction (p_enabled IN VARCHAR2) IS
    BEGIN
        IF UPPER(p_enabled) NOT IN ('Y','N') THEN
            RAISE_APPLICATION_ERROR(-20021, 'p_enabled must be ''Y'' or ''N''.');
        END IF;

        UPDATE system_config
           SET config_value = UPPER(p_enabled)
         WHERE config_key = 'ENFORCE_DML_RESTRICTION';

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Weekday/holiday DML restriction is now: ' || UPPER(p_enabled));
    END set_dml_restriction;

END pkg_chw_outreach;
/

-- ---------------------------------------------------------------------
-- Demo calls
-- ---------------------------------------------------------------------
DECLARE
    v_ref_id NUMBER;
BEGIN
    pkg_chw_outreach.add_referral(2, 3, 'Demo referral via package', v_ref_id);
    DBMS_OUTPUT.PUT_LINE('Package completion rate for CHW 3: ' || pkg_chw_outreach.get_completion_rate(3) || '%');
    pkg_chw_outreach.district_summary_report;
END;
/
