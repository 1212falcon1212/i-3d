# Üretim imajı — next build + next start.
FROM node:24-bookworm-slim AS build

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# NEXT_PUBLIC_* değerleri build sırasında bundle'a gömülür; runtime'da değişmez.
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_SITE_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_SITE_URL=$NEXT_PUBLIC_SITE_URL

# API_URL_INTERNAL build anında da gerekli: Next `rewrites()`'i build sırasında
# değerlendirip .next/routes-manifest.json'a yazar, `next start` yeniden
# hesaplamaz. Yoksa /api/v1 ve /uploads kuralları hiç yazılmaz.
ARG API_URL_INTERNAL
ENV API_URL_INTERNAL=$API_URL_INTERNAL
ARG ALLOW_LOCAL_IMAGE_HOSTS
ENV ALLOW_LOCAL_IMAGE_HOSTS=$ALLOW_LOCAL_IMAGE_HOSTS
RUN npm run build

FROM node:24-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production

COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/next.config.ts ./

EXPOSE 3000
CMD ["npm", "run", "start", "--", "-p", "3000", "-H", "0.0.0.0"]
