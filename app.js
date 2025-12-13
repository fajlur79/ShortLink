import 'dotenv/config';
import express from "express";
import cookieParser from "cookie-parser";
import router from "./routes/index.js";
import deviceMiddleware from "./middleware/device.js";
import { ipLimiter } from './middleware/rateLimit.js';

const app = express();

app.use(express.json());
app.use(cookieParser());
app.use(deviceMiddleware);

app.use((req, res, next)=>{
    const forwardIP =req.headers['x-forwarded-for'];
    const socketIP = req.socket.remoteAddress;
    console.log(`[REQUEST] IP: ${forwardIP || socketIP} | URL: ${req.url}`);
    next();
})

app.use(ipLimiter)

app.use(express.json());

app.use("/", router);

const PORT = process.env.PORT;


app.listen(PORT,() => console.log(`Shortener online on port ${PORT}`));