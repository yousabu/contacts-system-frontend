
# APP (Angular) 

This project contains the Angular Application

## Features

- Docker Compose for Angular and Nginx service
- Dockerfile to create a Docker image for the app
- Azure Pipeline to build and push the image
- The pipeline will use a Helm chart template located in another repo, update the values.yaml, and then deploy


## Development server

Run `npm start` to start the api server in development mode (using nodemon).

### Dockerfile Production

```dockerfile
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

```
## Nginx
- We use Nginx to Manage Connection Between Frontend And Backend.
```nginx.conf
  events {
    worker_connections 1024;
  }
http {
  upstream frontend {
    # These are references to our backend containers, facilitated by
    # Compose, as defined in docker-compose.yml
    server contacts_angular:4000;
  } 
  upstream backend {
    # These are references to our backend containers, facilitated by
    # Compose, as defined in docker-compose.yml
    server contacts_express:3000;
  }
  

 server {
    listen 80;
    server_name frontend;
    server_name backend;

    location / {
       resolver 127.0.0.11 valid=30s;
       proxy_pass http://frontend;
       proxy_set_header Host $host;
    }
    location /api {
      resolver 127.0.0.11 valid=30s;
       proxy_pass http://backend;
       proxy_set_header Host $host;
    }
  }
}

```
## Run Docker Compose

Run `docker-compose up -d` to start the backend express service and MongoDB.
- The backend service will now be available at <Public Server IP>:80, and the frontend can start using it.

Run `docker-compose down` to stop.

### Azure Pipeline

``` azure-pipelines.yml
Pipeline
│
├── Trigger: Branches include 'main'
│
├── Pool: yarb
│
├── Resources
│   └── Repositories
│       └── helmchart-repo (GitHub)
│
├── Steps
│   │
│   ├── Check Helm Installation
│   │
│   ├── Set Image Tags
│   │
│   ├── Build and Push Docker Image with Unique Tag
│   │
│   ├── Tag and Push Docker Image with Latest Tag
│   │
│   ├── Checkout helmchart-repo
│   │
│   ├── Check Directory Files
│   │
│   ├── Update Image Tag in values.yaml
│   │
│   ├── Deploy Express HelmChart
│   │
│   ├── Rollback Helm Deployment (on deployment failure)
│   │
│   ├── Clean Up Old Docker Images Locally
│   │
│   ├── Clean WORKDIR
│      └── Clean Workspace 
   
```

* HelmChart URL: https://github.com/yousabu/contacts-system-helmchart.git
* Backend URL  : https://github.com/yousabu/contacts-system-backend.git

