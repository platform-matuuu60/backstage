# ${{ values.name }}

${{ values.description }}

Created from the Backstage template **Serverless Worker**. Owner: `${{ values.owner }}`.

## How it runs

- **Infrastructure**: the `ServerlessWorker` claim in
  [gitops](https://github.com/platform-matuuu60/gitops/blob/main/teams/${{ values.team }}/${{ values.name }}.yaml).
  Crossplane provisions the queue `${{ values.team }}-${{ values.name }}`, its dead-letter queue
  `${{ values.team }}-${{ values.name }}-dlq`, the function and an IAM role that can only consume this queue.
- **Processing**: `src/handler.py` receives batches of up to ${{ values.batchSize }} messages. A message
  whose processing raises is returned to the queue alone (partial batch response); after
  ${{ values.maxReceiveCount }} deliveries it moves to the dead-letter queue.
- **Code**: on every push to `main`, CI runs the platform security scan and the tests, then
  the platform deploy workflow publishes `src/` and updates the function code.

## Send a message

From a host that reaches the emulator:

```bash
aws sqs send-message \
  --queue-url "$(aws sqs get-queue-url --queue-name ${{ values.team }}-${{ values.name }} --query QueueUrl --output text)" \
  --message-body '{"hello": "world"}'
```

## Local tests

```bash
python3 -m unittest discover -s tests -v
```
