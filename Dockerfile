# Stage 1
FROM node:16-alpine as build-step

ARG APP_NAME

RUN mkdir -p /app
WORKDIR /app
COPY ["decorate-angular-cli.js", "package*.json", "/app/"]

# Install Nx CLI globally
RUN npm install -g nx

RUN apk update && apt add curl

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.04.0-ce.tgz \
                            && tar xzvf docker-17.04.0-ce.tgz \
                            && mv docker/docker /usr/local/bin \
                            && rm -r docker docker-17.04.0-ce.tgz
RUN apk update && apk add git
# RUN npm install --force
COPY . /app
# RUN npx nx build ${APP_NAME} --configuration=production --base-href /${APP_NAME}/

# # Stage 2
# FROM nginx:1.22.0-alpine

# ARG APP_NAME

# RUN rm -rf /usr/share/nginx/html/*
# COPY --from=build-step /app/dist/apps/${APP_NAME} /usr/share/nginx/html
# COPY nginx.default.conf /etc/nginx/conf.d/default.conf