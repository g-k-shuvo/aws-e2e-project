# AWS Lambda Calculator

A simple calculator application that uses AWS Lambda for mathematical calculations.

## Project Structure

- `index.html` - Frontend calculator interface
- `lambda_function.js` - AWS Lambda function for calculations
- `README.md` - This file

## Setup Instructions

### 1. Deploy the Lambda Function

1. **Create a new Lambda function in AWS Console:**
   - Go to AWS Lambda Console
   - Click "Create function"
   - Choose "Author from scratch"
   - Function name: `calculator-lambda`
   - Runtime: Node.js 18.x or later
   - Architecture: x86_64
   - Click "Create function"

2. **Upload the Lambda code:**
   - Copy the contents of `lambda_function.js`
   - Replace the default code in your Lambda function
   - Click "Deploy"

3. **Configure Lambda Function URL:**
   - In your Lambda function, go to "Configuration" tab
   - Click "Function URL"
   - Click "Create function URL"
   - Auth type: "NONE" (for this demo)
   - Configure cross-origin resource sharing (CORS): Yes
   - Click "Save"

4. **Copy the Function URL:**
   - Copy the generated URL (it will look like: `https://xxxxxxxxxx.lambda-url.us-east-1.on.aws/`)

### 2. Update the Frontend

1. **Open `index.html`**
2. **Find this line in the Calculator constructor:**
   ```javascript
   this.lambdaUrl = 'YOUR_LAMBDA_FUNCTION_URL_HERE';
   ```
3. **Replace `YOUR_LAMBDA_FUNCTION_URL_HERE` with your actual Lambda function URL**

### 3. Test the Application

1. Open `index.html` in a web browser
2. Enter two numbers
3. Select an operation
4. Click "Calculate"
5. The result should come from your Lambda function

## Features

- **Mathematical Operations:**
  - Addition (+)
  - Subtraction (−)
  - Multiplication (×)
  - Division (÷)
  - Modulo (%)
  - Exponentiation (^)
  - Square Root (√)

- **Error Handling:**
  - Division by zero
  - Square root of negative numbers
  - Invalid inputs
  - Network errors

- **User Experience:**
  - Loading states
  - Real-time validation
  - Responsive design
  - Error messages

## Security Notes

- The Lambda function URL is set to "NONE" authentication for demo purposes
- In production, consider using API Gateway with proper authentication
- The CORS headers are configured to allow all origins (`*`) for demo purposes
- In production, restrict CORS to your specific domain

## Troubleshooting

1. **"Please configure your Lambda function URL" error:**
   - Make sure you've updated the `lambdaUrl` in the JavaScript code

2. **CORS errors:**
   - Ensure CORS is enabled in your Lambda function URL configuration
   - Check that the Lambda function returns proper CORS headers

3. **Network errors:**
   - Verify your Lambda function URL is correct
   - Check that your Lambda function is deployed and active
   - Ensure your internet connection is working

4. **Calculation errors:**
   - Check the Lambda function logs in AWS CloudWatch
   - Verify the input format matches what the Lambda function expects

## Next Steps

- Add authentication to the Lambda function
- Use API Gateway instead of direct Lambda URLs
- Add more mathematical operations
- Implement request rate limiting
- Add input validation on the Lambda side
- Set up CloudWatch monitoring and alerts
