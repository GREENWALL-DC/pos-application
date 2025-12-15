const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

transporter.verify((err, success) => {
  if (err) {
    console.log("Email transporter error:", err);
  } else {
    console.log("Gmail email server is ready");
  }
});

exports.sendEmail = async (to, otp) => {
  try {
    const mailOptions = {
      from: `"Joy Brews" <${process.env.EMAIL_USER}>`,
      to, 
      subject: "Your Login OTP Code",
      html: `
        <h2>Your OTP Code</h2>
        <h1 style="font-size:30px;">${otp}</h1>
        <p>This OTP is valid for 5 minutes.</p>
      `,
    };

    const result = await transporter.sendMail(mailOptions);
    console.log(`OTP email sent to: ${to}`);
    return result;
  } catch (error) {
    console.error("Email sending failed:", error);
    throw new Error("Failed to send email OTP");
  }
};
