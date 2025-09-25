# TIS (Time is Money) 💰⏰

A modern, user-friendly iOS app for tracking work hours and calculating earnings. Built with SwiftUI and Core Data, TIS helps you manage multiple jobs, track different shift types, and monitor your income with beautiful analytics.

## ✨ Features

### 🕐 Time Tracking
- **Real-time tracking** with start/stop functionality
- **Automatic shift type detection** (Regular, Overtime, Special Event, Flexible)
- **Background timer support** for continuous tracking
- **Manual shift entry** for past work sessions
- **Shift templates** for common work patterns

### 💼 Job Management
- **Multiple job support** with individual hourly rates
- **Job-specific bonuses** and special pay rates
- **Visual job overview** with earnings and hours worked
- **Easy job creation** with modern UI
- **Job editing** functionality (in progress)

### 📊 Analytics & Insights
- **Earnings breakdown** by job and shift type
- **Visual charts** using Swift Charts
- **Trend analysis** and performance metrics
- **Export capabilities** (CSV and PDF)
- **Earnings goals** with progress tracking

### 🌍 Localization & Currency
- **Multi-language support** (English, Hebrew with RTL)
- **Multi-currency support** (USD, ILS, EUR, GBP)
- **Localized currency formatting**
- **RTL layout support** for Hebrew

### 🎨 Modern Design
- **Beautiful UI** with custom components
- **Dark/Light mode** support
- **Smooth animations** and transitions
- **Toast notifications** for user feedback
- **Responsive design** for all iOS devices
- **Glass morphism** design elements
- **Custom design system** (Typography, Spacing, Colors)

### 📱 Core Features
- **Offline-first** data storage with Core Data
- **Data export** for record keeping
- **Notification reminders** for shifts
- **Settings customization**
- **Universal iOS support** (iPhone and iPad)
- **Achievement system** with badges and progress
- **Haptic feedback** for enhanced UX

## 🏗️ Architecture

### Tech Stack
- **SwiftUI** - Modern declarative UI framework
- **Core Data** - Local data persistence
- **MVVM Pattern** - Clean architecture
- **Combine** - Reactive programming (where applicable)
- **Swift Charts** - Data visualization
- **UserNotifications** - Local notifications
- **WidgetKit** - Home screen widgets

### Project Structure
```
TIS/
├── Views/                 # Main app screens
│   ├── DashboardView.swift
│   ├── TimeTrackingView.swift
│   ├── JobsView.swift
│   ├── HistoryView.swift
│   ├── AnalyticsView.swift
│   ├── SettingsView.swift
│   ├── AddJobView.swift
│   ├── EditJobView.swift
│   ├── AddManualShiftView.swift
│   ├── AchievementsView.swift
│   ├── EarningsGoalsView.swift
│   ├── ShiftRemindersView.swift
│   ├── ShiftTemplatesView.swift
│   └── LocalizationSettingsView.swift
├── Components/            # Reusable UI components
│   ├── TISCard.swift
│   ├── TISButton.swift
│   ├── ToastView.swift
│   ├── AnimatedBackgroundView.swift
│   ├── EnhancedCard.swift
│   ├── PressableButtonStyle.swift
│   └── Shimmer.swift
├── Managers/              # Business logic managers
│   ├── LocalizationManager.swift
│   ├── ExportManager.swift
│   ├── NotificationManager.swift
│   ├── AchievementManager.swift
│   ├── HapticsManager.swift
│   └── PersistenceController.swift
├── Design/                # Design system
│   ├── ColorScheme.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   └── Shadows.swift
├── Models/                # Core Data models
│   ├── TISModel.xcdatamodeld
│   └── AchievementData.swift
├── ViewModels/           # View models
│   └── TimeTracker.swift
└── Widgets/              # Widget support
    ├── TimeTrackingWidget.swift
    └── TISModel.xcdatamodeld
```

## 🚀 Getting Started

### Prerequisites
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/1oridevs/TIS.git
   ```

2. Open `TIS.xcodeproj` in Xcode

3. Select your development team in "Signing & Capabilities"

4. Build and run the project

### First Time Setup
1. **Add your first job** with hourly rate and bonuses
2. **Start tracking** your work hours
3. **View analytics** to see your earnings
4. **Export data** for record keeping
5. **Set earnings goals** for motivation
6. **Customize language and currency** in settings

## 📱 Screenshots

*Screenshots will be added once the app is built and running*

## 🎯 Current Status

### ✅ Completed Features
- [x] **Core Data model** with Job, Shift, and Bonus entities
- [x] **Time tracking** with start/stop functionality
- [x] **Job management** (add, view, delete)
- [x] **Manual shift entry** for past work sessions
- [x] **Analytics dashboard** with earnings breakdown
- [x] **Data export** (CSV and PDF)
- [x] **Modern UI** with custom components
- [x] **Toast notification system**
- [x] **Settings and preferences**
- [x] **Offline data storage**
- [x] **Localization support** (English, Hebrew)
- [x] **Multi-currency support** (USD, ILS, EUR, GBP)
- [x] **Achievement system** with badges
- [x] **Earnings goals** with progress tracking
- [x] **Shift reminders** and notifications
- [x] **Custom design system** (Typography, Spacing, Colors)
- [x] **Haptic feedback** integration
- [x] **Widget support** (TimeTrackingWidget)
- [x] **Shift templates** for common patterns
- [x] **RTL layout support** for Hebrew
- [x] **Performance optimizations** (fixed freezing issues)

### 🚧 In Progress
- [x] **Job editing functionality** - EditJobView completed with full localization
- [ ] **Shift editing** - Allow users to edit past shifts
- [ ] **Enhanced analytics charts** - More detailed visualizations
- [ ] **Push notifications** for shift reminders
- [ ] **Data validation** improvements

### 📋 Planned Features
- [ ] **Apple Watch companion app**
- [ ] **iCloud sync** across devices
- [ ] **Advanced reporting** and insights
- [ ] **Team/shared job management**
- [ ] **Calendar integration**
- [ ] **Voice commands** for hands-free tracking
- [ ] **Advanced achievement system**
- [ ] **Data backup/restore** options

## 🎉 Recent Major Updates

### 🚀 **UI/UX Enhancements**
- ✅ **Smooth Animations** - Added comprehensive animation system with loading states, transitions, and micro-interactions
- ✅ **Beautiful Empty States** - Created animated illustrations and messaging for all empty data scenarios
- ✅ **Onboarding Flow** - Built 5-step guided setup with interactive pages for new users
- ✅ **App Icon System** - Designed professional icons with multiple options for all device sizes
- ✅ **Enhanced Widgets** - Added 3 new widget types (Time Tracking, Earnings, Jobs) with comprehensive functionality

### 🎯 **Core Features Completed**
- ✅ **Complete Localization** - Full English and Hebrew support with RTL layouts and currency formatting
- ✅ **Accessibility Features** - VoiceOver support, Dynamic Type, and comprehensive accessibility labels
- ✅ **Performance Optimization** - Reduced memory usage, improved loading times, and eliminated freezing issues
- ✅ **Currency Display** - Consistent formatting across all views with proper RTL support

### 🐛 **Critical Bug Fixes**
- ✅ **Zero Crashes** - Fixed duplicate dictionary keys causing fatal crashes
- ✅ **No More Freezing** - Resolved infinite animations and performance bottlenecks
- ✅ **Complete Localization** - All hardcoded strings replaced with localized versions
- ✅ **EditJobView Fixed** - Proper implementation with full functionality

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Ori Cohen** - *Initial work* - [@1oridevs](https://github.com/1oridevs)

## 🙏 Acknowledgments

- SwiftUI community for inspiration and best practices
- Core Data documentation and examples
- Open source contributors who made this possible

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Check the documentation
- Contact us at [oridevs.offical@gmail.com]


## Goals

The goals for this project is pretty simple. for me, (Ori) I wanted to get more experience with working on swift project as well as open sourcing. As a user, I felt the hardness when trying to calculate how much money i made this month/week and writing hours to the clock to actually get paid and know exactly my rights and exactly how much should I expect the paycheck to be. Well, guess what? you don't need to guess anymore. You just add your job to the system, add your hourly rate and boom. You are ready to go. Plug and play type shi.
---

**Made with ❤️ for time-conscious professionals**