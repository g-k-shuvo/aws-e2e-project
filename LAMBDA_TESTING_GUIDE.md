# AWS Lambda Testing Guide

This guide will help you test your calculator Lambda function directly in the AWS Lambda console.

## Quick Test Setup

### Step 1: Access Your Lambda Function
1. Go to AWS Lambda Console
2. Find your function: `calculator-lambda`
3. Click on the function name to open it

### Step 2: Test the Function
1. Click the **"Test"** tab
2. Click **"Create new event"**
3. Event name: `test-addition`
4. Copy and paste this JSON into the event body:

```json
{
  "body": "{\"num1\": 10, \"num2\": 5, \"operation\": \"+\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```

5. Click **"Save"**
6. Click **"Test"**

## Expected Results

### ✅ Successful Test Response
You should see a response like this:
```json
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST, OPTIONS"
  },
  "body": "{\"result\":15,\"operation\":\"+\",\"num1\":10,\"num2\":5,\"calculationId\":\"2024-01-15T10:30:00.000Z-abc123def\",\"timestamp\":\"2024-01-15T10:30:00.000Z\"}"
}
```

### 📊 Check DynamoDB
After a successful test:
1. Go to DynamoDB Console
2. Find table: `aws-e2e-project`
3. Click "Explore table items"
4. You should see your calculation stored there

## Comprehensive Test Cases

### 1. Basic Operations Test
**Event:**
```json
{
  "body": "{\"num1\": 20, \"num2\": 4, \"operation\": \"/\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```
**Expected Result:** `{"result": 5, "operation": "/", "num1": 20, "num2": 4, ...}`

### 2. Error Handling Test - Division by Zero
**Event:**
```json
{
  "body": "{\"num1\": 10, \"num2\": 0, \"operation\": \"/\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```
**Expected Result:** 
```json
{
  "statusCode": 400,
  "body": "{\"error\":\"Cannot divide by zero\"}"
}
```

### 3. Error Handling Test - Invalid Operation
**Event:**
```json
{
  "body": "{\"num1\": 10, \"num2\": 5, \"operation\": \"invalid\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```
**Expected Result:**
```json
{
  "statusCode": 400,
  "body": "{\"error\":\"Invalid operation\"}"
}
```

### 4. Missing Parameters Test
**Event:**
```json
{
  "body": "{\"num1\": 10}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```
**Expected Result:**
```json
{
  "statusCode": 400,
  "body": "{\"error\":\"Missing required parameters: num1, num2, and operation\"}"
}
```

### 5. Square Root Test
**Event:**
```json
{
  "body": "{\"num1\": 16, \"num2\": 0, \"operation\": \"sqrt\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```
**Expected Result:** `{"result": 4, "operation": "sqrt", "num1": 16, "num2": 0, ...}`

### 6. Exponentiation Test
**Event:**
```json
{
  "body": "{\"num1\": 2, \"num2\": 8, \"operation\": \"**\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```
**Expected Result:** `{"result": 256, "operation": "**", "num1": 2, "num2": 8, ...}`

## Testing Checklist

### ✅ Functionality Tests
- [ ] Addition operation works
- [ ] Subtraction operation works
- [ ] Multiplication operation works
- [ ] Division operation works
- [ ] Modulo operation works
- [ ] Exponentiation operation works
- [ ] Square root operation works

### ✅ Error Handling Tests
- [ ] Division by zero returns error
- [ ] Negative square root returns error
- [ ] Invalid operation returns error
- [ ] Missing parameters returns error
- [ ] Invalid number format returns error

### ✅ Database Tests
- [ ] Successful calculations are stored in DynamoDB
- [ ] Each calculation has a unique ID
- [ ] Timestamps are properly recorded
- [ ] All calculation data is stored correctly

### ✅ Response Format Tests
- [ ] Success responses have statusCode 200
- [ ] Error responses have appropriate statusCode (400, 500)
- [ ] CORS headers are present
- [ ] Response body is valid JSON

## Troubleshooting

### Common Issues:

1. **"Table not found" error:**
   - Check if DynamoDB table `aws-e2e-project` exists
   - Verify IAM permissions for Lambda to access DynamoDB

2. **"Module not found" error:**
   - Ensure AWS SDK dependencies are included in deployment package
   - Check that `@aws-sdk/client-dynamodb` and `@aws-sdk/lib-dynamodb` are installed

3. **"Invalid JSON" error:**
   - Check that the test event body is properly formatted
   - Ensure the `body` field contains valid JSON string

4. **"Permission denied" error:**
   - Verify Lambda execution role has DynamoDB permissions
   - Check CloudFormation stack for IAM role creation

### Debug Steps:
1. Check CloudWatch logs for detailed error messages
2. Verify DynamoDB table exists and is accessible
3. Test with simpler operations first
4. Check environment variables are set correctly

## Performance Testing

### Test Large Numbers:
```json
{
  "body": "{\"num1\": 999999999, \"num2\": 111111111, \"operation\": \"*\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```

### Test Decimal Numbers:
```json
{
  "body": "{\"num1\": 3.14159, \"num2\": 2.71828, \"operation\": \"+\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```

## Next Steps After Testing

1. **Verify DynamoDB Storage:** Check that calculations are being stored
2. **Test Frontend Integration:** Update your HTML file with the Lambda URL
3. **Monitor Performance:** Check CloudWatch metrics for function performance
4. **Set Up Alerts:** Configure CloudWatch alarms for errors

## Quick Test Commands

You can also test using AWS CLI:

```bash
# Test addition
aws lambda invoke \
  --function-name calculator-lambda \
  --payload '{"body":"{\"num1\":10,\"num2\":5,\"operation\":\"+\"}","headers":{"Content-Type":"application/json"}}' \
  response.json

# View response
cat response.json
```

This will help you verify that your Lambda function is working correctly before integrating it with your frontend! 