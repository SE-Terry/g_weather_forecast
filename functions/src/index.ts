/* eslint-disable max-len */
/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onCall, onRequest} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import * as nodemailer from "nodemailer";
import * as functions from "firebase-functions";
import * as https from "https";
import {
  generateSubscriptionConfirmationEmail,
  generateUnsubscribeConfirmationEmail,
  generateDailyWeatherEmail,
} from "./emailTemplates";

admin.initializeApp();

// Configure Gmail SMTP transporter using secure config
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: functions.config().gmail.user,
    pass: functions.config().gmail.password,
  },
});

export const registerWeatherEmail = onCall(async (request) => {
  const email = request.data.email;
  const location = request.data.location || "your location";

  // Store subscription in Firestore with location
  await admin.firestore().collection("weather_subscriptions").doc(email).set({
    email,
    location,
    confirmed: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Generate confirmation link
  const confirmLink =
		"https://g-weather-forecast-2025.web.app/confirm.html?email=" +
		encodeURIComponent(email);

  // Generate beautiful HTML email with user's location
  const htmlContent = generateSubscriptionConfirmationEmail({
    email,
    confirmLink,
    companyName: "G-Weather-Forecast",
    firstName: "Weather Enthusiast",
    location: location,
    supportEmail: "se.terry.2004.career@gmail.com",
    companyAddress: "Ho Chi Minh City, Vietnam",
  });

  const mailOptions = {
    from: functions.config().gmail.user,
    to: email,
    subject: `Daily weather updates for ${location}`,
    html: htmlContent,
  };

  try {
    await transporter.sendMail(mailOptions);
    logger.info(
      `Confirmation email sent to: ${email} for location: ${location}`
    );
    return {message: `Confirmation email sent to ${email} for ${location}`};
  } catch (error) {
    logger.error("Error sending email:", error);
    throw new Error("Failed to send confirmation email");
  }
});

export const unsubscribeWeatherEmail = onCall(async (request) => {
  const email = request.data.email;

  // Get subscription data to retrieve location
  const subscriptionDoc = await admin
    .firestore()
    .collection("weather_subscriptions")
    .doc(email)
    .get();

  const subscriptionData = subscriptionDoc.data();
  const location = subscriptionData?.location || "your location";

  // Remove subscription from Firestore
  await admin
    .firestore()
    .collection("weather_subscriptions")
    .doc(email)
    .delete();

  // Generate beautiful HTML email
  const htmlContent = generateUnsubscribeConfirmationEmail({
    email,
    companyName: "G-Weather-Forecast",
    firstName: "Weather Enthusiast",
    location: location,
    supportEmail: "se.terry.2004.career@gmail.com",
    companyAddress: "Ho Chi Minh City, Vietnam",
  });

  const mailOptions = {
    from: functions.config().gmail.user,
    to: email,
    subject: "Unsubscribed from daily weather",
    html: htmlContent,
  };

  try {
    await transporter.sendMail(mailOptions);
    logger.info(
      `Unsubscribe confirmation sent to: ${email} for location: ${location}`
    );
    return {message: `Unsubscribe confirmation email sent to ${email}`};
  } catch (error) {
    logger.error("Error sending unsubscribe email:", error);
    throw new Error("Failed to send unsubscribe email");
  }
});

// Handle email confirmation when users click the confirmation link
export const confirmSubscription = onRequest(async (req, res) => {
  const email = req.query.email as string;

  if (!email) {
    res.status(400).send(`
      <html>
        <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
          <h2>❌ Invalid Confirmation Link</h2>
          <p>The confirmation link is missing required information.</p>
        </body>
      </html>
    `);
    return;
  }

  try {
    // Update subscription to confirmed
    await admin
      .firestore()
      .collection("weather_subscriptions")
      .doc(email)
      .update({
        confirmed: true,
        confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    logger.info(`Email subscription confirmed for: ${email}`);

    res.status(200).send(`
      <html>
        <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #f4f7fa;">
          <div style="max-width: 500px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
            <h2 style="color: #4a90e2;">✅ Subscription Confirmed!</h2>
            <p>Thank you for confirming your email address.</p>
            <p>You will now receive daily weather updates for your location at <strong>${email}</strong> every morning at 6:00 AM.</p>
            <div style="margin: 30px 0; padding: 20px; background: #e8f4fd; border-radius: 8px;">
              <p style="margin: 0; color: #2c5282;">🌤️ Your first weather update will arrive tomorrow morning!</p>
            </div>
            <p style="font-size: 14px; color: #666;">You can unsubscribe at any time by clicking the unsubscribe link in any weather email.</p>
          </div>
        </body>
      </html>
    `);
  } catch (error) {
    logger.error(`Error confirming subscription for ${email}:`, error);
    res.status(500).send(`
      <html>
        <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
          <h2>❌ Confirmation Failed</h2>
          <p>There was an error confirming your subscription. Please try again or contact support.</p>
        </body>
      </html>
    `);
  }
});

// Helper function to fetch weather data from WeatherAPI
async function fetchWeatherData(location: string): Promise<any> {
  return new Promise((resolve, reject) => {
    const apiKey =
			functions.config().weather?.api_key || process.env.WEATHER_API_KEY;
    const url = `https://api.weatherapi.com/v1/forecast.json?key=${apiKey}&q=${encodeURIComponent(
      location
    )}&days=5&aqi=no&alerts=no`;

    https
      .get(url, (res) => {
        let data = "";
        res.on("data", (chunk) => {
          data += chunk;
        });
        res.on("end", () => {
          try {
            const weatherData = JSON.parse(data);
            if (weatherData.error) {
              reject(new Error(weatherData.error.message));
            } else {
              resolve(weatherData);
            }
          } catch (error) {
            reject(error);
          }
        });
      })
      .on("error", (error) => {
        reject(error);
      });
  });
}

// Scheduled function to send daily weather emails at 6 AM
export const sendDailyWeatherEmails = onSchedule(
  {
    schedule: "0 6 * * *", // Run at 6:00 AM every day
    timeZone: "Asia/Ho_Chi_Minh", // Vietnam timezone
  },
  async (event) => {
    logger.info("Starting daily weather email job");

    try {
      // Get all confirmed subscribers
      const subscribersSnapshot = await admin
        .firestore()
        .collection("weather_subscriptions")
        .where("confirmed", "==", true)
        .get();

      if (subscribersSnapshot.empty) {
        logger.info("No confirmed subscribers found");
        return;
      }

      logger.info(`Found ${subscribersSnapshot.size} confirmed subscribers`);

      // Process subscribers in batches to avoid rate limits
      const batchSize = 10;
      const subscribers = subscribersSnapshot.docs;

      for (let i = 0; i < subscribers.length; i += batchSize) {
        const batch = subscribers.slice(i, i + batchSize);
        const promises = batch.map(async (doc) => {
          const subscriberData = doc.data();
          const email = subscriberData.email;
          const location = subscriberData.location || "your location";

          try {
            // Fetch weather data for subscriber's location
            const weatherData = await fetchWeatherData(location);

            // Generate HTML email content
            const htmlContent = generateDailyWeatherEmail({
              email,
              location,
              companyName: "G-Weather-Forecast",
              firstName: "Weather Enthusiast",
              supportEmail: "se.terry.2004.career@gmail.com",
              companyAddress: "Ho Chi Minh City, Vietnam",
              weatherData,
            });

            // Send email
            const mailOptions = {
              from: functions.config().gmail.user,
              to: email,
              subject: `🌤️ Daily Weather for ${location} - ${new Date().toLocaleDateString()}`,
              html: htmlContent,
            };

            await transporter.sendMail(mailOptions);
            logger.info(
              `Daily weather email sent to: ${email} for location: ${location}`
            );
          } catch (error) {
            logger.error(
              `Failed to send daily weather email to ${email}:`,
              error
            );
            // Continue with other subscribers even if one fails
          }
        });

        // Wait for current batch to complete before processing next batch
        await Promise.allSettled(promises);

        // Add a small delay between batches to be respectful to email provider
        if (i + batchSize < subscribers.length) {
          await new Promise((resolve) => setTimeout(resolve, 1000));
        }
      }

      logger.info("Daily weather email job completed");
    } catch (error) {
      logger.error("Error in daily weather email job:", error);
      throw error;
    }
  }
);
