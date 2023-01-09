FROM node:19-alpine
RUN mkdir -p /usr/app
COPY app/. /usr/app/

WORKDIR /usr/app
RUN ls

# In the file server.js, the listening port is set.
EXPOSE 3000

RUN npm install
CMD ["node", "server.js"]
