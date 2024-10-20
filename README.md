

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

* 1. The **__lambda_module__** which is part of the terraform enviroment, constains a json file called **__buckets.json__**, this file also contains the names of the buckets that will be created as a part of AWS Glue and AWS Lambda pipeline process, the definition needs to be unique for each bucket or we will have and error, so is important to check if the bucket exists first, we can use the following comand to obtains a response if the bucket already exists in AWS, using aws `s3api head-bucket --bucket your_bucket`, this check can also by applied for the bucket configuration process regarding dynamo db to capture terraform state, also this is the json file that is describing the buckets:
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