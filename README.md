# CDA-MVP

Minimum viable prototype datasources for Content Data Accessibility ([T234701](https://phabricator.wikimedia.org/T234701))

**Phab**: [T266714](https://phabricator.wikimedia.org/T266714)

| Query | Purpose |
|:------|:--------|
| [create_top_viewed.hql](queries/create_top_viewed.hql) | Creates `bearloga.top_viewed` table, loaded with [mvp-100-us.ipynb](mvp-100-us.ipynb) |
| [create_cda_edits_mvp.hql](queries/create_cda_edits_mvp.hql) | Creates `bearloga.cda_edits` table |
| [cda_edits.hql](queries/cda_edits.hql) | Loads `bearloga.cda_edits` table with data based on `bearloga.top_viewed` and `wmf.mediawiki_history` |
| [create_cda_views_mvp.hql](queries/create_cda_views_mvp.hql) | Creates `bearloga.cda_views` table |
| [cda_views.hql](queries/cda_views.hql) | Loads `bearloga.cda_views` table with data based on `bearloga.top_viewed` and `wmf.pageview_hourly` |
