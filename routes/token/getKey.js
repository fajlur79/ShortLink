import express from "express";
import redis from "../../services/redisClient.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const deviceId = req.cookies.deviceId;
  const activeKey = await redis.get(`devkey:${deviceId}`);
  res.json({ token: activeKey || null });
});

export default router;
