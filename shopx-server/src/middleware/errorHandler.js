const {constants}=require("../../constants")
const errorHandler = (err, req, res, next) => {
  // const statusCode = res.statusCode ? res.statusCode : 500;

    // ✅ FIX: read status from ERROR, not from response
  const statusCode = err.statusCode || res.statusCode || constants.SERVER_ERROR;

  res.status(statusCode);
  


  switch (statusCode) {
    case constants.VALIDATION_ERROR:
      res.json({
        title: "Validation Error ",
        message: err.message,
        stackTrace: err.stack,
      });

      break;
    case constants.NOT_FOUND:
      res.json({
        title: "Not Found",
        message: err.message,
        stackTrace: err.stack,
      });
      break;
       case constants.UNAUTHORIZED:
      res.json({
        title: " UNAUTHORIZED",
        message: err.message,
        stackTrace: err.stack,
      });
      break;

       case constants.FORBIDDEN:
      res.json({
        title: "FORBIDDEN",
        message: err.message,
        stackTrace: err.stack,
      });
      break;

       case constants.SERVER_ERROR:
      res.json({
        title: "SERVER_ERROR",
        message: err.message,
        stackTrace: err.stack,
      });
      break;
   
    default:
      res.json({
        title: "Unknown Error",
        message: err.message,
        stackTrace: err.stack,
      });
      break;
  }
};

module.exports = errorHandler;
