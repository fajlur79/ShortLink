import client from 'prom-client'


const register = new client.Registry();

client.collectDefaultMetrics({ register });

const httpRequestDurationMicroseconds = new client.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route','status_code' ],
    buckets: [0.1, 0.5, 1, 1.5, 2, 5],
    registers: [register]
});

export const metricsMiddleware =(req, res, next)=>{
    const start = Date.now();
    res.on('finish', ()=>{
        const duration =Date.now()- start;
        httpRequestDurationMicroseconds.labels(req.method, req.route ? req.route.path : req.path, res.statusCode).observe(duration / 1000);
    });
    next();
};

export const metricsEndpoint = async (req, res)=>{
    res.setHeader('Content-Type', register.contentType);
    res.send(await register.metrics())
};