const express = require('express');
const { nanoid } = require('nanoid');

const router = express.Router();

router.post('/shorten', async (req, res) => {
  const { originalUrl } = req.body;

  // Basic validation
  if (!originalUrl) {
    return res.status(400).json({ error: 'originalUrl is required' });
  }

  try {
    const shortCode = nanoid(8);
    const redisClient = req.redis;

    await redisClient.set(shortCode, originalUrl, { EX: 86400 });

    const shortUrl = `${req.protocol}://${req.get('host')}/${shortCode}`;

    return res.status(201).json({ originalUrl, shortUrl, shortCode });
  } catch (error) {
    console.error('Error creating short URL:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.get('/:shortCode', async (req, res) => {
  const { shortCode } = req.params;
  const redisClient = req.redis;

  try {
    const originalUrl = await redisClient.get(shortCode);

    if (originalUrl) {
      return res.redirect(originalUrl);
    } else {
      return res.status(404).json({ error: 'Short URL not found' });
    }
  } catch (error) {
    console.error('Error retrieving URL:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
