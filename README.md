# G Weather Forecast 🌤️

A modern, responsive weather dashboard built with Flutter and Firebase that provides detailed weather forecasts, email subscriptions, and comprehensive weather data visualization.

## 🌟 Features

### 📱 Core Weather Features
- **Real-time Weather Data**: Current weather conditions with detailed metrics
- **Extended Forecasts**: Up to 13-day weather forecasts with hourly breakdowns
- **Location Search**: Smart city search with autocomplete suggestions
- **Current Location**: GPS-based weather detection
- **Weather History**: Recent search history with quick access
- **Detailed Weather Modal**: Comprehensive hourly data with AQI, astronomy, and more

### 📧 Email Subscription System
- **Daily Weather Emails**: Automated daily weather reports at 6:00 AM (Vietnam timezone)
- **Email Verification**: Secure email confirmation system
- **Location-based Subscriptions**: Personalized weather updates for specific locations
- **Easy Unsubscribe**: One-click unsubscribe functionality
- **Beautiful Email Templates**: Responsive HTML email templates

### 🎨 User Interface
- **Responsive Design**: Works seamlessly on desktop and mobile
- **Modern UI**: Clean, intuitive interface with smooth animations
- **Dark/Light Theme Support**: Adaptive theming
- **Interactive Cards**: Clickable weather cards with detailed information
- **Tooltips & Accessibility**: Enhanced user experience with helpful tooltips

## 🚀 Demo

**Live Demo**: [https://g-weather-forecast-2025.web.app](https://g-weather-forecast-2025.web.app)

### Demo Features to Try:
1. Search for any city worldwide
2. Click on weather cards for detailed hourly forecasts
3. Subscribe to daily weather emails
4. View weather history
5. Use current location feature

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **HTTP** - API communication
- **Shared Preferences** - Local storage
- **Geolocator** - Location services
- **Google Fonts** - Typography

### Backend
- **Firebase Functions** - Serverless backend
- **Firebase Firestore** - NoSQL database
- **Firebase Hosting** - Web hosting
- **TypeScript** - Programming language
- **Nodemailer** - Email service
- **Cloud Scheduler** - Automated tasks

### APIs
- **WeatherAPI.com** - Weather data provider
- **Gmail SMTP** - Email delivery

## 📋 Prerequisites

Before running this project locally, ensure you have:

- **Flutter SDK** (3.0+)
- **Node.js** (18+)
- **Firebase CLI**
- **Git**
- **WeatherAPI.com API Key**
- **Gmail App Password** (for email features)

## 🔧 Local Development Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/g_weather_forecast.git
cd g_weather_forecast
```

### 2. Flutter Setup
```bash
# Install Flutter dependencies
flutter pub get

# Create environment file
# For web deployment
echo "WEATHER_API_KEY=your_weather_api_key_here" > web/web.env

# For mobile development  
echo "WEATHER_API_KEY=your_weather_api_key_here" > .env
```

### 3. Firebase Setup
```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project (if not already done)
firebase init

# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Set environment variables for functions
# Use .env file for local development
echo "GMAIL_USER=your-email@gmail.com" > .env
echo "GMAIL_PASSWORD=your-app-password" >> .env
echo "WEATHER_API_KEY=your-weather-api-key" >> .env
```

### 4. API Keys Setup

#### WeatherAPI.com
1. Sign up at [WeatherAPI.com](https://www.weatherapi.com/)
2. Get your free API key
3. Add it to your environment files

#### Gmail App Password
1. Enable 2-factor authentication on your Google account
2. Generate an App Password for Gmail
3. Use this password in your environment variables

### 5. Firebase Configuration
Update `lib/firebase_options.dart` with your Firebase project configuration.

## 🚀 Running the Project

### Development Mode
```bash
# Run Flutter web app
flutter run -d chrome

# Run Firebase Functions locally (in another terminal)
cd functions
npm run serve
```

### Build for Production
```bash
# Build Flutter web app
flutter build web

# Copy confirm.html to build output
copy web\confirm.html build\web\confirm.html  # Windows
cp web/confirm.html build/web/confirm.html    # macOS/Linux
```

## 📦 Deployment

### Deploy to Firebase
```bash
# Deploy everything
firebase deploy

# Deploy only hosting
firebase deploy --only hosting

# Deploy only functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:registerWeatherEmail
```

### Available Firebase Functions
- `registerWeatherEmail` - Handle email subscription registration
- `confirmSubscription` - Process email confirmation clicks
- `unsubscribeWeatherEmail` - Handle unsubscribe requests
- `sendDailyWeatherEmails` - Automated daily email sending (6:00 AM Vietnam time)

## 📧 Email Features

### Daily Weather Email Schedule
- **Time**: 6:00 AM Vietnam Time (GMT+7)
- **Frequency**: Daily
- **Content**: Current weather, 4-day forecast, location-specific data

### Email Templates
- **Subscription Confirmation**: Welcome email with verification link
- **Daily Weather Report**: Comprehensive weather information
- **Unsubscribe Confirmation**: Farewell message

## 🏗️ Project Structure

```
g_weather_forecast/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── providers/
│   │   └── weather_provider.dart # State management
│   ├── services/
│   │   ├── weather_api_service.dart # Weather API integration
│   │   └── email_service.dart      # Firebase Functions calls
│   ├── sections/
│   │   ├── search-section/         # Search functionality
│   │   ├── forecast-section/       # Weather forecast display
│   │   └── details-dialog/         # Detailed weather modal
│   ├── widgets/                    # Reusable UI components
│   └── theme.dart                  # App theming
├── functions/
│   ├── src/
│   │   ├── index.ts               # Firebase Functions
│   │   └── emailTemplates.ts      # Email HTML templates
│   └── package.json               # Node.js dependencies
├── web/
│   ├── index.html                 # Flutter web entry
│   └── confirm.html               # Email confirmation page
└── firebase.json                  # Firebase configuration
```

## 🔐 Environment Variables

### Flutter App (.env / web.env)
```
WEATHER_API_KEY=your_weather_api_key
```

### Firebase Functions (.env)
```
GMAIL_USER=your-email@gmail.com
GMAIL_PASSWORD=your-app-password
WEATHER_API_KEY=your_weather_api_key
```

## 🧪 Testing

### Test Email Subscription Flow
1. Enter email in the app
2. Check email for confirmation link
3. Click confirmation link
4. Verify subscription in Firebase Console
5. Test daily email function

### Test Weather Features
1. Search for different cities
2. Use current location
3. Click on weather cards for details
4. Check weather history
5. Load more forecasts

## 🐛 Troubleshooting

### Common Issues

#### Email Confirmation Not Working
- Ensure `confirm.html` is copied to `build/web/` after Flutter build
- Check Firebase Functions logs for errors
- Verify Gmail credentials are correct

#### Weather API Issues
- Verify API key is valid and has sufficient quota
- Check network connectivity
- Ensure API key is properly set in environment variables

#### Firebase Functions Deployment
- Ensure all environment variables are set
- Check Node.js version compatibility (22+)
- Verify Firebase project permissions

### Debug Commands
```bash
# Check Firebase Functions logs
firebase functions:log

# Test functions locally
firebase emulators:start --only functions

# Check Flutter web build
flutter doctor
```

## 🤝 Reason

This project is a part of the internship program at Golden Owl Asia for the Mobile Flutter Developer position. Thank you for the opportunity and support—I'm truly grateful to be a part of this journey!

I will update the demo video in this README in no time. Stay tuned!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [WeatherAPI.com](https://www.weatherapi.com/) for weather data
- [Flutter](https://flutter.dev/) for the amazing framework
- [Firebase](https://firebase.google.com/) for backend services
- [Google Fonts](https://fonts.google.com/) for typography

## 📞 Support

For support, email se.terry.2004.career@gmail.com.

---

**Made with ❤️ using Flutter and Firebase**