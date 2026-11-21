import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def process(message):
    """Business logic for one message. Raise to retry it; after the queue's
    maxReceiveCount deliveries it moves to the dead-letter queue."""
    logger.info("processed %s", json.dumps(message))


def handler(event, context):
    # Partial batch response: only the failed messages go back to the queue.
    failures = []
    for record in event.get("Records", []):
        try:
            process(json.loads(record["body"]))
        except Exception:
            logger.exception("message %s failed", record.get("messageId"))
            failures.append({"itemIdentifier": record["messageId"]})
    return {"batchItemFailures": failures}
