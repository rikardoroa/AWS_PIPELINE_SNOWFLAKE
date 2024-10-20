
# AWS Snowflake Pipeline for Fire Incidents Data Capture

## AWS CLI Installation and Bucket Configuration for Terraform

### 1. AWS CLI Installation

The AWS CLI is essential for managing credentials and configuring the environment. Follow the steps below for installation:

1. **Install AWS CLI**:
   ```bash
   brew install awscli
   ```

2. **Verify Installation**:
   ```bash
   aws --version
   ```

3. **Windows Installation**:
   For Windows users, refer to the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

4. **Terraform Environment Configuration**:
   
   - **Check if the Bucket Exists**:
        ```bash
        aws s3api head-bucket --bucket your_bucket
        ```
        If you receive the error `An error occurred (404) when calling the HeadBucket operation: Not Found`, the bucket does not exist and can be created.

   - **Create DynamoDB Table for Terraform State Locking**:
        ```bash
        aws dynamodb create-table --table-name terraform-lock-table --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region your_region
        ```
        Replace `your_region` with the actual AWS region (e.g., `us-east-2`).

   - **Create S3 Bucket for Terraform State**:
        ```bash
        aws s3api create-bucket --bucket your_bucket --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2
        ```
        Replace `your_bucket` with a unique bucket name.

   - **Apply Bucket Policies**:
        ```bash
        aws s3api put-public-access-block --bucket your_bucket --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
        ```

## Bucket Configuration for AWS Lambda and AWS Glue Resources

### 1. Bucket Creation for Lambda and Glue

The `lambda_module` in the Terraform environment contains a `buckets.json` file. Ensure each bucket name is unique to avoid errors:

```json
{
  "buckets": [
      { "name": "dev-fire-incidents-dt" },
      { "name": "dev-fire-incidents-dt-all" },
      { "name": "dev-fire-incidents-dt-glue-python" }
  ]
}
```

### 2. Changing Bucket Names

To modify bucket names, update the `outputs.tf` file in the `lambda_module`:

```hcl
output "glue_bucket" {
    value = aws_s3_bucket.bucket_creation["dev-fire-incidents-dt-glue-python"].id
}
```

Replace the bucket name as necessary:

```hcl
output "glue_bucket" {
    value = aws_s3_bucket.bucket_creation["my_other_bucket"].id
}
```

### 3. Configuring AWS Regions for Resources

The Glue and Lambda modules contain a `providers.tf` file for region configuration. Ensure your AWS region is set correctly:

```hcl
provider "aws" {
    region = "us-east-2"
}
```

Update the region in the `variables.tf` file as well:

```hcl
variable "aws_region" {
    description = "aws region"
    type = string
    default = "us-east-2"
}
```

## Backend Configuration for Terraform State

To capture changes in your Terraform configuration, update the `backend.hcl` file with the correct bucket name:

```hcl
bucket = "dev-fire-incidents-dt-tf-state"
```

## Project Description

### Project Structure for AWS_PIPELINE_SNOWFLAKE Repository:

```bash
.
├── .github/
│   └── workflows/
│       ├── AWS_CREATION_PIPELINE_SN.yml
│       ├── AWS_DESTROY_PIPELINE_SN.yml
│       └── SNOWFLAKE_RESOURCES.yml
├── aws_pipeline_deployment/
│   ├── glue_module/
│   │   ├── glue_script/
│   │   │   └── GlueJobScript.py
│   │   ├── glue.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   ├── lambda_module/
│   │   ├── resources/
│   │   │   ├── python/
│   │   │   │   └── aws_lambda/
│   │   │   │       ├── api_calls.py
│   │   │   │       └── lambda_function.py
│   │   │   ├── Dockerfile
│   │   │   └── requirements.txt
│   │   ├── bucket.tf
│   │   ├── buckets.json
│   │   ├── docker.tf
│   │   ├── iam_role.tf
│   │   ├── lambda.tf
│   │   ├── local.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── variables.tf
├── main.tf
├── versions.tf
├── resource_queries/
│   ├── V0.1.1_file_format.sql
│   ├── V0.1.2_external_table.sql
│   ├── V0.1.3_stream_creation.sql
│   ├── V0.1.4_permanent_table_creation.sql
│   ├── V0.1.5_materialized_view.sql
│   └── V0.1.6_task_creation.sql
├── backend.hcl
└── README.md
```

### Key Directories:

1. **workflows**: CI/CD files to create AWS and Snowflake resources.

2. **glue_module**: Contains Python and Terraform files to deploy the Glue job, capturing incremental updates from the Fire Incidents API.

3. **lambda_module**: Contains Python, Docker, and Terraform configuration files to deploy AWS Lambda and S3 buckets for API data storage with KMS encryption.

4. **aws_pipeline_deployment**: The root directory containing Glue and Lambda modules. It also includes **main.tf** and **versions.tf** for detecting changes when workflows are deployed via GitHub Actions.

5. **resource_queries**: SQL queries to create Snowflake resources for data ingestion.

## Before Workflows Execution

1. [List any prerequisites or steps required before executing workflows.]

## Workflows Execution

1. [Describe how to execute the workflows for this project.]

## Snowflake Schemachange

### 1. Schemachange Considerations

The Schemachange tool expects a folder structure similar to the following:

```bash
(project_root)
├── folder_1
│   ├── V1.1.1__first_change.sql
│   ├── V1.1.2__second_change.sql
│   ├── R__sp_add_sales.sql
│   └── R__fn_get_timezone.sql
├── folder_2
│   └── folder_3
│       ├── V1.1.3__third_change.sql
│       └── R__fn_sort_ascii.sql
```

Each version annotation is linked to a Snowflake object (table, file format, stream, etc.) and must follow versioning best practices:

- **Prefix**: 'V' for versioned changes.
- **Version**: A unique version number.
- **Separator**: Two underscores (`__`).
- **Description**: An arbitrary description with words separated by underscores or spaces (cannot include two underscores).
- **Suffix**: `.sql` or `.sql.jinja`.

### 2. Schemachange Table Creation

Before using GitHub Actions to deploy objects via Schemachange, create the following Snowflake table to track changes:

```sql
CREATE TABLE IF NOT EXISTS CHANGE_HISTORY
(
    VERSION VARCHAR,
    DESCRIPTION VARCHAR,
    SCRIPT VARCHAR,
    SCRIPT_TYPE VARCHAR,
    CHECKSUM VARCHAR,
    EXECUTION_TIME NUMBER,
    STATUS VARCHAR,
    INSTALLED_BY VARCHAR,
    INSTALLED_ON TIMESTAMP_LTZ
);
```

### 3. Snowflake Credentials

To successfully deploy Snowflake objects via GitHub Actions, ensure full authentication using the following credentials:

- **ACCOUNT**
- **USER**
- **ROLE**
- **PASSWORD**
- **WAREHOUSE**
- **DATABASE**
