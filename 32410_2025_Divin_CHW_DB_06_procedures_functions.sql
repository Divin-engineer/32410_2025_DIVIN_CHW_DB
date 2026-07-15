-- =====================================================================
-- PHASE VI: PL/SQL PROGRAMMING (standalone objects)
-- Database/User : 32410_2025_Divin_CHW_DB
-- =====================================================================

SET SERVEROUTPUT ON;

-- ---------------------------------------------------------------------
-- PROCEDURE 1: sp_register_visit
-- Parameterized procedure with an OUT parameter + transaction control.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_register_visit (
    p_chw_id        IN  chws.chw_id%TYPE,
    p_household_id  IN  households.household_id%TYPE,
    p_notes         IN  visits.visit_notes%TYPE DEFAULT NULL,
    p_visit_id      OUT visits.visit_id%TYPE
) IS
    v_chw_exists NUMBER;
    v_hh_exists  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_chw_exists FROM chws WHERE chw_id = p_chw_id;
    SELECT COUNT(*) INTO v_hh_exists  FROM households WHERE household_id = p_household_id;

    IF v_chw_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'CHW ID ' || p_chw_id || ' does not exist.');
    ELSIF v_hh_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Household ID ' || p_household_id || ' does not exist.');
    END IF;

    p_visit_id := visit_seq.NEXTVAL;

    INSERT INTO visits (visit_id, chw_id, household_id, visit_date, visit_notes)
    VALUES (p_visit_id, p_chw_id, p_household_id, SYSDATE, p_notes);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Visit ' || p_visit_id || ' registered successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('sp_register_visit failed: ' || SQLERRM);
        RAISE;
END sp_register_visit;
/

-- ---------------------------------------------------------------------
-- PROCEDURE 2: sp_update_referral_status
-- Custom exception + RAISE_APPLICATION_ERROR + COMMIT/ROLLBACK.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_update_referral_status (
    p_referral_id IN referrals.referral_id%TYPE,
    p_new_status  IN referrals.status%TYPE,
    p_notes       IN referrals.follow_up_notes%TYPE DEFAULT NULL
) IS
    e_invalid_status EXCEPTION;
BEGIN
    IF p_new_status NOT IN ('PENDING','COMPLETED','CANCELLED') THEN
        RAISE e_invalid_status;
    END IF;

    UPDATE referrals
       SET status          = p_new_status,
           follow_up_date  = SYSDATE,
           follow_up_notes = NVL(p_notes, follow_up_notes)
     WHERE referral_id = p_referral_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Referral ID ' || p_referral_id || ' not found.');
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Referral ' || p_referral_id || ' updated to ' || p_new_status || '.');
EXCEPTION
    WHEN e_invalid_status THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20013, 'Invalid status. Use PENDING, COMPLETED or CANCELLED.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('sp_update_referral_status failed: ' || SQLERRM);
        RAISE;
END sp_update_referral_status;
/

-- ---------------------------------------------------------------------
-- FUNCTION 1: fn_referral_completion_rate
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_referral_completion_rate (
    p_chw_id IN chws.chw_id%TYPE
) RETURN NUMBER IS
    v_total     NUMBER;
    v_completed NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total
      FROM referrals r JOIN visits v ON v.visit_id = r.visit_id
     WHERE v.chw_id = p_chw_id;

    IF v_total = 0 THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*) INTO v_completed
      FROM referrals r JOIN visits v ON v.visit_id = r.visit_id
     WHERE v.chw_id = p_chw_id AND r.status = 'COMPLETED';

    RETURN ROUND((v_completed / v_total) * 100, 2);
END fn_referral_completion_rate;
/

-- ---------------------------------------------------------------------
-- FUNCTION 2: fn_days_since_last_visit
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_days_since_last_visit (
    p_household_id IN households.household_id%TYPE
) RETURN NUMBER IS
    v_last_visit DATE;
BEGIN
    SELECT MAX(visit_date) INTO v_last_visit
      FROM visits
     WHERE household_id = p_household_id;

    IF v_last_visit IS NULL THEN
        RETURN NULL; -- never visited
    END IF;

    RETURN TRUNC(SYSDATE) - TRUNC(v_last_visit);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END fn_days_since_last_visit;
/

-- ---------------------------------------------------------------------
-- PROCEDURE 3: sp_list_coverage_gaps
-- Uses an EXPLICIT CURSOR to loop through households not visited
-- within p_days_threshold days (or never visited at all).
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_list_coverage_gaps (
    p_days_threshold IN NUMBER DEFAULT 30
) IS
    CURSOR c_gaps IS
        SELECT h.household_id, h.head_name, h.village, d.district_name,
               MAX(v.visit_date)                    AS last_visit_date,
               TRUNC(SYSDATE) - MAX(v.visit_date)    AS days_since_visit
          FROM households h
          JOIN districts d  ON d.district_id = h.district_id
          LEFT JOIN visits v ON v.household_id = h.household_id
         GROUP BY h.household_id, h.head_name, h.village, d.district_name
        HAVING NVL(TRUNC(SYSDATE) - MAX(v.visit_date), 9999) >= p_days_threshold
         ORDER BY days_since_visit DESC NULLS FIRST;

    v_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Coverage Gap Report (>= ' || p_days_threshold || ' days) ===');

    FOR r IN c_gaps LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            r.head_name || ' | ' || r.village || ' | ' || r.district_name ||
            ' | Last visit: ' || NVL(TO_CHAR(r.last_visit_date,'YYYY-MM-DD'), 'NEVER') ||
            ' | Days gap: ' || NVL(TO_CHAR(r.days_since_visit), 'N/A')
        );
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No coverage gaps found for this threshold.');
    END IF;
END sp_list_coverage_gaps;
/

-- ---------------------------------------------------------------------
-- Quick manual test block (run this to see everything work together)
-- ---------------------------------------------------------------------
DECLARE
    v_new_visit_id NUMBER;
BEGIN
    sp_register_visit(2, 3, 'Test visit from demo block', v_new_visit_id);
    DBMS_OUTPUT.PUT_LINE('New visit id: ' || v_new_visit_id);
    DBMS_OUTPUT.PUT_LINE('CHW #1 completion rate: ' || fn_referral_completion_rate(1) || '%');
    sp_list_coverage_gaps(20);
END;
/
