FROM node:20-bullseye-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Install dependencies for build
FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apt-get update && \
    apt-get install -y python3 build-essential

# Install node modules using pnpm with caching
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

# Deploy production build
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

# Create the final stage for running the app
FROM base AS api
WORKDIR /app

# Copy the built app from the previous stage
COPY --from=build /prod/api /app
COPY --from=build /app/.git /app/.git

# Create the .git/config file if it's missing
RUN mkdir -p /app/.git && \
    echo "[core]" > /app/.git/config && \
    echo "    repositoryformatversion = 0" >> /app/.git/config && \
    echo "    filemode = true" >> /app/.git/config && \
    echo "    bare = false" >> /app/.git/config && \
    echo "    logallrefupdates = true" >> /app/.git/config && \
    echo "[remote \"origin\"]" >> /app/.git/config && \
    echo "    url = https://github.com/imputnet/cobalt.git" >> /app/.git/config && \
    echo "    fetch = +refs/heads/*:refs/remotes/origin/*" >> /app/.git/config && \
    echo "[branch \"main\"]" >> /app/.git/config && \
    echo "    remote = origin" >> /app/.git/config && \
    echo "    merge = refs/heads/main" >> /app/.git/config

EXPOSE 9000

# Start the application
CMD [ "node", "src/cobalt", "--host", "0.0.0.0", "--port", "9000" ]
