import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

from handler import handler  # noqa: E402


def record(message_id, body):
    return {"messageId": message_id, "body": body}


class HandlerTest(unittest.TestCase):
    def test_valid_batch_reports_no_failures(self):
        event = {"Records": [record("1", json.dumps({"order": 1})), record("2", json.dumps({"order": 2}))]}
        self.assertEqual(handler(event, None), {"batchItemFailures": []})

    def test_only_the_failed_message_is_retried(self):
        event = {"Records": [record("ok", json.dumps({"order": 1})), record("bad", "not json")]}
        with self.assertLogs(level="ERROR"):
            response = handler(event, None)
        self.assertEqual(response, {"batchItemFailures": [{"itemIdentifier": "bad"}]})


if __name__ == "__main__":
    unittest.main()
