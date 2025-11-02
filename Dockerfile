# Use official Node image
FROM node:18

# Create app directory inside the container
WORKDIR /app

# Copy all files from current directory to /app in the container
COPY . .

# Install dependencies
RUN npm install

# Expose port 80
EXPOSE 80

# Start the app
CMD ["node", "index.js"]
