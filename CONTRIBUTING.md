# Contributing to TIS (Time is Money) 🤝

Thank you for your interest in contributing to TIS! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- iOS 17.0+ development environment
- Xcode 15.0+
- Swift 5.9+
- Git

### Development Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/TIS.git`
3. Open `TIS.xcodeproj` in Xcode
4. Create a new branch: `git checkout -b feature/your-feature-name`

## 📋 Development Guidelines

### Code Style
- Follow Swift naming conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use SwiftUI best practices

### Commit Messages
- Use clear, descriptive commit messages
- Start with a verb in imperative mood
- Keep the first line under 50 characters
- Add more details in the body if needed

Examples:
```
Add job editing functionality
Fix toolbar ambiguity in JobsView
Update README with new features
```

### Pull Request Process
1. Ensure your code compiles without warnings
2. Test your changes thoroughly
3. Update documentation if needed
4. Create a pull request with a clear description
5. Reference any related issues

## 🏗️ Architecture Guidelines

### File Organization
- Keep views in the `Views/` directory
- Reusable components go in `Components/`
- Business logic belongs in `Managers/`
- Design system files in `Design/`

### SwiftUI Best Practices
- Use `@State`, `@Binding`, `@ObservedObject` appropriately
- Prefer composition over inheritance
- Keep views small and focused
- Use previews for development

### Core Data Guidelines
- Use proper Core Data patterns
- Handle errors gracefully
- Use background contexts for heavy operations
- Keep the main context on the main thread

## 🧪 Testing

### Testing Requirements
- Add unit tests for new business logic
- Test UI components with SwiftUI previews
- Test on multiple device sizes
- Verify accessibility features

### Testing Checklist
- [ ] Code compiles without warnings
- [ ] All tests pass
- [ ] UI looks correct on different devices
- [ ] Accessibility features work
- [ ] Performance is acceptable

## 🐛 Bug Reports

### Before Reporting
1. Check if the issue already exists
2. Try to reproduce the issue
3. Check the latest version

### Bug Report Template
```
**Bug Description**
A clear description of the bug.

**Steps to Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment**
- iOS Version: [e.g., 17.0]
- Device: [e.g., iPhone 15]
- App Version: [e.g., 1.0.0]

**Additional Context**
Any other context about the problem.
```

## ✨ Feature Requests

### Before Requesting
1. Check if the feature already exists
2. Consider if it fits the app's purpose
3. Think about implementation complexity

### Feature Request Template
```
**Feature Description**
A clear description of the feature.

**Use Case**
Why would this feature be useful?

**Proposed Solution**
How would you like to see this implemented?

**Alternatives**
Any alternative solutions you've considered.

**Additional Context**
Any other context about the feature request.
```

## 📝 Documentation

### Code Documentation
- Document public APIs
- Add inline comments for complex logic
- Update README for new features
- Keep documentation up to date

### Documentation Standards
- Use clear, concise language
- Include code examples where helpful
- Keep documentation current with code changes
- Use proper markdown formatting

## 🎨 Design Contributions

### UI/UX Guidelines
- Follow iOS Human Interface Guidelines
- Maintain consistency with existing design
- Consider accessibility in all designs
- Test on multiple device sizes

### Asset Guidelines
- Use vector graphics when possible
- Provide assets in multiple resolutions
- Follow naming conventions
- Optimize file sizes

## 🔒 Security

### Security Guidelines
- Never commit sensitive information
- Use secure coding practices
- Validate all user inputs
- Handle errors securely

### Sensitive Information
- API keys
- Passwords
- Personal data
- Debug information

## 📞 Getting Help

### Communication Channels
- GitHub Issues for bug reports and feature requests
- GitHub Discussions for general questions
- Pull Request comments for code review

### Code Review Process
1. All changes require review
2. Address feedback promptly
3. Be respectful and constructive
4. Ask questions if unclear

## 🎯 Contribution Ideas

### Good First Issues
- Fix typos in documentation
- Add unit tests
- Improve accessibility
- Add SwiftUI previews

### Advanced Contributions
- New features
- Performance optimizations
- Architecture improvements
- Platform expansions

## 📄 License

By contributing to TIS, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- App credits (if applicable)

---

Thank you for contributing to TIS! Your efforts help make time tracking better for everyone. 🎉
