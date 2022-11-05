import boto3

def lambda_handler(event,context):
    message = event["Records"][0]["body"]
    s3 = boto3.resource('s3')
    f = open("/tmp/sqs.json","w")
    f.write(message)
    f.close()
    s3.meta.client.upload_file('/tmp/sqs.json','javahome-linkedin-demo2','sqs.json')
    print(message)
    return message


