-- Usage:
--     hive -f queries/create_cda_edits_mvp.hql

DROP TABLE IF EXISTS bearloga.cda_edits_mvp;

CREATE EXTERNAL TABLE IF NOT EXISTS bearloga.cda_edits_mvp (
  `project`            string         COMMENT 'Project name (e.g. en.wikipedia)',
  `wiki_db`            string         COMMENT 'Database name (e.g. enwiki)',
  `page_id`            int            COMMENT 'Article ID, unique to project/wiki_db',
  `page_title`         string         COMMENT 'Wiki article title',
  `user_is_anonymous`  string         COMMENT 'Whether edits were made by a registered user or anonymously',
  `user_is_bot`        string         COMMENT 'Whether edits were made by a known bot',
  `is_reverted`        string         COMMENT 'Whether edits have been reverted',
  `date`               string         COMMENT 'Date of the edit counts, remember to cast to DATE()',
  `edit_count`         int            COMMENT 'Total number of edits made',
  `topics`             array<string>  COMMENT 'All topics for page predicted by topic model (e.g. ["History_and_Society.Politics_and_government"])',
  `main_topics`        array<string>  COMMENT 'All main topics for page predicted by topic model (e.g. ["History_and_Society"])',
  `sub_topics`         array<string>  COMMENT 'All sub topics for page predicted by topic model (e.g. ["Politics_and_government"])'
)
COMMENT 'Content Data Accessibility MVP table for edit counts (Phab:T266714)'
PARTITIONED BY (
  `month`              int            COMMENT 'Unpadded month of edits'
)
STORED AS PARQUET
LOCATION '/user/bearloga/cda_mvp/edit_counts'
;