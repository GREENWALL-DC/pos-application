const twilio = require("twilio");

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

/**
 * Send OTP via WhatsApp
 * @param {string} phone - MUST be in international format (+91..., +966...)
 * @param {string} otp - 4 digit OTP
 */
exports.sendWhatsAppOtp = async (phone, otp) => {
  try {
    if (!phone) {
      throw new Error("Phone number is required for WhatsApp OTP");
    }

    // Clean phone number (no spaces or dashes)
    let to = phone.replace(/\s+/g, "").replace(/-/g, "");

    // Ensure whatsapp prefix
    if (!to.startsWith("whatsapp:")) {
      to = `whatsapp:${to}`;
    }

    console.log("📲 Sending WhatsApp OTP to:", to);

    const result = await client.messages.create({
      from: process.env.TWILIO_WHATSAPP_FROM,
      to,
      body: `🔐 *JoyPros Admin Login OTP*\n\nYour OTP is *${otp}*\n\nThis OTP is valid for 5 minutes.\nDo not share this code with anyone.`,
    });

    console.log("✅ WhatsApp OTP sent. SID:", result.sid);
    return result;
  } catch (error) {
    console.error("❌ WhatsApp OTP failed:", error);

    if (error.code === 21211) {
      throw new Error("Invalid phone number format");
    }

    if (error.code === 21408 || error.code === 21608) {
      throw new Error(
        "WhatsApp not enabled for this number. Please join Twilio sandbox."
      );
    }

    throw new Error("Failed to send WhatsApp OTP");
  }
};
