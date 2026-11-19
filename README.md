# IDP Backstage

Developer portal of the [IDP platform](https://github.com/platform-matuuu60/platform): software catalog, templates that create apps end to end, and TechDocs.

- Backstage 1.57, new frontend system
- Image built by CI with a multi-stage Dockerfile and published to `ghcr.io/platform-matuuu60/backstage`
- Deployed by ArgoCD from the platform repo (`kubernetes/apps`)

## Local development

Requires Node 24 and Yarn (via Corepack).

```bash
yarn install
yarn start
```

## Image

```bash
docker build -t backstage .
```
