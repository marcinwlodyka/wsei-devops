# Step 1: Use a Node.js image as the base image
FROM node:18 AS build

# Step 2: Set the working directory in the container
WORKDIR /app

# Step 3: Copy package.json and package-lock.json (if present)
COPY package*.json ./

# Step 4: Install dependencies
RUN npm install

# Step 5: Copy the entire project into the container
COPY . .

# Step 6: Build the Vue.js project with Vite
RUN npm run build

# Step 7: Create a production image with a lightweight server
FROM nginx:alpine

# Step 8: Copy the build files from the build stage to the nginx public directory
COPY --from=build /app/dist /usr/share/nginx/html

# Step 9: Expose the default HTTP port
EXPOSE 80

# Step 10: Start Nginx server
CMD ["nginx", "-g", "daemon off;"]