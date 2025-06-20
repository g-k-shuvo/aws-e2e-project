@echo off
setlocal enabledelayedexpansion

REM Calculator Lambda with DynamoDB Deployment Script for Windows

REM Configuration
set STACK_NAME=calculator-stack
set LAMBDA_FUNCTION_NAME=calculator-lambda
set DYNAMODB_TABLE_NAME=calculator-calculations
set REGION=us-east-1

echo 🚀 Starting deployment of Calculator Lambda with DynamoDB...

REM Check if AWS CLI is installed
aws --version >nul 2>&1
if errorlevel 1 (
    echo ❌ AWS CLI is not installed. Please install it first.
    pause
    exit /b 1
)

REM Check if user is authenticated
aws sts get-caller-identity >nul 2>&1
if errorlevel 1 (
    echo ❌ AWS CLI is not configured. Please run 'aws configure' first.
    pause
    exit /b 1
)

echo ✅ AWS CLI is configured

REM Deploy CloudFormation stack
echo 📦 Deploying CloudFormation stack...
aws cloudformation deploy ^
    --template-file cloudformation-template.yaml ^
    --stack-name %STACK_NAME% ^
    --parameter-overrides ^
        LambdaFunctionName=%LAMBDA_FUNCTION_NAME% ^
        DynamoDBTableName=%DYNAMODB_TABLE_NAME% ^
    --capabilities CAPABILITY_NAMED_IAM ^
    --region %REGION%

if errorlevel 1 (
    echo ❌ CloudFormation deployment failed
    pause
    exit /b 1
)

echo ✅ CloudFormation stack deployed successfully

REM Get the Lambda function URL
echo 🔗 Getting Lambda function URL...
for /f "tokens=*" %%i in ('aws cloudformation describe-stacks --stack-name %STACK_NAME% --region %REGION% --query "Stacks[0].Outputs[?OutputKey==`LambdaFunctionUrl`].OutputValue" --output text') do set LAMBDA_URL=%%i

echo ✅ Lambda function URL: %LAMBDA_URL%

REM Create deployment package for Lambda
echo 📦 Creating Lambda deployment package...
if exist temp rmdir /s /q temp
mkdir temp
copy lambda_function.js temp\index.js

REM Create package.json for Lambda dependencies
echo {> temp\package.json
echo   "name": "calculator-lambda",>> temp\package.json
echo   "version": "1.0.0",>> temp\package.json
echo   "type": "module",>> temp\package.json
echo   "dependencies": {>> temp\package.json
echo     "@aws-sdk/client-dynamodb": "^3.0.0",>> temp\package.json
echo     "@aws-sdk/lib-dynamodb": "^3.0.0">> temp\package.json
echo   }>> temp\package.json
echo }>> temp\package.json

REM Install dependencies
cd temp
npm install --production
cd ..

REM Create ZIP file
echo 📦 Creating ZIP file...
cd temp
powershell Compress-Archive -Path * -DestinationPath ..\lambda-deployment.zip
cd ..
rmdir /s /q temp

REM Update Lambda function code
echo 🔄 Updating Lambda function code...
aws lambda update-function-code ^
    --function-name %LAMBDA_FUNCTION_NAME% ^
    --zip-file fileb://lambda-deployment.zip ^
    --region %REGION%

if errorlevel 1 (
    echo ❌ Lambda function update failed
    pause
    exit /b 1
)

REM Clean up
del lambda-deployment.zip

echo ✅ Lambda function updated successfully

REM Update the HTML file with the Lambda URL
echo 📝 Updating HTML file with Lambda URL...
powershell -Command "(Get-Content index.html) -replace 'YOUR_LAMBDA_FUNCTION_URL_HERE', '%LAMBDA_URL%' | Set-Content index.html"

echo ✅ HTML file updated with Lambda URL

echo.
echo 🎉 Deployment completed successfully!
echo.
echo 📋 Summary:
echo    - CloudFormation Stack: %STACK_NAME%
echo    - Lambda Function: %LAMBDA_FUNCTION_NAME%
echo    - DynamoDB Table: %DYNAMODB_TABLE_NAME%
echo    - Lambda URL: %LAMBDA_URL%
echo.
echo 🌐 You can now open index.html in your browser to test the calculator!
echo.
echo 📊 To view your calculations in DynamoDB:
echo    - Go to AWS Console ^> DynamoDB
echo    - Find table: %DYNAMODB_TABLE_NAME%
echo    - Click 'Explore table items'
echo.
echo 🔍 To view Lambda logs:
echo    - Go to AWS Console ^> CloudWatch ^> Log groups
echo    - Find: /aws/lambda/%LAMBDA_FUNCTION_NAME%

pause 