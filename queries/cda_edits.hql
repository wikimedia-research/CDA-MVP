-- Parameters:
--     month      -- Month (in 2020) to compute the aggregation for.
--     snapshot   -- MediaWiki History snapshot to use.

-- Usage:
--     hive -f queries/cda_edits.hql -d snapshot=2020-10 -d month=10

SET mapred.job.queue.name=nice;

WITH daily_edits AS (
  SELECT
      tv.project, tv.wiki_db, tv.page_id, tv.page_title,
      mwh.event_user_is_anonymous AS user_is_anonymous,
      SIZE(event_user_is_bot_by_historical) > 0 AS user_is_bot,
      mwh.revision_is_identity_reverted AS is_reverted,
      SUBSTR(mwh.event_timestamp, 1, 10) AS `date`,
      COUNT(1) AS edit_count
    FROM bearloga.top_viewed tv
    LEFT JOIN wmf.mediawiki_history mwh ON (
      tv.wiki_db = mwh.wiki_db
      AND tv.page_id = mwh.page_id
      AND mwh.snapshot = '${snapshot}'
    )
    WHERE mwh.event_entity = 'revision'
      AND mwh.page_namespace = 0
      AND SUBSTR(mwh.event_timestamp, 1, 7) = CONCAT('2020-', LPAD(${month}, 2, '0'))
      -- AND SUBSTR(mwh.event_timestamp, 1, 10) = CONCAT('2020-', LPAD(${month}, 2, '0'), '-31') -- for debugging/prototyping
    GROUP BY tv.project, tv.wiki_db, tv.page_id, tv.page_title,
      mwh.event_user_is_anonymous,
      SIZE(event_user_is_bot_by_historical) > 0,
      mwh.revision_is_identity_reverted,
      SUBSTR(mwh.event_timestamp, 1, 10)
)

INSERT OVERWRITE TABLE bearloga.cda_edits_mvp
PARTITION(month=${month})

SELECT
  de.project, de.wiki_db, de.page_id, de.page_title,
  de.user_is_anonymous, de.user_is_bot, de.is_reverted,
  de.date, de.edit_count,
  COLLECT_SET(ato.topic) AS topics,
  COLLECT_SET(tc.main_topic) AS main_topics,
  COLLECT_SET(tc.sub_topic) AS sub_topics
FROM daily_edits de
LEFT JOIN isaacj.article_topics_outlinks_2020_09 ato ON (
  de.wiki_db =  ato.wiki_db
  AND de.page_id = ato.pageid
  AND ato.wiki_db IN('enwiki', 'zhwiki', 'eswiki') -- for partition predicate
)
LEFT JOIN cchen.topic_component tc ON ato.topic = tc.topic
WHERE ato.score >= 0.5
GROUP BY de.project, de.wiki_db, de.page_id, de.page_title,
  de.user_is_anonymous, de.user_is_bot, de.is_reverted,
  de.date, de.edit_count
;
