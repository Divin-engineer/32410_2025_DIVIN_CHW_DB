# 32410_2025_Divin_CHW_DB
## CHW Outreach & Referral Tracking System — DPR400210 Capstone

## 1. What this covers
| File | Phase |
|---|---|
| `..._03_ERD_Normalization.md` | Phase III — ER diagram + 3NF walkthrough |
| `..._04_ddl_tables.sql` | Phase V — tables, sequences, all constraint types |
| `..._05_sample_data.sql` | Phase V — meaningful sample data |
| `..._06_procedures_functions.sql` | Phase VI — procedures, functions, cursor, exceptions |
| `..._07_package_outreach.sql` | Phase VI — `pkg_chw_outreach` package |
| `..._08_triggers_audit.sql` | Phase VII — compound business-rule triggers + audit trigger |
| `..._09_innovation_powerbi_views.sql` | Innovation — reporting views |

You said Phase IV (DB/user creation) is already done under `32410_2025_Divin_CHW_DB`, and you'll handle Phase VIII yourself — this set picks up from there.

## 2. Run order (VS Code Oracle extension, connected as `32410_2025_Divin_CHW_DB`)
1. `04_ddl_tables.sql`
2. `05_sample_data.sql`
3. `06_procedures_functions.sql`
4. `07_package_outreach.sql`
5. `08_triggers_audit.sql`
6. `09_innovation_powerbi_views.sql`

Run each file top to bottom. Every `CREATE OR REPLACE` is safe to re-run if you need to fix something.

## 3. About the business rule (Phase VII)
Per the exam brief, VISITS and REFERRALS are blocked from INSERT/UPDATE/DELETE on weekdays and public holidays — allowed only on weekends that aren't holidays. Since that would get in your way while building the project, it's OFF by default (`system_config.ENFORCE_DML_RESTRICTION = 'N'`).

- To demo it live: `EXEC pkg_chw_outreach.set_dml_restriction('Y');` then try an UPDATE on a weekday — you'll get `ORA-20030`/`ORA-20031`.
- Turn it back off after: `EXEC pkg_chw_outreach.set_dml_restriction('N');`
- The audit trigger on REFERRALS is independent of this toggle and always logs to `AUDIT_LOG`.

## 4. Innovation — Power BI dashboard (simplest path)
The four views in `09_innovation_powerbi_views.sql` are already the "hard part" — one row per chart. You don't need to write any Python or install APEX.

**Simplest option (no driver setup):**
1. Run each view's `SELECT * FROM view_name;` in your Oracle extension.
2. Right-click the result grid → Export → CSV (or copy into Excel).
3. Open Power BI Desktop → **Get Data → Text/CSV** (or **Excel**) → import each of the 4 files.
4. Build 4 simple visuals:
   - Bar chart: `vw_referral_completion_by_chw` → CHW name vs. completion_rate_pct
   - Bar/map chart: `vw_coverage_gap_by_district` → district_name vs. households_with_gap_30d
   - Pie chart: `vw_topic_frequency` → topic_name vs. times_covered
   - Line chart: `vw_monthly_visit_trends` → visit_month vs. visit_count

**If you want a live connection instead** (optional, more setup): Power BI Desktop → **Get Data → Database → Oracle database** → enter your TNS/host string → select the 4 views → Import. This needs the Oracle client installed on your machine, so the CSV route above is the easier one to demo on exam day.

Either way, in your presentation you can say: *"I exposed my reporting logic as SQL views, then visualized them in Power BI to show referral completion by CHW, coverage gaps by district, topic frequency, and monthly visit trends."* That satisfies the innovation requirement.

## 5. GitHub structure suggestion
```
32410_2025_Divin_CHW_DB/
├── README.md
├── docs/
│   └── 03_ERD_Normalization.md
├── sql/
│   ├── 04_ddl_tables.sql
│   ├── 05_sample_data.sql
│   ├── 06_procedures_functions.sql
│   ├── 07_package_outreach.sql
│   ├── 08_triggers_audit.sql
│   └── 09_innovation_powerbi_views.sql
└── screenshots/
```
