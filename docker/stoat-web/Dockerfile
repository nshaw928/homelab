FROM node:20-alpine AS build
RUN corepack enable
RUN apk add --no-cache git
WORKDIR /app
RUN git clone --recurse-submodules --depth=1 https://github.com/stoatchat/for-web.git .
# assets submodule uses SSH (private) and gets skipped — create placeholders
COPY create-placeholder-assets.sh /tmp/
RUN sh /tmp/create-placeholder-assets.sh
ARG VITE_API_URL
ARG VITE_WS_URL
ARG VITE_MEDIA_URL
ARG VITE_PROXY_URL
RUN pnpm install --frozen-lockfile
# build workspace dependencies before client (lingui-solid, stoat.js, etc.)
RUN pnpm -r --if-present run build
WORKDIR /app/packages/client
RUN pnpm exec vite build

FROM nginx:alpine
COPY --from=build /app/packages/client/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 5000
