# TIS (Time is Money) 💰⏰

A modern, user-friendly iOS app for tracking work hours and calculating earnings. Built with SwiftUI and Core Data, TIS helps you manage multiple jobs, track different shift types, and monitor your income with beautiful analytics.

## ✨ Features

### 🕐 Time Tracking
- **Real-time tracking** with start/stop functionality
- **Automatic shift type detection** (Regular, Overtime, Special Event, Flexible)
- **Background timer support** for continuous tracking
- **Manual shift entry** for past work sessions

### 💼 Job Management
- **Multiple job support** with individual hourly rates
- **Job-specific bonuses** and special pay rates
- **Visual job overview** with earnings and hours worked
- **Easy job creation** with modern UI

### 📊 Analytics & Insights
- **Earnings breakdown** by job and shift type
- **Visual charts** and statistics
- **Trend analysis** and performance metrics
- **Export capabilities** (CSV and PDF)

### 🎨 Modern Design
- **Beautiful UI** with custom components
- **Dark/Light mode** support
- **Smooth animations** and transitions
- **Toast notifications** for user feedback
- **Responsive design** for all iOS devices

### 📱 Core Features
- **Offline-first** data storage with Core Data
- **Data export** for record keeping
- **Notification reminders** for shifts
- **Settings customization**
- **Universal iOS support** (iPhone and iPad)

## 🏗️ Architecture

### Tech Stack
- **SwiftUI** - Modern declarative UI framework
- **Core Data** - Local data persistence
- **MVVM Pattern** - Clean architecture
- **Combine** - Reactive programming (where applicable)

### Project Structure
```
TIS/
├── Views/                 # Main app screens
│   ├── DashboardView.swift
│   ├── TimeTrackingView.swift
│   ├── JobsView.swift
│   ├── HistoryView.swift
│   ├── AnalyticsView.swift
│   └── SettingsView.swift
├── Components/            # Reusable UI components
│   ├── TISCard.swift
│   ├── TISButton.swift
│   └── ToastView.swift
├── Managers/              # Business logic managers
│   ├── ExportManager.swift
│   └── NotificationManager.swift
├── Design/                # Design system
│   └── ColorScheme.swift
└── Models/                # Core Data models
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

## 📱 Screenshots

*Screenshots will be added once the app is built and running*

## 🎯 Current Status

### ✅ Completed Features
- [x] Core Data model with Job, Shift, and Bonus entities
- [x] Time tracking with start/stop functionality
- [x] Job management (add, view, delete)
- [x] Manual shift entry
- [x] Analytics dashboard with earnings breakdown
- [x] Data export (CSV and PDF)
- [x] Modern UI with custom components
- [x] Toast notification system
- [x] Settings and preferences
- [x] Offline data storage

### 🚧 In Progress
- [ ] Job editing functionality
- [ ] Enhanced analytics charts
- [ ] Push notifications for shift reminders

### 📋 Planned Features
- [ ] Apple Watch companion app
- [ ] iCloud sync across devices
- [ ] Widget support for quick time tracking
- [ ] Advanced reporting and insights
- [ ] Team/shared job management
- [ ] Integration with calendar apps
- [ ] Voice commands for hands-free tracking

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

- **Ori Cohen* - *Initial work* - [@1oridevs](https://github.com/1oridevs)

## 🙏 Acknowledgments

- SwiftUI community for inspiration and best practices
- Core Data documentation and examples
- Open source contributors who made this possible

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Check the documentation
- Contact us at [oridevs.offical@gmail.com]

---

**Made with ❤️ for time-conscious professionals**