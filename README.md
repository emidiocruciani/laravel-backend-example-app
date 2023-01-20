# Example app laravel backend

See https://github.com/emidiocruciani/nextjs-frontend-example-app for a frontend example implementation that uses this application.

## Requirements
- docker, docker compose (v2)
- git

## Installation steps
- Create *docker-compose.override.yml* file from existing *docker-compose.override-example-yml* file.
```bash
cp docker-compose.override-example.yml docker-compose.override.yml
```
- Edit secrets environment variables (APP_KEY, passwords, etc.). Never commit these values.

You can now run this application with docker:
```bash
docker compose up
```

## Provisioned services
- application, http://localhost:8080
- mailhog, http://localhost:8025
- adminer, http://localhost:8090
