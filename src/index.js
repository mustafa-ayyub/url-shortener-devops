require('dotenv').config();

const { createClient } = require('redis');
const app = require('./app');

const port = process.env.PORT || 3000;

const redisClient = createClient({
  url: process.env.REDIS_URL,
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));

(async () => {
  try {
    await redisClient.connect();
    console.log('Successfully connected to Redis.');

    app.set('redisClient', redisClient);

    app.listen(port, () => {
      console.log(`URL Shortener service listening on port ${port}`);
    });
  } catch (err) {
    console.error('Could not connect to Redis:', err);
  }
})();
