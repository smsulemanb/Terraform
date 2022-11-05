module "SQS" {
    source="./modules/SQS"
    que_name = "javahome-queue"
    delay_seconds = 0
    lambda_function_name = module.lambda.lambda_arn
}
module "lambda"{
    source="./modules/lambda"
}
module "s3"{
    source= "./modules/s3"
    bucket_name = "javahome-linkedin-demo2"
}