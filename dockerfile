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

# Step 6: Build the Nuxt.js project
RUN npm run build

# Step 7: Create a production image with a lightweight server
FROM node:18-alpine

# Step 8: Set the working directory in the container
WORKDIR /app

# Step 9: Copy the build files from the build stage
COPY --from=build /app ./

# Step 10: Install only production dependencies
RUN npm install --production

# Step 11: Expose the default HTTP port
EXPOSE 3000

# Step 12: Start the Nuxt.js server
CMD ["npm", "start"]