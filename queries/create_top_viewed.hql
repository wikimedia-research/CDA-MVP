-- Usage:
-- hive -f queries/create_top_viewed.hql

DROP TABLE IF EXISTS bearloga.top_viewed;

CREATE TABLE IF NOT EXISTS bearloga.top_viewed (
  `project`     string  COMMENT 'Project name (e.g. en.wikipedia)',
  `wiki_db`     string  COMMENT 'Database name (e.g. enwiki)',
  `page_id`     int     COMMENT 'Wiki article ID, unique to project/wiki_db',
  `page_title`  string  COMMENT 'Wiki article title'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY "\t"
;

LOAD DATA LOCAL INPATH "data/top_x00.tsv"
OVERWRITE INTO TABLE bearloga.top_viewed
;
