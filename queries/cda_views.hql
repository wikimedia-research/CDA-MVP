-- Parameters:
--     month      -- Month (in 2020) to compute the aggregation for.

-- Usage:
--     hive -f queries/cda_views.hql -d month=10

SET mapred.job.queue.name=nice;

WITH total_views AS (
    SELECT
      project, year, month, day, access_method, agent_type,
      SUM(view_count) AS total_count
    FROM wmf.pageview_hourly
    WHERE year = 2020 AND month = ${month}
      -- AND day = 15 AND hour = 12 -- for debugging/prototyping
      AND namespace_id = 0
      AND country_code = 'US'
      AND project IN('en.wikipedia', 'zh.wikipedia', 'es.wikipedia')
    GROUP BY project, year, month, day, access_method, agent_type
), daily_views AS (
    SELECT
      tv.project, tv.wiki_db, tv.page_id, tv.page_title,
      pvh.year, pvh.month, pvh.day,
      pvh.access_method, pvh.agent_type,
      SUM(pvh.view_count) AS view_count
    FROM bearloga.top_viewed tv
    LEFT JOIN wmf.pageview_hourly pvh ON (
      tv.project = pvh.project
      AND tv.page_id = pvh.page_id
      AND pvh.year = 2020
      AND pvh.month = ${month}
      -- AND pvh.day = 15 AND pvh.hour = 12 -- for debugging/prototyping
    )
    WHERE pvh.namespace_id = 0
      AND pvh.country_code = 'US'
      -- AND pvh.agent_type = 'user'
    GROUP BY tv.project, tv.wiki_db, tv.page_id, tv.page_title,
      pvh.year, pvh.month, pvh.day,
      pvh.access_method, pvh.agent_type
)

INSERT OVERWRITE TABLE bearloga.cda_views_mvp
PARTITION(month=${month})

SELECT
  dv.project, dv.wiki_db, dv.page_id, dv.page_title, dv.access_method, dv.agent_type,
  CONCAT(dv.year, '-', LPAD(dv.month, 2, '0'), '-', LPAD(dv.day, 2, '0')) AS `date`,
  dv.view_count,
  LN(dv.view_count / total_views.total_count) AS ln_proportion,
  COLLECT_SET(ato.topic) AS topics,
  COLLECT_SET(tc.main_topic) AS main_topics,
  COLLECT_SET(tc.sub_topic) AS sub_topics
FROM daily_views dv
LEFT JOIN total_views ON (
  dv.project = total_views.project
  AND dv.year = total_views.year
  AND dv.month = total_views.month
  AND dv.day = total_views.day
  AND dv.access_method = total_views.access_method
  AND dv.agent_type = total_views.agent_type
)
LEFT JOIN isaacj.article_topics_outlinks_2020_09 ato ON (
  dv.wiki_db =  ato.wiki_db
  AND dv.page_id = ato.pageid
  AND ato.wiki_db IN('enwiki', 'zhwiki', 'eswiki') -- for partition predicate
)
LEFT JOIN cchen.topic_component tc ON ato.topic = tc.topic
WHERE ato.score >= 0.5
GROUP BY dv.project, dv.wiki_db, dv.page_id, dv.page_title, dv.access_method, dv.agent_type,
  CONCAT(dv.year, '-', LPAD(dv.month, 2, '0'), '-', LPAD(dv.day, 2, '0')),
  dv.view_count, LN(dv.view_count / total_views.total_count)
;
