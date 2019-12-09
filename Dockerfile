FROM node:latest
WORKDIR /app
COPY dist ./
EXPOSE 80
ENTRYPOINT ["node", "index.js"]
