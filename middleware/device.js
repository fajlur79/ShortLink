import { nanoid } from "nanoid";

export default function deviceMiddleware(req, res, next) {
  const existingId = req.cookies.deviceId;

  if(existingId){
    req.deviceId = existingId;
    return next();
  }

  const isProduction = process.env.NODE_ENV === 'production';
  const newId = nanoid();
  res.cookie("deviceId", newId, {
    maxAge: 30 * 24 * 60 * 60 * 1000,
    httpOnly: true,
    secure: isProduction,
    sameSite: isProduction? 'None' : "lax",
  });
  

  req.deviceId = newId;
  console.log(`[New Id]:${newId}, secure? : ${isProduction}`)
  
  next();
}
