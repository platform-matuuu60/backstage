# Multi-stage build: compiles inside the image so CI (not the host) does the work.
# Based on the Backstage "multi-stage build" deployment guide.

# Stage 1: keep only package.json files so dependency layers cache well.
FROM node:24-bookworm-slim AS packages
WORKDIR /app
COPY backstage.json package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages packages
COPY plugins plugins
RUN find packages \! -name "package.json" -mindepth 2 -maxdepth 2 -exec rm -rf {} \+

# Stage 2: install all dependencies, type-check and build the backend bundle.
FROM node:24-bookworm-slim AS build
ENV PYTHON=/usr/bin/python3
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 g++ build-essential \
 && rm -rf /var/lib/apt/lists/*
USER node
WORKDIR /app
COPY --from=packages --chown=node:node /app .
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --immutable
COPY --chown=node:node . .
RUN yarn tsc \
 && yarn --cwd packages/backend build \
 && mkdir packages/backend/dist/skeleton packages/backend/dist/bundle \
 && tar xzf packages/backend/dist/skeleton.tar.gz -C packages/backend/dist/skeleton \
 && tar xzf packages/backend/dist/bundle.tar.gz -C packages/backend/dist/bundle

# Stage 3: production dependencies and the bundle only.
FROM node:24-bookworm-slim
ENV PYTHON=/usr/bin/python3
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 g++ build-essential \
 && rm -rf /var/lib/apt/lists/*
USER node
WORKDIR /app
COPY --from=build --chown=node:node /app/.yarn ./.yarn
COPY --from=build --chown=node:node /app/.yarnrc.yml /app/backstage.json ./
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/packages/backend/dist/skeleton/ ./
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"
COPY --from=build --chown=node:node /app/packages/backend/dist/bundle/ ./
COPY --chown=node:node app-config.yaml app-config.production.yaml ./
ENV NODE_ENV=production \
    NODE_OPTIONS="--no-node-snapshot"
EXPOSE 7007
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
