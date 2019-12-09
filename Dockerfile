FROM node:slim
WORKDIR /app
COPY dist ./
EXPOSE 80
ENTRYPOINT ["node", "index.js"]
