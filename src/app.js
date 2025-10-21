const express = require('express');
const urlRoutes = require('./routes/urlRoutes');
const app = express();

app.use(express.json());

app.use((req, res, next) => {
  req.redis = req.app.get('redisClient');
  next();
});

// --- API Routes ---
app.use('/', urlRoutes);

module.exports = app;
