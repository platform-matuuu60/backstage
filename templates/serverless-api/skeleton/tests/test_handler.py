import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

from handler import handler  # noqa: E402


class HandlerTest(unittest.TestCase):
    def test_default_greeting(self):
        response = handler({}, None)
        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(json.loads(response["body"])["message"], "Hello, world!")

    def test_name_from_query_string(self):
        response = handler({"queryStringParameters": {"name": "idp"}}, None)
        self.assertEqual(json.loads(response["body"])["message"], "Hello, idp!")


if __name__ == "__main__":
    unittest.main()
