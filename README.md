# TIS - Time is Money

A modern iOS app for tracking work hours and calculating earnings. Built with SwiftUI and Core Data for offline-first functionality.

## Features

### ✅ Implemented
- **Time Tracking**: Start/stop timer with job selection
- **Job Management**: Create and manage multiple jobs with different hourly rates
- **Earnings Calculation**: Automatic calculation based on hours worked and hourly rate
- **Shift Types**: Support for regular, overtime, special events, and flexible shifts
- **Bonus System**: Add named bonuses to jobs and shifts
- **History Tracking**: View past shifts with filtering by time period
- **Modern UI**: Clean, intuitive interface with SwiftUI
- **Offline Support**: Full offline functionality with Core Data

### 🚧 In Progress
- **Data Export**: CSV and PDF export functionality
- **Notifications**: Reminder system for shift tracking
- **Advanced Features**: Pause/resume functionality, idle detection

## Screenshots

*Screenshots will be added once the app is built and running*

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/TIS.git
```

2. Open `TIS.xcodeproj` in Xcode

3. Build and run on your device or simulator

## Usage

### Getting Started
1. **Add Jobs**: Tap the "+" button in the Jobs tab to create your first job
2. **Set Hourly Rate**: Enter your hourly rate for each job
3. **Add Bonuses**: Configure named bonuses for special events (like your "Kuppa" game bonus)
4. **Start Tracking**: Go to Time Tracking tab and select a job to start your shift

### Time Tracking
- **Start Shift**: Select a job and tap "Start Shift"
- **End Shift**: Tap "End Shift" when you're done
- **Add Notes**: Include notes about your shift
- **Select Shift Type**: Choose between Regular, Overtime, Special Event, or Flexible

### Managing Jobs
- **Create Jobs**: Add multiple jobs with different rates
- **Edit Jobs**: Modify job details and bonuses
- **View Statistics**: See total hours and earnings per job

### Viewing History
- **Filter by Period**: View shifts by day, week, month, or custom period
- **Export Data**: Export your data as CSV or PDF
- **Detailed View**: See comprehensive shift details including bonuses

## Data Models

### Job
- Name, hourly rate, creation date
- Associated shifts and bonuses
- Calculated total earnings and hours

### Shift
- Start/end times, duration
- Associated job and shift type
- Notes and bonuses
- Calculated earnings

### Bonus
- Name and amount
- Associated with jobs and shifts
- Reusable across multiple shifts

## Architecture

- **MVVM Pattern**: Clean separation of concerns
- **Core Data**: Offline-first data persistence
- **SwiftUI**: Modern, declarative UI framework
- **Combine**: Reactive programming for real-time updates

## Contributing

This is an open-source project. Feel free to contribute by:
- Reporting bugs
- Suggesting new features
- Submitting pull requests
- Improving documentation

## License

This project is open source and available under the [MIT License](LICENSE).

## Roadmap

### Version 1.1
- [ ] Data export functionality
- [ ] Push notifications
- [ ] Widget support

### Version 1.2
- [ ] Apple Watch app
- [ ] iCloud sync
- [ ] Advanced reporting

### Version 2.0
- [ ] Web app version
- [ ] Multi-user support
- [ ] Team management features

## Support

If you encounter any issues or have questions, please:
1. Check the existing issues on GitHub
2. Create a new issue with detailed information
3. Contact the maintainers

---

**TIS - Time is Money** - Because every minute counts! 💰⏰
