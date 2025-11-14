const asyncHandler = require("express-async-handler");
const db = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const registerUser = asyncHandler(async (req, res) => {
  const { username, email, password, user_type} = req.body;
  if (!username || !email || !password) {
    res.status(400);
    throw new Error("ALL the fields are Mandatory");
  }

  const userAvailable = await db.query("SELECT * FROM users WHERE email = $1", [
    email,
  ]);

  if (userAvailable.rows.length > 0) {
    res.status(400);
    throw new Error("User Already Registered!");
  }

  //hashpassword
  const hashPassword = await bcrypt.hash(password, 10);
  console.log("hashPassword:", hashPassword);

  const result = await db.query(
    "INSERT INTO users (username, email, password,user_type) VALUES ($1, $2, $3,$4) RETURNING *",
    [username, email, hashPassword,user_type||"user"]
  );

  const newUser = result.rows[0];

  console.log("User created:", newUser);

  if (newUser) {
    res.status(201).json({
      message: "User registered successfully",
      user: {
        id: newUser.id,
        username: newUser.username,
        email: newUser.email,
      },
    });
  } else {
    res.status(400);
    throw new Error("User Data is not valid");
  }
});











//login
const loginUser = asyncHandler(async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    res.status(400);
    throw new Error("All fields are Mandatory");
  }
  const result = await db.query("SELECT * FROM users WHERE username = $1", [
    username,
  ]);
  const newUser = result.rows[0];

  //compare password with hashPassword
  if (newUser && (await bcrypt.compare(password, newUser.password))) {
    const accessToken = jwt.sign(
      {
        user: {
           id: newUser.id,
          username: newUser.username,
          email: newUser.email,
          user_type:newUser.user_type
         
        },
      },
      process.env.ACCESS_TOKEN_SECRET,
      { expiresIn: "1d" }
    );
    res.status(200).json({ accessToken });
  } else {
    res.status(401);
    throw new Error("email or password is not valid");
  }
});










const currentUser = asyncHandler(async (req, res) => {
  res.json(req.user);
});

const updateUser = asyncHandler(async (req, res) => {
  const userId = req.user.id; //jwt token
  const { username, email } = req.body;

  if (!username && !email) {
    res.status(400);
    throw new Error("Provide username or email to update ");
  }
  // 🔥 Check if new email already exists

  if (email) {
    const emailCheck = await db.query(
      "SELECT * FROM users WHERE email = $1 AND id != $2",
      [email, userId]
    );
    if (emailCheck.rows.length > 0) {
      res.status(400);
      throw new Error("Email already in use");
    }
  }

  // 🔥 Update user safely
  const result = await db.query(
    "UPDATE users SET username = COALESCE($1, username), email = COALESCE($2, email) WHERE id = $3 RETURNING id, username, email",

    [username, email, userId]
  );
  res.json({
    message: "User updated successfully",
    user: result.rows[0],
  });
});

const getUserById = asyncHandler(async (req, res) => {
  const userId = req.params.id;

  const result = await db.query(
    "SELECT id, username, email FROM users WHERE id = $1",
    [userId]
  );

  if (result.rows.length === 0) {
    res.status(404);
    throw new Error("User not found");
  }

  res.json(result.rows[0]);
});

const deleteUser = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const result = await db.query("DELETE FROM users WHERE id = $1 RETURNING *", [
    userId,
  ]);

  if (result.rows.length === 0) {
    res.status(404);
    throw new Error("User not found");
  }

  res.json({ message: "User deleted successfully" });
});

//admin only
const deleteUserById = asyncHandler(async (req, res) => {
  const userId = req.params.id; // user ID from URL

  // DELETE query
  const result = await db.query(
    "DELETE FROM users WHERE id = $1 RETURNING *",
    [userId]
  );

  if (result.rows.length === 0) {
    res.status(404);
    throw new Error("User not found");
  }

  res.json({
    message: "User deleted successfully by admin",
    deleted_user: result.rows[0],
  });
});


//Admin
const getAllUsers = asyncHandler(async (req, res) => {
  const result = await db.query("SELECT id, username, email, user_type FROM users ORDER BY id ASC");

  res.json({
    message: "All users fetched successfully",
    users: result.rows,
  });
});



module.exports = {
  registerUser,
  loginUser,
  currentUser,
  updateUser,
  getUserById,
  deleteUser,
  deleteUserById,
  getAllUsers
};
