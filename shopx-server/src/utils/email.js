// const nodemailer = require("nodemailer");

// const transporter = nodemailer.createTransport({
//   service: "gmail",
//   auth: {
//     user: process.env.EMAIL_USER,
//     pass: process.env.EMAIL_PASSWORD,
//   },
// });

// transporter.verify((err, success) => {
//   if (err) {
//     console.log("Email transporter error:", err);
//   } else {
//     console.log("Gmail email server is ready");
//   }
// });

// exports.sendEmail = async (to, otp) => {
//   try {
//     const mailOptions = {
//       from: `"Joy Brews" <${process.env.EMAIL_USER}>`,
//       to, 
//       subject: "Your Login OTP Code",
//       html: `
//         <h2>Your OTP Code</h2>
//         <h1 style="font-size:30px;">${otp}</h1>
//         <p>This OTP is valid for 5 minutes.</p>
//       `,
//     };

//     const result = await transporter.sendMail(mailOptions);
//     console.log(`OTP email sent to: ${to}`);
//     return result;
//   } catch (error) {
//     console.error("Email sending failed:", error);
//     throw new Error("Failed to send email OTP");
//   }
// };

const SibApiV3Sdk = require("sib-api-v3-sdk");

const client = SibApiV3Sdk.ApiClient.instance;
client.authentications["api-key"].apiKey = process.env.BREVO_API_KEY;

const apiInstance = new SibApiV3Sdk.TransactionalEmailsApi();

exports.sendEmail = async (to, otp) => {
  try {
    await apiInstance.sendTransacEmail({
      sender: {
  name: "Joy Brews",
  email: "ansifmohammad7@gmail.com",
},

      to: [{ email: to }],
      subject: "Your OTP Code",
      htmlContent: `
        <h2>Your OTP</h2>
        <h1>${otp}</h1>
        <p>Valid for 5 minutes</p>
      `,
    });

    console.log("OTP email sent successfully");
  } catch (err) {
    console.error("Brevo API email error:", err);
    throw err;
  }
};


// const axios = require("axios");

// const BREVO_API_URL = "https://api.brevo.com/v3/smtp/email";

// exports.sendEmail = async (to, otp) => {
//   try {
//     const response = await axios.post(
//       BREVO_API_URL,
//       {
//         sender: {
//           name: "Joy Brews",
//           email: "ansifmohammad7@gmail.com"
//         },
//         to: [
//           {
//             email: to
//           }
//         ],
//         subject: "Your Login OTP Code",
//         htmlContent: `
//           <h2>Your OTP Code</h2>
//           <h1 style="font-size:30px; letter-spacing: 4px;">${otp}</h1>
//           <p>This OTP is valid for 5 minutes.</p>
//         `
//       },
//       {
//         headers: {
//           "api-key": process.env.BREVO_API_KEY,
//           "Content-Type": "application/json",
//           "Accept": "application/json"
//         }
//       }
//     );

//     console.log("OTP email sent via Brevo:", response.data);
//     return response.data;
//   }
  
//  catch (error) {
//   console.error("Email failed", error);
//   return null;
// }

// };

