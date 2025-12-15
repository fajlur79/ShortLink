import 'dotenv/config';
import express from "express";
import cookieParser from "cookie-parser";
import router from "./routes/index.js";
import deviceMiddleware from "./middleware/device.js";
import { ipLimiter } from './middleware/rateLimit.js';
import logger from './utils/logger.js';

const app = express();

app.use(express.json());
app.use(cookieParser());
app.use(deviceMiddleware);

app.use((req, res, next)=>{
    const forwardIP =req.headers['x-forwarded-for'];
    const socketIP = req.socket.remoteAddress;
    logger.info("Incoming Request:", {
        ip: forwardIP || socketIP,
        url: req.url,
        method: req.method
    })
    next();
})

app.use(ipLimiter)


app.get("/", (req, res)=>{
    res.status(200).send("Welcome to ShortLink.")
});

app.use("/", router);

const PORT = process.env.PORT;

if(process.env.NODE_ENV != 'test'){
    const PORT = process.env.PORT;
    app.listen(PORT,() => {
        logger.info(`ShortLink online on port ${PORT}`);
});
}

export default app;