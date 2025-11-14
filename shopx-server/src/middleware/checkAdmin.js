const checkAdmin = (req, res, next) => {
  if (req.user.user_type !== "admin") {
    res.status(403);
    throw new Error("Access denied. Admins only.");
  }
  next();
};

module.exports = checkAdmin;
