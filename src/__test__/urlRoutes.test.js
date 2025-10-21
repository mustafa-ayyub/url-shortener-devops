const request = require('supertest');
const app = require('../app');

jest.mock('nanoid', () => ({
  nanoid: jest.fn(() => 'abcdefgh'),
}));

const mockRedisClient = {
  set: jest.fn(),
  get: jest.fn(),
};

beforeEach(() => {
  app.set('redisClient', mockRedisClient);
  mockRedisClient.set.mockClear();
  mockRedisClient.get.mockClear();
});

describe('URL Shortener API', () => {
  describe('POST /shorten', () => {
    it('should create a short URL for a valid original URL', async () => {
      const response = await request(app)
        .post('/shorten')
        .send({ originalUrl: 'https://www.google.com' });

      expect(response.statusCode).toBe(201);
      expect(response.body).toHaveProperty('shortUrl');
      expect(response.body.shortCode).toBe('abcdefgh');
      expect(mockRedisClient.set).toHaveBeenCalledWith(
        'abcdefgh',
        'https://www.google.com',
        { EX: 86400 }
      );
    });

    it('should return a 400 error if originalUrl is missing', async () => {
      const response = await request(app).post('/shorten').send({});
      expect(response.statusCode).toBe(400);
      expect(response.body).toEqual({ error: 'originalUrl is required' });
    });
  });

  describe('GET /:shortCode', () => {
    it('should redirect to the original URL for a valid short code', async () => {
      mockRedisClient.get.mockResolvedValue('https://www.google.com');

      const response = await request(app).get('/abcdefgh');

      expect(response.statusCode).toBe(302);
      expect(response.headers.location).toBe('https://www.google.com');
      expect(mockRedisClient.get).toHaveBeenCalledWith('abcdefgh');
    });

    it('should return a 404 error for an invalid short code', async () => {
      mockRedisClient.get.mockResolvedValue(null);

      const response = await request(app).get('/invalidcode');
      expect(response.statusCode).toBe(404);
      expect(response.body).toEqual({ error: 'Short URL not found' });
    });
  });
});
