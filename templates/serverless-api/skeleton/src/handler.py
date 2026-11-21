import json


def handler(event, context):
    params = event.get("queryStringParameters") or {}
    name = params.get("name", "world")

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"service": "${{ values.name }}", "message": f"Hello, {name}!"}),
    }
