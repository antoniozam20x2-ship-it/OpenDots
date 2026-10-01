FROM node:24-bookworm-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:24-bookworm-slim AS final
ENV NODE_ENV=production HOST=0.0.0.0 PORT=4310 DATABASE_PATH=/data/opendots.sqlite
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev && mkdir -p /data && chmod 777 /data
COPY --from=build /app/dist ./dist
# NOTE: intentionally running as root (no USER node) so the process can
# create the SQLite file on Railway's mounted volume, which arrives
# owned by root and would otherwise cause "unable to open database file".
EXPOSE 4310
CMD ["node", "dist/server/server/index.js"]
