/**
 * Email templates for weather subscription service
 */

/**
 * Data for subscription confirmation and unsubscribe emails.
 */
export interface EmailTemplateData {
 email: string
 confirmLink?: string
 companyName?: string
 firstName?: string
 location?: string
 supportEmail?: string
 companyAddress?: string
}

/**
 * Data for daily weather email.
 */
export interface DailyWeatherData {
 email: string
 location: string
 companyName?: string
 firstName?: string
 supportEmail?: string
 companyAddress?: string
 weatherData: {
  current: {
   temp_c: number
   condition: {
    text: string
    icon: string
   }
   humidity: number
   wind_kph: number
   feelslike_c: number
  }
  forecast: {
   forecastday: Array<{
    date: string
    day: {
     maxtemp_c: number
     mintemp_c: number
     condition: {
      text: string
      icon: string
     }
     chance_of_rain: number
    }
   }>
  }
 }
}

/**
 * Generate the HTML for the subscription confirmation email.
 * @param {EmailTemplateData} data
 * @return {string}
 */
export function generateSubscriptionConfirmationEmail(
  data: EmailTemplateData
): string {
  const {
    email,
    confirmLink = "https://g-weather-forecast-2025.web.app/confirm.html?email=" +
   encodeURIComponent(email),
    companyName = "G-Weather-Forecast",
    firstName = "Weather Enthusiast",
    location = "your location",
    supportEmail = "se.terry.2004.career@gmail.com",
    companyAddress = "Ho Chi Minh City, Vietnam",
  } = data;

  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verify Your Weather Forecast Subscription</title>
  <style>
    body, table, td, p, a, li, blockquote {
      -webkit-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
    }
    table, td {
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
    }
    img {
      -ms-interpolation-mode: bicubic;
      border: 0;
      height: auto;
      line-height: 100%;
      outline: none;
      text-decoration: none;
    }
    body {
      margin: 0 !important;
      padding: 0 !important;
      background-color: #f4f7fa;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    .email-container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
    }
    .header {
      background: linear-gradient(135deg, #4a90e2 0%, #357abd 100%);
      padding: 40px 20px;
      text-align: center;
    }
    .header h1 {
      color: #ffffff;
      margin: 0;
      font-size: 28px;
      font-weight: 600;
    }
    .weather-icon {
      width: 60px;
      height: 60px;
      margin: 0 auto 20px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 30px;
    }
    .content {
      padding: 40px 30px;
      text-align: center;
    }
    .content h2 {
      color: #2c3e50;
      font-size: 24px;
      margin-bottom: 20px;
      font-weight: 600;
    }
    .content p {
      color: #5a6c7d;
      font-size: 16px;
      line-height: 1.6;
      margin-bottom: 20px;
    }
    .location-highlight {
      background: linear-gradient(135deg, #4a90e2 0%, #357abd 100%);
      color: white;
      padding: 8px 16px;
      border-radius: 20px;
      font-weight: 600;
      display: inline-block;
      margin: 10px 0;
    }
    .verify-button {
      display: inline-block;
      background: linear-gradient(135deg, #4a90e2 0%, #357abd 100%);
      color: #ffffff !important;
      text-decoration: none;
      padding: 16px 40px;
      border-radius: 50px;
      font-size: 18px;
      font-weight: 600;
      margin: 30px 0;
      box-shadow: 0 4px 15px rgba(74, 144, 226, 0.3);
      transition: all 0.3s ease;
    }
    .verify-button:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(74, 144, 226, 0.4);
    }
    .footer {
      background-color: #2c3e50;
      color: #ffffff;
      padding: 30px 30px 10px 30px;
      text-align: center;
    }
    .footer p {
      margin: 5px 0;
      font-size: 14px;
      color: #bdc3c7;
    }
    .footer a {
      color: #4a90e2;
      text-decoration: none;
    }
    .social-links {
      margin: 20px 0;
    }
    .social-links a {
      display: inline-block;
      margin: 0 10px;
      color: #bdc3c7;
      font-size: 20px;
      text-decoration: none;
    }
    @media only screen and (max-width: 600px) {
      .email-container {
        width: 100% !important;
      }
      .header, .content, .footer {
        padding: 20px !important;
      }
      .header h1 {
        font-size: 24px !important;
      }
      .content h2 {
        font-size: 20px !important;
      }
      .verify-button {
        padding: 14px 30px !important;
        font-size: 16px !important;
      }
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <div class="weather-icon">🌤️</div>
      <h1>${companyName}</h1>
    </div>
    <div class="content">
      <h2>Welcome to Your Personal Weather Service!</h2>
      <p>Hi ${firstName},</p>
      <p>Thank you for subscribing to ${companyName}! We're excited to help you stay ahead of the weather with accurate, personalized forecasts delivered right to your inbox.</p>
      <p>You've subscribed to receive daily weather updates for:</p>
      <div class="location-highlight">📍 ${location}</div>
      <p>To complete your subscription and start receiving daily weather updates, please verify your email address by clicking the button below:</p>
      <a href="${confirmLink}" class="verify-button">Verify My Email Address</a>
      <p style="font-size: 14px; color: #7f8c8d;">
        If the button doesn't work, copy and paste this link into your browser:<br>
        <a href="${confirmLink}" style="color: #4a90e2; word-break: break-all;">${confirmLink}</a>
      </p>
    </div>
    <div class="content">
      <p style="font-size: 14px; color: #7f8c8d;">
        This verification link will expire in 24 hours. If you didn't sign up for ${companyName}, you can safely ignore this email.
      </p>
      <p style="font-size: 14px; color: #7f8c8d;">
        Need help? Contact our support team at <a href="mailto:${supportEmail}" style="color: #4a90e2;">${supportEmail}</a>
      </p>
    </div>
    <div class="footer">
      <div class="social-links">
        <a href="#" title="Facebook">📘</a>
        <a href="#" title="Twitter">🐦</a>
        <a href="#" title="Instagram">📷</a>
      </div>
      <p><strong>${companyName}</strong></p>
      <p>Your trusted weather companion</p>
      <p>${companyAddress}</p>
    </div>
  </div>
</body>
</html>
  `;
}

/**
 * Generate the HTML for the daily weather email.
 * @param {DailyWeatherData} data
 * @return {string}
 */
export function generateDailyWeatherEmail(data: DailyWeatherData): string {
  const {
    email,
    location,
    companyName = "G-Weather-Forecast",
    supportEmail = "se.terry.2004.career@gmail.com",
    companyAddress = "Ho Chi Minh City, Vietnam",
    weatherData,
  } = data;

  const currentWeather = weatherData.current;
  const forecast = weatherData.forecast.forecastday.slice(0, 4);
  const today = new Date().toLocaleDateString("en-US", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });

  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Daily Weather Forecast for ${location}</title>
  <style>
    body, table, td, p, a, li, blockquote {
      -webkit-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
    }
    table, td {
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
    }
    img {
      -ms-interpolation-mode: bicubic;
      border: 0;
      height: auto;
      line-height: 100%;
      outline: none;
      text-decoration: none;
    }
    body {
      margin: 0 !important;
      padding: 0 !important;
      background-color: #f4f7fa;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    .email-container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
    }
    .header {
      background: linear-gradient(135deg, #4a90e2 0%, #357abd 100%);
      padding: 30px 20px;
      text-align: center;
      color: white;
    }
    .header h1 {
      color: #ffffff;
      margin: 0 0 10px 0;
      font-size: 24px;
      font-weight: 600;
    }
    .header p {
      color: rgba(255, 255, 255, 0.9);
      margin: 0;
      font-size: 14px;
    }
    .current-weather {
      padding: 30px 20px;
      text-align: center;
      background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
      color: white;
    }
    .current-temp {
      font-size: 48px;
      font-weight: bold;
      margin: 10px 0;
    }
    .current-condition {
      font-size: 18px;
      margin: 10px 0;
    }
    .current-details {
      display: flex;
      justify-content: space-around;
      margin-top: 20px;
      flex-wrap: wrap;
    }
    .detail-item {
      text-align: center;
      min-width: 80px;
      margin: 5px;
    }
    .detail-value {
      font-size: 16px;
      font-weight: bold;
    }
    .detail-label {
      font-size: 12px;
      opacity: 0.9;
    }
    .forecast-section {
      padding: 30px 20px;
    }
    .forecast-title {
      color: #2c3e50;
      font-size: 20px;
      font-weight: 600;
      margin-bottom: 20px;
      text-align: center;
    }
    .forecast-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 15px;
    }
    .forecast-day {
      background: #f8fafc;
      border-radius: 10px;
      padding: 15px;
      text-align: center;
      border: 1px solid #e2e8f0;
    }
    .forecast-date {
      font-size: 12px;
      color: #64748b;
      font-weight: 500;
      margin-bottom: 8px;
    }
    .forecast-temps {
      font-size: 14px;
      font-weight: bold;
      color: #1e293b;
      margin: 8px 0;
    }
    .forecast-condition {
      font-size: 11px;
      color: #64748b;
      margin: 5px 0;
    }
    .forecast-rain {
      font-size: 11px;
      color: #3b82f6;
      margin: 5px 0;
    }
    .location-highlight {
      background: rgba(74, 144, 226, 0.1);
      color: #4a90e2;
      padding: 8px 16px;
      border-radius: 20px;
      font-weight: 600;
      display: inline-block;
      margin: 10px 0;
    }
    .footer {
      background-color: #2c3e50;
      color: #ffffff;
      padding: 20px;
      text-align: center;
    }
    .footer p {
      margin: 5px 0;
      font-size: 12px;
      color: #bdc3c7;
    }
    .footer a {
      color: #4a90e2;
      text-decoration: none;
    }
    .unsubscribe-link {
      margin-top: 15px;
      padding-top: 15px;
      border-top: 1px solid #34495e;
    }
    @media only screen and (max-width: 600px) {
      .email-container {
        width: 100% !important;
      }
      .current-details {
        flex-direction: column;
        align-items: center;
      }
      .forecast-grid {
        grid-template-columns: repeat(2, 1fr);
      }
      .current-temp {
        font-size: 36px;
      }
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🌤️ Daily Weather Update</h1>
      <p>${today}</p>
      <div class="location-highlight">📍 ${location}</div>
    </div>
    <div class="current-weather">
      <div class="current-temp">${Math.round(currentWeather.temp_c)}°C</div>
      <div class="current-condition">${currentWeather.condition.text}</div>
      <div class="current-details">
        <div class="detail-item">
          <div class="detail-value">${Math.round(
    currentWeather.feelslike_c
  )}°C</div>
          <div class="detail-label">Feels like</div>
        </div>
        <div class="detail-item">
          <div class="detail-value">${currentWeather.humidity}%</div>
          <div class="detail-label">Humidity</div>
        </div>
        <div class="detail-item">
          <div class="detail-value">${Math.round(
    currentWeather.wind_kph
  )} km/h</div>
          <div class="detail-label">Wind</div>
        </div>
      </div>
    </div>
    <div class="forecast-section">
      <div class="forecast-title">4-Day Forecast</div>
      <div class="forecast-grid">
        ${forecast
    .map((day, index) => {
      const date = new Date(day.date);
      const dayName =
       index === 0 ?
         "Today" :
         date.toLocaleDateString("en-US", {weekday: "short"});
      const monthDay = date.toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
      });
      return `
              <div class="forecast-day">
                <div class="forecast-date">${dayName}<br>${monthDay}</div>
                <div class="forecast-temps">
                  ${Math.round(day.day.maxtemp_c)}° / ${Math.round(
  day.day.mintemp_c
)}°
                </div>
                <div class="forecast-condition">${day.day.condition.text}</div>
                <div class="forecast-rain">💧 ${day.day.chance_of_rain}%</div>
              </div>
            `;
    })
    .join("")}
      </div>
    </div>
    <div class="footer">
      <p><strong>${companyName}</strong></p>
      <p>Your daily weather companion for ${location}</p>
      <p>${companyAddress}</p>
      <div class="unsubscribe-link">
        <p>
          Don't want daily updates?
          <a href="mailto:${supportEmail}?subject=Unsubscribe%20Weather%20Updates&body=Please%20unsubscribe%20${encodeURIComponent(
  email
)}%20from%20daily%20weather%20updates." style="color: #4a90e2;">
            Unsubscribe here
          </a>
        </p>
      </div>
    </div>
  </div>
</body>
</html>
  `;
}

/**
 * Generate the HTML for the unsubscribe confirmation email.
 * @param {EmailTemplateData} data
 * @return {string}
 */
export function generateUnsubscribeConfirmationEmail(
  data: EmailTemplateData
): string {
  const {
    companyName = "G-Weather-Forecast",
    location = "your location",
    supportEmail = "se.terry.2004.career@gmail.com",
  } = data;

  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Unsubscribed from Weather Forecasts</title>
  <style>
    body, table, td, p, a, li, blockquote {
      -webkit-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
    }
    table, td {
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
    }
    img {
      -ms-interpolation-mode: bicubic;
      border: 0;
      height: auto;
      line-height: 100%;
      outline: none;
      text-decoration: none;
    }
    body {
      margin: 0 !important;
      padding: 0 !important;
      background-color: #f4f7fa;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    .email-container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
    }
    .header {
      background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
      padding: 40px 20px;
      text-align: center;
    }
    .header h1 {
      color: #ffffff;
      margin: 0;
      font-size: 28px;
      font-weight: 600;
    }
    .weather-icon {
      width: 60px;
      height: 60px;
      margin: 0 auto 20px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 30px;
    }
    .content {
      padding: 40px 30px;
      text-align: center;
    }
    .content h2 {
      color: #2c3e50;
      font-size: 24px;
      margin-bottom: 20px;
      font-weight: 600;
    }
    .content p {
      color: #5a6c7d;
      font-size: 16px;
      line-height: 1.6;
      margin-bottom: 20px;
    }
    .location-highlight {
      background: #ecf0f1;
      color: #2c3e50;
      padding: 8px 16px;
      border-radius: 20px;
      font-weight: 600;
      display: inline-block;
      margin: 10px 0;
    }
    .footer {
      background-color: #2c3e50;
      color: #ffffff;
      padding: 30px 30px 10px 30px;
      text-align: center;
    }
    .footer p {
      margin: 5px 0;
      font-size: 14px;
      color: #bdc3c7;
    }
    .footer a {
      color: #4a90e2;
      text-decoration: none;
    }
    .social-links {
      margin: 20px 0;
    }
    .social-links a {
      display: inline-block;
      margin: 0 10px;
      color: #bdc3c7;
      font-size: 20px;
      text-decoration: none;
    }
    @media only screen and (max-width: 600px) {
      .email-container {
        width: 100% !important;
      }
      .header, .content, .footer {
        padding: 20px !important;
      }
      .header h1 {
        font-size: 24px !important;
      }
      .content h2 {
        font-size: 20px !important;
      }
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <div class="weather-icon">👋</div>
      <h1>${companyName}</h1>
    </div>
    <div class="content">
      <h2>You've Been Unsubscribed</h2>
      <p>We're sorry to see you go! You have been successfully unsubscribed from ${companyName} daily weather forecasts.</p>
      <p>You will no longer receive weather updates for:</p>
      <div class="location-highlight">📍 ${location}</div>
      <p style="font-size: 14px; color: #7f8c8d;">
        Thank you for being part of our weather community. We hope to serve you again in the future!
      </p>
      <p style="font-size: 14px; color: #7f8c8d;">
        Questions? Contact us at <a href="mailto:${supportEmail}" style="color: #4a90e2;">${supportEmail}</a>
      </p>
    </div>
  </div>
</body>
</html>
  `;
}
