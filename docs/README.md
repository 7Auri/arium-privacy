# Arium - Privacy & Terms

This repository hosts the Privacy Policy and Terms of Service for the Arium habit tracking app.

## 🌐 Live URLs

- **Homepage:** https://YOUR-USERNAME.github.io/arium-privacy/
- **Privacy Policy:** https://YOUR-USERNAME.github.io/arium-privacy/privacy.html
- **Terms of Service:** https://YOUR-USERNAME.github.io/arium-privacy/terms.html

## 📱 About Arium

Arium is a beautiful habit tracking app for iOS that helps you build better habits daily.

**Features:**
- 🔥 Streak tracking
- 📊 Beautiful charts
- 🎯 Smart reminders
- 🎨 20 themes
- ⌚ Apple Watch support
- ☁️ iCloud sync
- 💎 Premium features

## 🚀 Setup Instructions

### 1. Create GitHub Repository

```bash
# Create a new repository named "arium-privacy"
# Make it public
# Don't initialize with README (we already have files)
```

### 2. Push Files to GitHub

```bash
cd /path/to/Arium
git init
git add docs/
git commit -m "Add privacy policy and terms of service"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/arium-privacy.git
git push -u origin main
```

### 3. Enable GitHub Pages

1. Go to repository Settings
2. Scroll to "Pages" section
3. Source: Deploy from a branch
4. Branch: `main`
5. Folder: `/docs`
6. Click Save

### 4. Wait for Deployment

GitHub Pages will deploy your site in 1-2 minutes. You'll see a green checkmark when ready.

### 5. Update App URLs

Once deployed, update the URLs in your app:

**SettingsView.swift:**
```swift
// Replace YOUR-USERNAME with your GitHub username
"https://YOUR-USERNAME.github.io/arium-privacy/privacy.html"
"https://YOUR-USERNAME.github.io/arium-privacy/terms.html"
```

**PrivacyPolicyView.swift & TermsOfServiceView.swift:**
```swift
// Update Safari button URLs
URL(string: "https://YOUR-USERNAME.github.io/arium-privacy/privacy.html")
URL(string: "https://YOUR-USERNAME.github.io/arium-privacy/terms.html")
```

## 📝 Files

- `index.html` - Homepage with links to privacy and terms
- `privacy.html` - Full privacy policy
- `terms.html` - Full terms of service

## 🎨 Customization

All HTML files use inline CSS for easy customization. Colors use the Arium brand palette:
- Primary: `#667eea` (Purple)
- Secondary: `#764ba2` (Dark Purple)

## 📧 Contact

For questions or updates:
- Email: support@zorbeyteam.com
- Website: https://zorbeyteam.com/arium

## 📄 License

© 2024 Zorbey Team. All rights reserved.
