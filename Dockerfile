# Base step
FROM node:20 AS base

# Dependencies step
FROM base AS dependencies
WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN npm install

# Build step
FROM base AS build
WORKDIR /usr/src/app
COPY . .
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
RUN npm run build
RUN npm prune --prod

# Deploy step
FROM node:20-alpine3.19 AS deploy
WORKDIR /usr/src/app
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/package-lock.json ./package-lock.json
COPY --from=build /usr/src/app/prisma ./prisma
RUN npx prisma generate

EXPOSE 3333

CMD ["npm", "run", "start"]
