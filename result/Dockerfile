FROM node:18-slim@sha256:f9ab18e354e6855ae56ef2b290dd225c1e51a564f87584b9bd21dd651838830e

# Add curl for healthcheck and a minimal init process.
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --system app && useradd --system --gid app --create-home --home-dir /home/app app

WORKDIR /usr/local/app

RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci && \
    npm cache clean --force && \
    mv /usr/local/app/node_modules /node_modules

COPY . .
RUN mkdir -p /home/app && \
    chown -R app:app /home/app /usr/local/app && \
    chmod -R a+rX /usr/local/app

ENV PORT=80
USER app
EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
