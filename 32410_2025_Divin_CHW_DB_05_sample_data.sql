-- =====================================================================
-- Sample / meaningful test data for 32410_2025_Divin_CHW_DB
-- Run this AFTER 04_ddl_tables.sql
-- =====================================================================

-- SYSTEM_CONFIG: controls whether the weekday/holiday business rule (Phase VII)
-- is actively enforced. Keep it 'N' while you are building/testing, switch to
-- 'Y' when you want to demonstrate the rule live.
INSERT INTO system_config VALUES ('ENFORCE_DML_RESTRICTION', 'N');

-- DISTRICTS
INSERT INTO districts VALUES (district_seq.NEXTVAL, 'Gasabo');
INSERT INTO districts VALUES (district_seq.NEXTVAL, 'Kicukiro');
INSERT INTO districts VALUES (district_seq.NEXTVAL, 'Bugesera');
INSERT INTO districts VALUES (district_seq.NEXTVAL, 'Nyagatare');

SELECT * FROM DISTRICTS;

-- HEALTH_TOPICS
INSERT INTO health_topics VALUES (topic_seq.NEXTVAL, 'Family Planning', 'SRH');
INSERT INTO health_topics VALUES (topic_seq.NEXTVAL, 'Menstrual Hygiene', 'SRH');
INSERT INTO health_topics VALUES (topic_seq.NEXTVAL, 'Antenatal Care', 'Maternal Health');
INSERT INTO health_topics VALUES (topic_seq.NEXTVAL, 'STI Prevention', 'SRH');
INSERT INTO health_topics VALUES (topic_seq.NEXTVAL, 'Postnatal Care', 'Maternal Health');
INSERT INTO health_topics VALUES (topic_seq.NEXTVAL, 'Nutrition Counselling', 'General Health');

SELECT * FROM HEALTH_TOPICS;

-- PUBLIC_HOLIDAYS (Rwanda, sample dates for 2026)
INSERT INTO public_holidays VALUES (holiday_seq.NEXTVAL, DATE '2026-01-01', 'New Year');
INSERT INTO public_holidays VALUES (holiday_seq.NEXTVAL, DATE '2026-04-07', 'Genocide Memorial Day');
INSERT INTO public_holidays VALUES (holiday_seq.NEXTVAL, DATE '2026-07-01', 'Independence Day');
INSERT INTO public_holidays VALUES (holiday_seq.NEXTVAL, DATE '2026-07-04', 'Liberation Day');


SELECT * FROM PUBLIC_HOLIDAYS;
-- CHWS
INSERT INTO chws VALUES (chw_seq.NEXTVAL, 'Aline', 'Uwase', '0788111001', DATE '2024-02-01', 'ACTIVE', 1);
INSERT INTO chws VALUES (chw_seq.NEXTVAL, 'Eric', 'Habimana', '0788111002', DATE '2024-03-15', 'ACTIVE', 1);
INSERT INTO chws VALUES (chw_seq.NEXTVAL, 'Claudine', 'Mukamana', '0788111003', DATE '2024-01-20', 'ACTIVE', 2);
INSERT INTO chws VALUES (chw_seq.NEXTVAL, 'Jean', 'Bosco', '0788111004', DATE '2024-05-10', 'ACTIVE', 3);
INSERT INTO chws VALUES (chw_seq.NEXTVAL, 'Solange', 'Ingabire', '0788111005', DATE '2024-06-01', 'INACTIVE', 4);

SELECT * FROM CHWS;

-- HOUSEHOLDS
INSERT INTO households VALUES (household_seq.NEXTVAL, 'Bakundukize Emmanuel', '0722001001', 'Kinyinya', 'Cell A', 'Sector 1', 1);
INSERT INTO households VALUES (household_seq.NEXTVAL, 'Mukashema Alice', '0722001002', 'Kimironko', 'Cell B', 'Sector 1', 1);
INSERT INTO households VALUES (household_seq.NEXTVAL, 'Nsengimana Paul', '0722001003', 'Gikondo', 'Cell C', 'Sector 2', 2);
INSERT INTO households VALUES (household_seq.NEXTVAL, 'Uwamahoro Grace', '0722001004', 'Nyarugunga', 'Cell D', 'Sector 2', 2);
INSERT INTO households VALUES (household_seq.NEXTVAL, 'Ndayisenga Vincent', '0722001005', 'Nyamata', 'Cell E', 'Sector 3', 3);
INSERT INTO households VALUES (household_seq.NEXTVAL, 'Mutesi Diane', '0722001006', 'Rilima', 'Cell F', 'Sector 3', 3);
INSERT INTO households VALUES (household_seq.NEXTVAL, 'Habyarimana Jules', '0722001007', 'Rukomo', 'Cell G', 'Sector 4', 4);
INSERT INTO households VALUES (household_seq.NEXTVAL, 'Nyiraneza Josiane', '0722001008', 'Katabagemu', 'Cell H', 'Sector 4', 4);


SELECT * FROM HOUSEHOLDS; 

-- HEALTH_FACILITIES
INSERT INTO health_facilities VALUES (facility_seq.NEXTVAL, 'Kinyinya Health Center', 'HEALTH_CENTER', '0788222001', 1);
INSERT INTO health_facilities VALUES (facility_seq.NEXTVAL, 'Kigali University Hospital', 'HOSPITAL', '0788222002', 1);
INSERT INTO health_facilities VALUES (facility_seq.NEXTVAL, 'Gikondo Clinic', 'CLINIC', '0788222003', 2);
INSERT INTO health_facilities VALUES (facility_seq.NEXTVAL, 'Nyamata District Hospital', 'HOSPITAL', '0788222004', 3);

SELECT * FROM HEALTH_FACILITIES;

-- VISITS
INSERT INTO visits VALUES (visit_seq.NEXTVAL, 1, 1, DATE '2026-06-05', 'Routine SRH outreach visit');
INSERT INTO visits VALUES (visit_seq.NEXTVAL, 1, 2, DATE '2026-06-10', 'Follow-up on family planning');
INSERT INTO visits VALUES (visit_seq.NEXTVAL, 2, 1, DATE '2026-05-01', 'First visit of the quarter');
INSERT INTO visits VALUES (visit_seq.NEXTVAL, 3, 3, DATE '2026-06-15', 'Antenatal care check');
INSERT INTO visits VALUES (visit_seq.NEXTVAL, 3, 4, DATE '2026-04-20', 'General SRH education');
INSERT INTO visits VALUES (visit_seq.NEXTVAL, 4, 5, DATE '2026-06-20', 'STI prevention session');
INSERT INTO visits VALUES (visit_seq.NEXTVAL, 4, 6, DATE '2026-03-11', 'Postnatal follow-up');
INSERT INTO visits VALUES (visit_seq.NEXTVAL, 1, 7, DATE '2026-06-25', 'New household registration visit');

SELECT * FROM VISITS; 

-- VISIT_TOPICS
INSERT INTO visit_topics VALUES (1, 1);
INSERT INTO visit_topics VALUES (1, 2);
INSERT INTO visit_topics VALUES (2, 1);
INSERT INTO visit_topics VALUES (3, 4);
INSERT INTO visit_topics VALUES (4, 3);
INSERT INTO visit_topics VALUES (5, 6);
INSERT INTO visit_topics VALUES (6, 4);
INSERT INTO visit_topics VALUES (7, 5);
INSERT INTO visit_topics VALUES (8, 1);
INSERT INTO visit_topics VALUES (8, 2);

SELECT * FROM VISIT_TOPICS;

-- REFERRALS
INSERT INTO referrals VALUES (referral_seq.NEXTVAL, 1, 1, DATE '2026-06-05', 'Needs contraceptive counselling', 'COMPLETED', DATE '2026-06-08', 'Attended, method provided');
INSERT INTO referrals VALUES (referral_seq.NEXTVAL, 3, 2, DATE '2026-05-01', 'Referred for further gynecological exam', 'PENDING', NULL, NULL);
INSERT INTO referrals VALUES (referral_seq.NEXTVAL, 4, 3, DATE '2026-06-15', 'High-risk pregnancy, needs ANC follow-up', 'COMPLETED', DATE '2026-06-18', 'ANC visit completed');
INSERT INTO referrals VALUES (referral_seq.NEXTVAL, 6, 4, DATE '2026-06-20', 'Suspected STI, needs testing', 'CANCELLED', DATE '2026-06-22', 'Household relocated');
INSERT INTO referrals VALUES (referral_seq.NEXTVAL, 7, 4, DATE '2026-03-11', 'Postnatal complication check', 'COMPLETED', DATE '2026-03-14', 'Resolved');
INSERT INTO referrals VALUES (referral_seq.NEXTVAL, 8, 1, DATE '2026-06-25', 'New household baseline screening', 'PENDING', NULL, NULL);

SELECT * FROM REFERRALS;

COMMIT;
