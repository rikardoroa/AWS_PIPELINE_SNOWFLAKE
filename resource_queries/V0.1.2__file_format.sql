USE DATABASE {{ database }};
USE SCHEMA {{ schema }};

CREATE OR REPLACE FILE FORMAT report_incidents_format
TYPE = 'JSON'
STRIP_OUTER_ARRAY = TRUE;