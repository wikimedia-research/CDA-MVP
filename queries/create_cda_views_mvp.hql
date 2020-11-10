-- Usage:
--     hive -f queries/create_cda_views_mvp.hql

DROP TABLE IF EXISTS bearloga.cda_views_mvp;

CREATE EXTERNAL TABLE IF NOT EXISTS bearloga.cda_views_mvp (
  `project`         string         COMMENT 'Project name (e.g. en.wikipedia)',
  `wiki_db`         string         COMMENT 'Database name (e.g. enwiki)',
  `page_id`         int            COMMENT 'Article ID, unique to project/wiki_db',
  `page_title`      string         COMMENT 'Wiki article title',
  `access_method`   string         COMMENT 'Method used to access the pages, can be desktop, mobile web, or mobile app',
  `agent_type`      string         COMMENT 'Agent accessing the pages, can be spider, user, or automated',
  `date`            string         COMMENT 'Date of the pageview counts, remember to cast to DATE()',
  `view_count`      int            COMMENT 'Total number of page views',
  `ln_proportion`   double         COMMENT 'Proportion of total pageviews for that day, stored as a natural log for technical reasons so use EXP()',
  `topics`          array<string>  COMMENT 'All topics for page predicted by topic model (e.g. ["History_and_Society.Politics_and_government"])',
  `main_topics`     array<string>  COMMENT 'All main topics for page predicted by topic model (e.g. ["History_and_Society"])',
  `sub_topics`      array<string>  COMMENT 'All sub topics for page predicted by topic model (e.g. ["Politics_and_government"])'
)
COMMENT 'Content Data Accessibility MVP table for pageviews (Phab:T266714)'
PARTITIONED BY (
  `month`           int            COMMENT 'Unpadded month of pageviews'
)
STORED AS PARQUET
LOCATION '/user/bearloga/cda_mvp/view_counts'
;