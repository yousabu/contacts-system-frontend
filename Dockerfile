FROM node:21-alpine as builder

# Copy dependency definitions
COPY package.json package-lock.json ./

RUN npm i && mkdir /app && mv ./node_modules ./app

# Change directory so that our commands run inside this new directory
WORKDIR /app

# Get all the code needed to run the app
COPY . /app/

# Build server side bundles
RUN npm run build

FROM node:21-alpine
## From 'builder' copy published folder
COPY --from=builder /app /app

WORKDIR /app
# Expose the port the app runs in
EXPOSE 4000

USER node

CMD ["node", "dist/contacts/server/server.mjs"]
