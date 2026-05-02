# Flutter Web estático — Railway / Docker (nginx escuta $PORT)
# syntax=docker/dockerfile:1
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG API_BASE_URL=http://127.0.0.1:8000
ARG FIREBASE_WEB_API_KEY=
ARG FIREBASE_WEB_APP_ID=
ARG FIREBASE_WEB_MESSAGING_SENDER_ID=
ARG FIREBASE_WEB_PROJECT_ID=
ARG FIREBASE_WEB_AUTH_DOMAIN=
ARG FIREBASE_WEB_STORAGE_BUCKET=
ARG FIREBASE_WEB_MEASUREMENT_ID=

RUN flutter build web --release \
  --dart-define=API_BASE_URL="${API_BASE_URL}" \
  --dart-define=FIREBASE_WEB_API_KEY="${FIREBASE_WEB_API_KEY}" \
  --dart-define=FIREBASE_WEB_APP_ID="${FIREBASE_WEB_APP_ID}" \
  --dart-define=FIREBASE_WEB_MESSAGING_SENDER_ID="${FIREBASE_WEB_MESSAGING_SENDER_ID}" \
  --dart-define=FIREBASE_WEB_PROJECT_ID="${FIREBASE_WEB_PROJECT_ID}" \
  --dart-define=FIREBASE_WEB_AUTH_DOMAIN="${FIREBASE_WEB_AUTH_DOMAIN}" \
  --dart-define=FIREBASE_WEB_STORAGE_BUCKET="${FIREBASE_WEB_STORAGE_BUCKET}" \
  --dart-define=FIREBASE_WEB_MEASUREMENT_ID="${FIREBASE_WEB_MEASUREMENT_ID}"

FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx-docker-entrypoint.sh /nginx-docker-entrypoint.sh
RUN chmod +x /nginx-docker-entrypoint.sh

ENTRYPOINT ["/nginx-docker-entrypoint.sh"]
