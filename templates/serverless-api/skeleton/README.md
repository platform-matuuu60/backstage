# ${{ values.name }}

${{ values.description }}

Created from the Backstage template **Serverless API**. Owner: `${{ values.owner }}`.

## How it runs

- **Infrastructure**: the `ServerlessApp` claim in
  [gitops](https://github.com/platform-matuuu60/gitops/blob/main/teams/${{ values.team }}/${{ values.name }}.yaml).
  Crossplane provisions the Lambda function, its IAM role and an HTTP API.
- **Code**: `src/handler.py`. On every push to `main`, CI runs the platform security
  scan and the tests, then publishes `src/` to `idp-artifacts/${{ values.name }}/latest.zip`
  and updates the function code.

## Local tests

```bash
python3 -m unittest discover -s tests -v
```
