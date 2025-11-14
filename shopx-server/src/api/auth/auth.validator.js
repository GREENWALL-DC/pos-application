const registerValidator = (req, res, next) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password) {
    res.status(400);
    return next(new Error("All fields are required"));
  }
  next();
};

const loginValidator = (req, res, next) => {
  const { username, password } = req.body;
  if (!username || !password) {
    res.status(400);
    return next(new Error("username and password required"));
  }
  next();
};

module.exports = { registerValidator, loginValidator };
