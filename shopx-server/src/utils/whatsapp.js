const twilio = require("twilio");

// Initialize Twilio client (works with trial account)
const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

exports.sendWhatsApp = async (to, message) => {
  try {
    // Format phone number for WhatsApp
    // Remove any spaces, dashes, and ensure country code
    let formattedTo = to.replace(/\s+/g, '').replace(/-/g, '');
    
    // If number doesn't start with '+', add it (assuming Indian numbers)
    if (!formattedTo.startsWith('+')) {
      if (formattedTo.startsWith('91') && formattedTo.length === 12) {
        formattedTo = '+' + formattedTo;
      } else if (formattedTo.length === 10) {
        formattedTo = '+91' + formattedTo; // Default to India
      }
    }
    
    // Add WhatsApp prefix if not present
    if (!formattedTo.startsWith('whatsapp:')) {
      formattedTo = 'whatsapp:' + formattedTo;
    }

    console.log(`Sending WhatsApp to: ${formattedTo}`);

    const result = await client.messages.create({
      body: `🔐 Your Admin Login OTP: ${message}\n\nThis OTP is valid for 5 minutes. Do not share with anyone.`,
      from: process.env.TWILIO_WHATSAPP_FROM, // Twilio sandbox number
      to: formattedTo
    });

    console.log(`WhatsApp OTP sent successfully. SID: ${result.sid}`);
    return result;
  } catch (error) {
    console.error("WhatsApp sending failed:", error);
    
    // User-friendly error messages
    if (error.code === 21211) {
      throw new Error("Invalid phone number format");
    } else if (error.code === 21608) {
      throw new Error("WhatsApp not enabled for this number. Please join Twilio sandbox first.");
    } else if (error.code === 21408) {
      throw new Error("Permission to send WhatsApp message denied. Recipient must join Twilio sandbox.");
    } else {
      throw new Error("Failed to send WhatsApp OTP. Please try another method.");
    }
  }
};