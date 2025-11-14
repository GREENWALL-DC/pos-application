const express = require("express");
const cors = require("cors");
require("dotenv").config();
const app = express();
const errorHandler = require("./middleware/errorHandler");
const authRoutes = require("./api/auth/auth.routes");

//middleware
app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);

//test route
app.get("/", (req, res) => {
  res.send("ShopX Backend Running 🚀");
});

app.use((req, res) => {
  res.status(404).json({ message: "Route not found" });
});


app.use(errorHandler);



const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
