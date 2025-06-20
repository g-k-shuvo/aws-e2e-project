# AWS Lambda Calculator with DynamoDB Storage

A simple calculator application that uses AWS Lambda for mathematical calculations and stores all calculation history in DynamoDB.

## Project Structure

- `index.html` - Frontend calculator interface
- `lambda_function.js` - AWS Lambda function for calculations with DynamoDB storage
- `cloudformation-template.yaml` - CloudFormation template for infrastructure
- `deploy.sh` - Deployment script for Linux/Mac
- `deploy.bat` - Deployment script for Windows
- `README.md` - This file

## Features

- **Mathematical Operations:**
  - Addition (+)
  - Subtraction (−)
  - Multiplication (×)
  - Division (÷)
  - Modulo (%)
  - Exponentiation (^)
  - Square Root (√)

- **Data Storage:**
  - All calculations are stored in DynamoDB
  - Each calculation gets a unique ID
  - Timestamp tracking for all operations
  - Automatic TTL (Time To Live) for data cleanup

- **Error Handling:**
  - Division by zero
  - Square root of negative numbers
  - Invalid inputs
  - Network errors
  - Database errors (graceful fallback)

- **User Experience:**
  - Loading states
  - Real-time validation
  - Responsive design
  - Error messages

## Quick Deployment

### Option 1: Automated Deployment (Recommended)

**For Windows:**
```bash
deploy.bat
```

**For Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Manual Deployment

#### 1. Deploy Infrastructure with CloudFormation

1. **Deploy the CloudFormation stack:**
   ```bash
   aws cloudformation deploy \
       --template-file cloudformation-template.yaml \
       --stack-name calculator-stack \
       --capabilities CAPABILITY_NAMED_IAM \
       --region us-east-1
   ```

2. **Get the Lambda function URL:**
   ```bash
   aws cloudformation describe-stacks \
       --stack-name calculator-stack \
       --region us-east-1 \
       --query 'Stacks[0].Outputs[?OutputKey==`LambdaFunctionUrl`].OutputValue' \
       --output text
   ```

#### 2. Deploy Lambda Function Code

1. **Create deployment package:**
   ```bash
   mkdir temp
   cp lambda_function.js temp/index.js
   
   # Create package.json
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
   
   cd temp
   npm install --production
   zip -r ../lambda-deployment.zip .
   cd ..
   rm -rf temp
   ```

2. **Update Lambda function:**
   ```bash
   aws lambda update-function-code \
       --function-name calculator-lambda \
       --zip-file fileb://lambda-deployment.zip \
       --region us-east-1
   ```

#### 3. Update Frontend

Replace `YOUR_LAMBDA_FUNCTION_URL_HERE` in `index.html` with your actual Lambda function URL.

## DynamoDB Table Structure

The DynamoDB table stores the following information for each calculation:

```json
{
  "id": "2024-01-15T10:30:00.000Z-abc123def",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "num1": 10,
  "num2": 5,
  "operation": "+",
  "result": 15,
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

### Table Schema:
- **Primary Key:** `id` (String) - Unique identifier for each calculation
- **Attributes:**
  - `timestamp` - ISO timestamp of the calculation
  - `num1` - First number
  - `num2` - Second number
  - `operation` - Mathematical operation performed
  - `result` - Calculation result
  - `createdAt` - Creation timestamp
  - `ttl` - Time To Live for automatic cleanup (optional)

## Infrastructure Components

### CloudFormation Stack Creates:
1. **DynamoDB Table** - Stores all calculations
2. **IAM Role** - Permissions for Lambda to access DynamoDB
3. **Lambda Function** - Handles calculations and database operations
4. **Lambda Function URL** - HTTP endpoint for the function

### IAM Permissions:
- Lambda execution role
- DynamoDB read/write permissions
- CloudWatch logging permissions

## Monitoring and Logging

### View Calculation History:
1. Go to AWS Console > DynamoDB
2. Find table: `calculator-calculations`
3. Click "Explore table items"

### View Lambda Logs:
1. Go to AWS Console > CloudWatch > Log groups
2. Find: `/aws/lambda/calculator-lambda`

### Monitor Performance:
- CloudWatch Metrics for Lambda invocations
- DynamoDB metrics for read/write capacity
- CloudWatch Logs for error tracking

## Security Considerations

- **Lambda Function URL:** Set to "NONE" authentication for demo purposes
- **CORS:** Configured to allow all origins (`*`) for demo purposes
- **DynamoDB:** Uses on-demand billing (pay-per-request)
- **IAM:** Least privilege principle applied

### Production Recommendations:
- Use API Gateway instead of direct Lambda URLs
- Implement proper authentication (API Keys, JWT, etc.)
- Restrict CORS to specific domains
- Enable DynamoDB encryption at rest
- Set up CloudWatch alarms for monitoring
- Implement request rate limiting

## Cost Optimization

- **DynamoDB:** Uses on-demand billing (no provisioned capacity)
- **Lambda:** Pay only for actual invocations
- **TTL:** Automatic cleanup of old records (configurable)
- **CloudFormation:** No additional cost for infrastructure management

## Troubleshooting

### Common Issues:

1. **"Please configure your Lambda function URL" error:**
   - Make sure you've updated the `lambdaUrl` in the JavaScript code

2. **CORS errors:**
   - Ensure CORS is enabled in your Lambda function URL configuration
   - Check that the Lambda function returns proper CORS headers

3. **DynamoDB errors:**
   - Verify IAM permissions for Lambda to access DynamoDB
   - Check CloudWatch logs for specific error messages

4. **Network errors:**
   - Verify your Lambda function URL is correct
   - Check that your Lambda function is deployed and active
   - Ensure your internet connection is working

5. **Deployment failures:**
   - Check AWS CLI configuration
   - Verify you have sufficient permissions
   - Check CloudFormation stack events for specific errors

### Debug Steps:
1. Check CloudWatch logs for Lambda function
2. Verify DynamoDB table exists and is accessible
3. Test Lambda function directly in AWS Console
4. Check IAM role permissions
5. Verify environment variables are set correctly

## Next Steps

- Add a history view to display past calculations
- Implement user authentication and user-specific calculation history
- Add more mathematical operations (trigonometry, logarithms, etc.)
- Create a dashboard for viewing calculation statistics
- Implement data export functionality
- Add calculation sharing features
- Set up automated backups for DynamoDB data
- Implement cost monitoring and alerts
