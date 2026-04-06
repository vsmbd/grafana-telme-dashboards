# GOALS

This repository exists to define and generate Grafana dashboards for the Telme + ClickHouse environment.

For the current milestone, the scope is limited to 3 dashboards only, all placed directly under a single Grafana folder named `Telme`.

---

## Primary goals

### 1. Create a clean first dashboard set
The initial dashboard suite should be small, coherent, and easy to reason about.

### 2. Keep all dashboards inside one Grafana folder
All dashboards must live directly under the `Telme` folder in Grafana.
No nested subfolders should be used in this first version.

### 3. Support both overview and engineering storytelling
The initial set should include:
- 2 overview dashboards
- 1 engineering dashboard

### 4. Be grounded in the real schema
Dashboard definitions must reflect actual or intentionally planned data available from:
- `app_sessions`
- `records`
- derived views if needed for function-level timing

### 5. Generate screenshot-worthy dashboards
The dashboards should be clean enough to use in:
- resumes
- LinkedIn outreach
- portfolio case studies
- demo walkthroughs

### 6. Keep the first milestone realistic
Do not over-design the first version.
It is better to have 3 strong dashboards than 10 weak or speculative ones.

### 7. Make dashboard naming stable
Dashboard names, IDs, and generated JSON filenames should be consistent and reusable.

### 8. Preserve room for future expansion
The current structure should allow more dashboards to be added later without forcing a redesign.

---

## Success criteria

The work is successful if:
- the `Telme` folder exists in Grafana
- all 3 dashboards are top-level dashboards inside that folder
- each dashboard has a clear purpose
- each dashboard can be generated cleanly from the spec
- the resulting dashboards are suitable for screenshots and demos
