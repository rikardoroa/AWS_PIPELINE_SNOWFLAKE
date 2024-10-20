

# AWS SNOWFLAKE PIPELINE FOR FIRE INCIDENTS DATA CAPTURE

## AWS Cli Installation and Bucket Configuration for Terraform 

* 1. **__AWS CLI installation__** is important for getting and identifying automatically our credentials, to wrap our environment with our aws session config, the next step is to define the installation following this:

  * 1. `brew install awscli`, this will install all the packets of aws cli into our environment

  * 2. `aws --version`, with this command we can check if the installation went well and also verify our version of aws cli.

  * 3. if you are using windows follow the documentation to install aws cli on windows : **_https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html_**
  

  * 4. after **__aws cli installation__** is necessary additional preriquisites before run the github workflow for AWS Services/Resources creation with terraform, is necessary apply the following commands to acomplish our terraform environment configuration in our CI/CD pipeline like this:
     * 1. execute the next command to create a dynamo table to capture the changes for our terraform state file : `aws dynamodb create-table --table-name terraform-lock-table --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region your_region` , make sure to replace **__your_region__** placeholder for your actual AWS Region related to your account, for example : **__us-east-2__**


     * 2. the next thing is to execute the following command to create a bucket for store the terraform state file, like this: `aws s3api create-bucket --bucket your_bucket --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2`, also replace the placeholder for a unique bucket


     * 3. now the final command is to establish some restrictions and to apply some policies to protect the bucket, like the following:`aws s3api put-public-access-block --bucket your_bucket --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true`


## Bucket Configuration for AWS Lambda and AWS Glue Resources

* 1. The **__lambda_module__** which is part of the terraform enviroment, constains a json file called **__buckets.json__**, this file also contains the names of the buckets that will be created as a part of AWS Glue and AWS Lambda pipeline process, the definition needs to be unique for each bucket or we will have and error, so is important to check if the bucket exists first, we can use the following comand to obtains a response if the bucket already exists in AWS, using aws `s3api head-bucket --bucket your_bucket`, if the response after apply the comand is:**__An error occurred (404) when calling the HeadBucket operation: Not Found__** that means that the buckets does not exists and you can create it. this check can also by applied for the bucket configuration process regarding dynamo db to capture terraform state, also this is the json file that is describing the buckets:
    ```json
               {
                "buckets": [
                    {
                        "name": "dev-fire-incidents-dt"
                    },
                    {
                        "name": "dev-fire-incidents-dt-all"
                    },
                    {
                        "name": "dev-fire-incidents-dt-glue-python"
                    }

                ]
            }
* 2. if the user wants to change all the buckets name, to create different ones, is necessary apply some changes in the the **__outputs.tf__** file related to the **__lambda_module__**, the file have this entry:
   
    ```tf
        output "glue_bucket" {
            value = aws_s3_bucket.bucket_creation["dev-fire-incidents-dt-glue-python"].id
        }
    ```

    in this case is necessary replace the name of the bucket in square brackets with the new name like this:
    
    ```tf
        output "glue_bucket" {
            value = aws_s3_bucket.bucket_creation["my_other_bucket"].id
        }

* 3. **__Resources region configuration__**: for both Glue and Lambda module we have a file called **__providers__**, that contains the region value for our AWS resources, replace this entry for your actual AWS Region in both files:
    ```tf
        provider "aws" {
            region  = "us-east-2"   
        }
    ```
    the region entry is also present in **__variables.tf__** file for the **__lambda__module__**, also replace the value of your AWS region in this entry:
    ```tf
        variable "aws_region"{
            description = "aws region"
            type = string
            default = "us-east-2"
        }
    ```   

## Backend Configuration for Terraform State

* 1. to capture the changes in terraform every time that we add more resources to the workflow is necessary set up the backend configuration executed in the steps  related to **__AWS Cli Installation and Bucket Configuration for Terraform__**, regarding that is necessary call the  **__backend.hcl__** file that contains the bucket that is capturing the changes of the terraform state, the mentioned file has this entry:
    ```bash
        bucket = "dev-fire-incidents-dt-tf-state"
    ```
    this bucket is created by the user using the commands describe above using aws cli, this file is used to capture all the changes once we execute the workflow to create the aws resources



## Project Description
* 1. 


## Before Worflows Executions
* 1. 


## Workflows Executions
* 1. 


## Snowflake Schemachange 
* 1. 