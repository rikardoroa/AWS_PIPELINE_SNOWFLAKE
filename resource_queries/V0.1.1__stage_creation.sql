USE DATABASE {{ database }};
USE SCHEMA {{ schema }};

CREATE OR REPLACE STAGE fire_incidents_stage
  URL={{ bucket }}
  DIRECTORY = ( ENABLE = TRUE,  AUTO_REFRESH = true )
  STORAGE_INTEGRATION = report_incidents_aws_integration;