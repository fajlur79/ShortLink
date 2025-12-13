import redis from "../services/redisClient.js";
import { todayKey } from "../utils/dateKey.js";
import rateLimit from "express-rate-limit";

const DAILY_LIMIT = 100;

export async function rateLimitToken(req, res, next) {
  const token = req.headers["x-api-key"];

  if (!token) {
    return res.status(401).json({ error: "API token required" });
  }

  const valid = await redis.get(`validtoken:${token}`);
  if (!valid) {
    return res.status(401).json({ error: "invalid token" });
  }

  const date = todayKey();
  const usageKey = `tokenuse:${token}:${date}`;

  const usage = await redis.incr(usageKey);

  if (usage === 1) {
    const now = new Date();
    const midnight = new Date(now);
    midnight.setUTCHours(24, 0, 0, 0);
    const ttl = Math.floor((midnight - now) / 1000);
    await redis.expire(usageKey, ttl);
  }

  if (usage > DAILY_LIMIT) {
    return res.status(429).json({ error: "daily limit reached" });
  }

  next();
}

export const ipLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, 
  max: 100, 
  message: {
    status: 429,
    error: "Too many requests from this IP, please try again after 15 minutes"
  },
  standardHeaders: true, 
  legacyHeaders: false, 

  
  keyGenerator: (req) => {
    return req.headers['x-forwarded-for'] || req.socket.remoteAddress;
  }
});