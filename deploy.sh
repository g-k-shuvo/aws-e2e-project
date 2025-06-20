#!/bin/bash

# Calculator Lambda with DynamoDB Deployment Script

set -e

# Configuration
STACK_NAME="calculator-stack"
LAMBDA_FUNCTION_NAME="calculator-lambda"
DYNAMODB_TABLE_NAME="calculator-calculations"
REGION="us-east-1"  # Change this to your preferred region

echo "🚀 Starting deployment of Calculator Lambda with DynamoDB..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is authenticated
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI is configured"

# Deploy CloudFormation stack
echo "📦 Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file cloudformation-template.yaml \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        LambdaFunctionName=$LAMBDA_FUNCTION_NAME \
        DynamoDBTableName=$DYNAMODB_TABLE_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION

echo "✅ CloudFormation stack deployed successfully"

# Get the Lambda function URL
echo "🔗 Getting Lambda function URL..."
LAMBDA_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`LambdaFunctionUrl`].OutputValue' \
    --output text)

echo "✅ Lambda function URL: $LAMBDA_URL"

# Create deployment package for Lambda
echo "📦 Creating Lambda deployment package..."
mkdir -p temp
cp lambda_function.js temp/index.js

# Create package.json for Lambda dependencies
cat > temp/package.json << EOF
{
  "name": "calculator-lambda",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.0.0",
    "@aws-sdk/lib-dynamodb": "^3.0.0"
  }
}
EOF

# Install dependencies
cd temp
npm install --production
cd ..

# Create ZIP file
echo "📦 Creating ZIP file..."
cd temp
zip -r ../lambda-deployment.zip .
cd ..
rm -rf temp

# Update Lambda function code
echo "🔄 Updating Lambda function code..."
aws lambda update-function-code \
    --function-name $LAMBDA_FUNCTION_NAME \
    --zip-file fileb://lambda-deployment.zip \
    --region $REGION

# Clean up
rm lambda-deployment.zip

echo "✅ Lambda function updated successfully"

# Update the HTML file with the Lambda URL
echo "📝 Updating HTML file with Lambda URL..."
sed -i.bak "s|YOUR_LAMBDA_FUNCTION_URL_HERE|$LAMBDA_URL|g" index.html
rm index.html.bak

echo "✅ HTML file updated with Lambda URL"

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Summary:"
echo "   - CloudFormation Stack: $STACK_NAME"
echo "   - Lambda Function: $LAMBDA_FUNCTION_NAME"
echo "   - DynamoDB Table: $DYNAMODB_TABLE_NAME"
echo "   - Lambda URL: $LAMBDA_URL"
echo ""
echo "🌐 You can now open index.html in your browser to test the calculator!"
echo ""
echo "📊 To view your calculations in DynamoDB:"
echo "   - Go to AWS Console > DynamoDB"
echo "   - Find table: $DYNAMODB_TABLE_NAME"
echo "   - Click 'Explore table items'"
echo ""
echo "🔍 To view Lambda logs:"
echo "   - Go to AWS Console > CloudWatch > Log groups"
echo "   - Find: /aws/lambda/$LAMBDA_FUNCTION_NAME" 