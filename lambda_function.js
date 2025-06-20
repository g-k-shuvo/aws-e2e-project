import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
    try {
        // Parse the request body
        const body = typeof event === 'string' ? JSON.parse(event) : event;
        
        // Extract parameters
        const num1 = parseFloat(body.num1);
        const num2 = parseFloat(body.num2);
        const operation = body.operation;
        
        // Validate inputs
        if (isNaN(num1) || isNaN(num2) || !operation) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST, OPTIONS'
                },
                body: JSON.stringify({
                    error: 'Missing required parameters: num1, num2, and operation'
                })
            };
        }
        
        // Perform calculation based on operation
        let result;
        
        switch (operation) {
            case '+':
                result = num1 + num2;
                break;
            case '-':
                result = num1 - num2;
                break;
            case '*':
                result = num1 * num2;
                break;
            case '/':
                if (num2 === 0) {
                    return {
                        statusCode: 400,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Headers': 'Content-Type',
                            'Access-Control-Allow-Methods': 'POST, OPTIONS'
                        },
                        body: JSON.stringify({
                            error: 'Cannot divide by zero'
                        })
                    };
                }
                result = num1 / num2;
                break;
            case '%':
                result = num1 % num2;
                break;
            case '**':
                result = Math.pow(num1, num2);
                break;
            case 'sqrt':
                if (num1 < 0) {
                    return {
                        statusCode: 400,
                        headers: {
                            'Content-Type': 'application/json',
                            'Access-Control-Allow-Origin': '*',
                            'Access-Control-Allow-Headers': 'Content-Type',
                            'Access-Control-Allow-Methods': 'POST, OPTIONS'
                        },
                        body: JSON.stringify({
                            error: 'Cannot calculate square root of negative number'
                        })
                    };
                }
                result = Math.sqrt(num1);
                break;
            default:
                return {
                    statusCode: 400,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*',
                        'Access-Control-Allow-Headers': 'Content-Type',
                        'Access-Control-Allow-Methods': 'POST, OPTIONS'
                    },
                    body: JSON.stringify({
                        error: 'Invalid operation'
                    })
                };
        }
        
        // Store calculation in DynamoDB
        const timestamp = new Date().toISOString();
        const calculationId = `${timestamp}-${Math.random().toString(36).substr(2, 9)}`;
        
        const calculationRecord = {
            ID: calculationId,
            timestamp: timestamp,
            num1: num1,
            num2: num2,
            operation: operation,
            result: result,
            createdAt: timestamp
        };
        
        try {
            await docClient.send(new PutCommand({
                TableName: process.env.CALCULATIONS_TABLE_NAME || '',
                Item: calculationRecord
            }));
        } catch (dbError) {
            console.error('Error storing calculation in DynamoDB:', dbError);
            // Continue with the response even if DB storage fails
        }
        
        // Return successful response
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            body: JSON.stringify({
                result: result,
                operation: operation,
                num1: num1,
                num2: num2,
                calculationId: calculationId,
                timestamp: timestamp
            })
        };
        
    } catch (error) {
        console.error('Lambda function error:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            body: JSON.stringify({
                error: 'Internal server error'
            })
        };
    }
}; 