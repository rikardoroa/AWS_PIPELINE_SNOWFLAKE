module "aws_lambda_utils" {
  source       = "./lambda_module"
}

module "aws_glue_utils" {
  source       = "./glue_module"
  target_bucket = module.aws_lambda_utils.glue_bucket 
  iam_for_dev_name = module.aws_lambda_utils.iam_for_dev_name
  iam_for_dev_arn = module.aws_lambda_utils.iam_for_dev_arn
  policy_name_json =  module.aws_lambda_utils.policy_for_dev
}