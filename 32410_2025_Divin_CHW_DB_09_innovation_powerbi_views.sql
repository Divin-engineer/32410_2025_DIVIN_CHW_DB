-- =====================================================================
-- INNOVATION COMPONENT: Power BI-ready reporting views (8 marks)
-- Database/User : 32410_2025_Divin_CHW_DB
--
-- These are plain SQL views. No PL/SQL, no extra install needed to build
-- them. You then feed their results into Power BI Desktop (see README
-- for the two ways to connect: live Oracle connector or simple CSV export).
-- =====================================================================

CREATE OR REPLACE VIEW vw_referral_completion_by_chw AS
SELECT c.chw_id,
       c.first_name || ' ' || c.last_name           AS chw_name,
       d.district_name,
       COUNT(r.referral_id)                          AS total_referrals,
       SUM(CASE WHEN r.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_referrals,
       ROUND(SUM(CASE WHEN r.status = 'COMPLETED' THEN 1 ELSE 0 END)
             / NULLIF(COUNT(r.referral_id),0) * 100, 2)        AS completion_rate_pct
  FROM chws c
  JOIN districts d   ON d.district_id = c.district_id
  LEFT JOIN visits v ON v.chw_id = c.chw_id
  LEFT JOIN referrals r ON r.visit_id = v.visit_id
 GROUP BY c.chw_id, c.first_name, c.last_name, d.district_name;

CREATE OR REPLACE VIEW vw_coverage_gap_by_district AS
SELECT d.district_name,
       COUNT(DISTINCT h.household_id)                                        AS total_households,
       SUM(CASE WHEN NVL(TRUNC(SYSDATE) - hh_last.last_visit, 9999) >= 30
                THEN 1 ELSE 0 END)                                           AS households_with_gap_30d
  FROM districts d
  JOIN households h ON h.district_id = d.district_id
  LEFT JOIN (
        SELECT household_id, MAX(visit_date) AS last_visit
          FROM visits
         GROUP BY household_id
        ) hh_last ON hh_last.household_id = h.household_id
 GROUP BY d.district_name;

CREATE OR REPLACE VIEW vw_topic_frequency AS
SELECT t.topic_name,
       t.category,
       COUNT(*) AS times_covered
  FROM visit_topics vt
  JOIN health_topics t ON t.topic_id = vt.topic_id
 GROUP BY t.topic_name, t.category
 ORDER BY times_covered DESC;

CREATE OR REPLACE VIEW vw_monthly_visit_trends AS
SELECT TO_CHAR(visit_date, 'YYYY-MM') AS visit_month,
       COUNT(*)                       AS visit_count
  FROM visits
 GROUP BY TO_CHAR(visit_date, 'YYYY-MM')
 ORDER BY visit_month;

-- Quick sanity check
SELECT * FROM vw_referral_completion_by_chw;
SELECT * FROM vw_coverage_gap_by_district;
SELECT * FROM vw_topic_frequency;
SELECT * FROM vw_monthly_visit_trends;
