const asyncHandler = require("express-async-handler");
const service = require("./dashboard.service");

exports.getDashboard = asyncHandler(async (req, res) => {
  const data = await service.getDashboardData();
  res.json(data);
});


exports.getSalesChart = asyncHandler(async (req, res) => {
  const { range } = req.query;

  if (!["day", "week", "month"].includes(range)) {
    return res.status(400).json({
      message: "Invalid range. Use day, week, or month.",
    });
  }

  const data = await service.getSalesChart(range);
  res.json(data);
});
