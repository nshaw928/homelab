FROM node:20-alpine AS build
RUN corepack enable
RUN apk add --no-cache git
WORKDIR /app
RUN git clone --recurse-submodules --depth=1 https://github.com/stoatchat/for-web.git .
ARG VITE_API_URL
ARG VITE_WS_URL
ARG VITE_MEDIA_URL
ARG VITE_PROXY_URL
RUN pnpm install --frozen-lockfile
WORKDIR /app/packages/client
RUN pnpm exec vite build

FROM nginx:alpine
COPY --from=build /app/packages/client/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 5000
