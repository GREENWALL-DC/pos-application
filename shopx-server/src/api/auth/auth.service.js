const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const repo = require("./auth.repository");
// const otpRepo = require("./auth.repository");
const { sendEmail } = require("../../utils/email"); // ✅ ADD
const { sendWhatsApp } = require("../../utils/whatsapp");
const { generateOTP } = require("../../utils/otp");
const { sendSMS } = require("../../utils/sms");

const register = async ( data,reqUser ) => {
   const { username, email, password, phone,user_type } = data;

  if (!username || !email || !password || !phone) {
    throw new Error("ALL fields are mandatory");
  }

  
  // 🔥 Check if any admin exists
  const adminCount = await repo.countAdmins();

  let finalType;

  // First user EVER → admin
  if (adminCount === 0) {
    finalType = "admin";
  } else {
    // If admin exists → only admin can register new accounts
    if (!reqUser || reqUser.user_type !== "admin") {
      throw new Error("Only admin can create new accounts");
    }
     // If admin sets user_type=admin → create admin
    // else create normal user
    finalType = user_type === "admin" ? "admin" : "user";
  }



  const existing = await repo.findUserByEmail(email);
  if (existing) throw new Error("User Already Registered!");

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await repo.createUser({
    username,
    email,
    passwordHash,
    phone,
    user_type: finalType,
  });

  return {
    id: user.id,
    username: user.username,
    email: user.email,
    user_type: user.user_type,
    phone: user.phone,
  };
};

const login = async ({ username, password }) => {
  if (!username || !password) throw new Error("All fields are Mandatory");

  const user = await repo.findUserByUsername(username);
  if (!user) throw new Error("Invalid credentials");

  const match = await bcrypt.compare(password, user.password);
  if (!match) throw new Error("Invalid credentials");

    // 🚨 BLOCK ADMINS FROM EMPLOYEE LOGIN
  if (user.user_type === "admin") {
    throw new Error("Admins must login through admin route");
  }

  const accessToken = jwt.sign(
    {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        user_type: user.user_type,
      },
    },
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: "1d" }
  );

  // return { accessToken };

  // ✅ CRUCIAL FIX: Return BOTH token AND user data
  return {
    accessToken,
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
      user_type: user.user_type, // 🔵 Flutter needs this!
    },
  };
};



const loginAdmin = async ({ username, password }) => {
  if (!username || !password) throw new Error("All fields are mandatory");

  const user = await repo.findUserByUsername(username);
  if (!user) throw new Error("Invalid credentials");

  if (user.user_type !== "admin") {
    throw new Error("Not authorized. Only admin can login.");
  }

  const match = await bcrypt.compare(password, user.password);
  if (!match) throw new Error("Invalid credentials");

  const accessToken = jwt.sign(
    {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        user_type: user.user_type,
      },
    },
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: "1d" }
  );

  return {
    accessToken,
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
      user_type: user.user_type,
    },
  };
};




const updateUser = async (userId, { username, email }) => {
  if (!username && !email) throw new Error("Provide username or email");

  if (email) {
    const check = await repo.findUserByEmail(email);
    if (check && check.id !== userId) throw new Error("Email already in use");
  }

  const updated = await repo.updateUser(userId, username, email);
  if (!updated) throw new Error("User not found");

  return updated;
};

const getUserById = async (id) => {
  const user = await repo.findUserById(id);
  if (!user) throw new Error("User not found");
  return user;
};

const deleteSelf = async (userId) => {
  const deleted = await repo.deleteUserById(userId);
  if (!deleted) throw new Error("User not found");
};

const deleteUserByAdmin = async (id) => {
  const deleted = await repo.deleteUserById(id);
  if (!deleted) throw new Error("User not found");
  return deleted;
};

const getAllUsers = async () => {
  return await repo.getAllUsers();
};

//ownerLogin
const loginOwner = async ({ username, password }) => {
  const user = await repo.findUserByUsername(username);

  if (!user) throw new Error("user not found ");
  if (user.user_type !== "admin")
    throw new Error("Not authorized. Only admin can login.");

  const match = await bcrypt.compare(password, user.password);
  if (!match) throw new Error("Invalid credentials");

  // Temporary short-lived token (5 min)
  const tempToken = jwt.sign({ id: user.id }, process.env.ACCESS_TOKEN_SECRET, {
    expiresIn: "5m",
  });

  return { tempToken };
};

const sendOTP = async ({ userId, method }) => {
  // normalize method names
  method = method.toLowerCase().replace(" ", "_");

  const user = await repo.findUserById(userId);
  if (!user) throw new Error("User not found");

  const otp = generateOTP();

  await repo.saveOTP(user.id, otp, method);

  // EMAIL OTP (FREE - WORKS NOW)
  if (method === "email") {
    if (!user.email) throw new Error("User email not found");
    await sendEmail(user.email, otp);
  }

  // 🟢 WHATSAPP OTP (FREE TRIAL)
  else if (method === "whatsapp") {
    if (!user.phone) throw new Error("User phone number not found");
    await sendWhatsApp(user.phone, otp); // ✅ FIXED: WhatsApp implemented
  }

  // 🔴 SMS OTP (REQUIRES PAID TWILIO)
  else if (method === "sms") {
    if (!user.phone) throw new Error("User phone number not found");
    await sendSMS(user.phone, `Your login OTP is: ${otp}`);
  } else {
    throw new Error("Invalid OTP method. Use: email, whatsapp, or sms"); // ✅ ADDED: Error for invalid methods
  }

  return {
    message: "OTP sent successfully",
    method: method,
    destination: method === "email" ? user.email : user.phone, // ✅ ADDED: Return destination info
  };
};

const verifyOTP = async ({ userId, otp }) => {
  const found = await repo.findValidOTP(userId, otp);
  if (!found) throw new Error("Invalid or expired OTP");

  await repo.deleteOTP(userId);

  const user = await repo.findUserById(userId);

  const accessToken = jwt.sign(
    {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        user_type: user.user_type, // Full user information
      },
    },
    process.env.ACCESS_TOKEN_SECRET, // Secret key
    { expiresIn: "1d" } // Token valid for 24 hours
  );

  return { accessToken, user };
};

module.exports = {
  register,
  login,
  loginAdmin,
  updateUser,
  getUserById,
  deleteSelf,
  deleteUserByAdmin,
  getAllUsers,
  loginOwner,
  sendOTP,
  verifyOTP,
};
