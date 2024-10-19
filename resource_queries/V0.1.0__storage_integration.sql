USE DATABASE {{ database }};
USE SCHEMA {{ schema }};


CREATE OR REPLACE STORAGE INTEGRATION report_incidents_aws_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  STORAGE_AWS_ROLE_ARN =  {{ role }} 
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ({{ bucket }} );