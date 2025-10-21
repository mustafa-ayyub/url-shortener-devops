// Load environment variables from .env file
require('dotenv').config();

const express = require('express');
const { createClient } = require('redis');
const urlRoutes = require('./routes/urlRoutes');

const app = express();
const port = process.env.PORT || 3000;

// Middleware to parse JSON bodies from incoming requests
app.use(express.json());

// --- Redis Client Setup ---
const redisClient = createClient({
  url: process.env.REDIS_URL
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));

(async () => {
  try {
    await redisClient.connect();
    console.log('Successfully connected to Redis.');
  } catch (err) {
    console.error('Could not connect to Redis:', err);
    process.exit(1); // Exit if we can't connect to the database
  }
})();

// Middleware to make the Redis client available to all routes
app.use((req, res, next) => {
  req.redis = redisClient;
  next();
});

// --- API Routes ---
app.use('/', urlRoutes);

// --- Server Startup ---
app.listen(port, () => {
  console.log(`URL Shortener service listening on port ${port}`);
});
