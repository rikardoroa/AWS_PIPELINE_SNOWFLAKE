
# AWS Snowflake Pipeline for Fire Incidents Data Capture

## AWS CLI Installation and Bucket Configuration for Terraform

### 1. AWS CLI Installation

The AWS CLI is essential for automatically managing credentials and configuring the environment. Follow the steps below for installation and configuration:

1. **Install AWS CLI**: Use Homebrew to install the AWS CLI:
   ```bash
   brew install awscli
   ```

2. **Verify Installation**: Confirm the installation and check the AWS CLI version:
   ```bash
   aws --version
   ```

3. **Windows Installation**: For Windows users, refer to the [AWS CLI Installation Guide for Windows](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

4. **Terraform Environment Configuration**: Before running GitHub workflows for AWS resource creation with Terraform, complete the following steps:
   
   - **Check if the Bucket Exists**:
        ```bash
        aws s3api head-bucket --bucket your_bucket
        ```
        If the response is: `An error occurred (404) when calling the HeadBucket operation: Not Found`, the bucket does not exist and can be created.

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

The `lambda_module` in the Terraform environment contains a `buckets.json` file with the following bucket names. Ensure each name is unique to avoid errors.

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

If you want to modify the bucket names, update the `outputs.tf` file in the `lambda_module`:

```hcl
output "glue_bucket" {
    value = aws_s3_bucket.bucket_creation["dev-fire-incidents-dt-glue-python"].id
}
```

Replace the bucket name in the square brackets as needed:

```hcl
output "glue_bucket" {
    value = aws_s3_bucket.bucket_creation["my_other_bucket"].id
}
```

### 3. Configuring AWS Regions for Resources

Both the Glue and Lambda modules contain a `providers.tf` file for region configuration. Ensure your AWS region is correctly set:

```hcl
provider "aws" {
    region = "us-east-2"
}
```

The region is also specified in the `variables.tf` file. Update it as follows:

```hcl
variable "aws_region" {
    description = "aws region"
    type = string
    default = "us-east-2"
}
```

## Backend Configuration for Terraform State

To capture changes in your Terraform configuration, set up the backend by updating the `backend.hcl` file. Ensure the bucket name matches the one created earlier:

```hcl
bucket = "dev-fire-incidents-dt-tf-state"
```

This bucket is created using the AWS CLI commands described in the installation section.

## Project Description

1. This is the project structure:

# Project Structure for AWS_PIPELINE_SNOWFLAKE Repository


    ```bash
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
1.  **__workflows__**: contains the CI/CD file to create the AWS and Snowflake Resources

2.  **__glue_module__**: this directory have the python and terraform configuration files to deploy the Glue job, that will execute the workload to 
capture the incrementals updates related to the API from https://data.sfgov.org/Public-Safety/Fire-Incidents/wr8u-xric/about_data

3. **__lambda_module__**: this directory contains the python, docker, terraform configuration files to deploy the AWS Lambda function and several S3 buckets to store all the info related to the API Call using KMS encryption.

4. **__aws_pipeline_deployment__**: this is the root directory that contains glue and lambda module folder, also contains the **__main.tf__** and 
**__versions.tf__** files that will execute and load the terraform backend configuration to detect changes once the workflow in deployed with github actions

5. **__resource_queries__**: this folder contains the SQL queries to create the snowflake warehouse resources for ingest the data.


## Before Workflows Execution

1. [List any prerequisites or steps required before executing workflows.]

## Workflows Execution

1. [Describe how to execute the workflows for this project.]

## Snowflake Schemachange

1. [Provide instructions on using Snowflake Schemachange.]

