const express = require("express");
const {registerUser,loginUser,currentUser,updateUser,getUserById, deleteUser,deleteUserById,getAllUsers}=require("../controllers/authController");
const validateToken =require("../middleware/validateTokenHandler");
const checkAdmin = require("../middleware/checkAdmin");


const router = express.Router();


// Public routes
router.post("/register",registerUser);
router.post("/login",loginUser);
// Protected route (requires token)
router.get("/current", validateToken ,currentUser);
router.put("/update",validateToken,updateUser);
router.get("/user/:id",validateToken, getUserById);
router.delete("/delete", validateToken, deleteUser);
router.delete("/user/:id",validateToken,checkAdmin,deleteUserById);
//admin
router.get("/users",validateToken,checkAdmin,getAllUsers);


module.exports=router;