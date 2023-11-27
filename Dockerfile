FROM node:alpine AS deps

# Copy project files to working directory
COPY . .

# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
# Change repository and update packages
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache libc6-compat

# Install dependencies based on the preferred package manager
RUN npm install -g npm@latest
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi
RUN npm run build

## Optimized Stage for Production
FROM nginx

WORKDIR /www

ENV NODE_ENV production

COPY --from=deps ./dist /www/

ADD ./nginx.default.conf /etc/nginx/conf.d/default.conf

# Expose the internal port
EXPOSE 80

RUN chmod -R 755 /www
