# Use official Node image
FROM node:18

# Create app directory inside the container
WORKDIR /app

# Copy app files
COPY ./app /app

# Install dependencies
RUN npm install

# Expose port 8080
EXPOSE 80

# Start the app
CMD ["node", "index.js"]
