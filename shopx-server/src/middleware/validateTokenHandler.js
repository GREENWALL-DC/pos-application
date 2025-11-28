// const asyncHandler = require ("express-async-handler");
// const jwt = require ("jsonwebtoken");

// const validateToken = asyncHandler(async(req,res,next)=>{
//     let token;
//     let authHeader = req.headers.Authorization || req.headers.authorization
//     if(authHeader && authHeader.startsWith("Bearer")){
//         token = authHeader.split(" ")[1];
//         jwt.verify(token,process.env.ACCESS_TOKEN_SECRET,(err,decoded)=>{
//             if(err){
//                 res.status(401);
//                 throw new Error("User is not authorized");
//         }
// req.user = decoded.user;
// next();
//     });

//     if(!token){
//         res.status(401);
//                 throw new Error("User is not authorized or Token is misssing ");
//     }
//     }
// });

// module.exports=validateToken;

const asyncHandler = require("express-async-handler");
const jwt = require("jsonwebtoken");
const repo = require("../api/auth/auth.repository");

const validateToken = asyncHandler(async (req, res, next) => {
  // 1️⃣ Check if ANY admin exists
  const adminCount = await repo.countAdmins();

  // 2️⃣ If NO admin exists → bypass token validation
  if (adminCount === 0) {
    return next();
  }

  // 3️⃣ After admin exists → enforce token validation
  let authHeader = req.headers.Authorization || req.headers.authorization;

  if (authHeader && authHeader.startsWith("Bearer")) {
    const token = authHeader.split(" ")[1];

    jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, decoded) => {
      if (err) {
        res.status(401);
        throw new Error("User is not authorized");
      }
      // 🔥 CASE 1: tempToken → { id: userId }
      if (decoded.id) {
        req.user = { id: decoded.id };
      }

      // 🔥 CASE 2: normal login token → { user: {...} }
      else if (decoded.user) {
        req.user = decoded.user;
      }
      next();
    });
  } else {
    res.status(401);
    throw new Error("User is not authorized or Token is missing");
  }
});

module.exports = validateToken;
