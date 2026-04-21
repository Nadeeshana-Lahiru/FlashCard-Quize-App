# 📇 Flashcard Quiz App

Master your studies by creating decks and testing your knowledge anywhere, anytime.

![Flutter](https://img.shields.io/badge/Flutter-3.22+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.4+-teal.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey)

## 📱 Overview

The **Flashcard Quiz App** is a mobile study companion that transforms traditional flashcards into an interactive learning experience. Create custom subjects, manage card decks, and test yourself with three different study modes — perfect for students, lifelong learners, or anyone preparing for exams.

## ✨ Key Features

### 📚 Subject Management
- Create, rename, and delete subjects (Science, History, Programming, etc.)
- Track card counts per subject
- Long-press context menu for quick subject actions

### 🃏 Smart Flashcards
- Create cards with questions and answers
- Edit and manage existing cards
- Import/export decks via CSV
- Share decks with friends

### 🎮 Three Study Modes

| Mode | Description |
|------|-------------|
| **Classic Swiping** | Traditional flashcards — read the question, flip to reveal answer |
| **Multiple Choice** | Test yourself with 4 answer options |
| **Typing Quiz** | Type the exact answer from memory (hardest mode!) |

### 👤 Personalization
- Customize your profile with name and learning goals
- View activity heatmap (last 30 days)
- Dark/Light theme support
- System default theme option

### 📊 Progress Tracking
- Review all created cards in a list view
- Track creation timestamps for each card
- Heatmap visualization of study activity

## 🖼️ Screenshots

| Splash Screen | Subjects Dashboard | Subject Options |
|------------|--------------------|-----------------|
| <img width="359" height="795" alt="Splash Screen" src="https://github.com/user-attachments/assets/c8302120-df8d-4b47-a5bc-8c9771cee0bf" /> | <img width="357" height="792" alt="Subjects Dashboard" src="https://github.com/user-attachments/assets/a689dde9-fda4-4e75-af2a-e47f2dd68d75" /> | <img width="353" height="792" alt="Subject Options" src="https://github.com/user-attachments/assets/7b7fccb2-26d7-4e69-a033-fe6e1b0bd4c1" /> |

| Study Mode Selection | Classic Swiping | Typing Quiz |
|----------------------|-----------------|-------------|
| <img width="356" height="791" alt="study mode" src="https://github.com/user-attachments/assets/0a0efebd-04d4-4906-8d5d-ab205623a5c0" /> | <img width="352" height="790" alt="swipe" src="https://github.com/user-attachments/assets/342974f3-a308-447b-b49b-f1e4161c04b3" /> | <img width="357" height="787" alt="typing" src="https://github.com/user-attachments/assets/8f4a643c-ac94-4564-a37f-b32244b0579c" /> |

| Manage Cards | History View | Profile Screen |
|--------------|--------------|----------------|
| <img width="357" height="791" alt="manage card" src="https://github.com/user-attachments/assets/b2609235-8af1-43e4-aa26-866412066a46" /> | <img width="356" height="792" alt="history" src="https://github.com/user-attachments/assets/8525bdc6-2254-4a65-8949-d7a218024676" /> | <img width="352" height="791" alt="profile" src="https://github.com/user-attachments/assets/6c5542f1-3fd9-4e79-95d6-da20cf21ab7d" /> |

| Settings | Add Subject Dialog | Card Management Actions |
|----------|--------------------|-------------------------|
| <img width="352" height="788" alt="settings" src="https://github.com/user-attachments/assets/067b6f2e-f9a1-452c-9e40-64a89e8af36e" /> | <img width="357" height="790" alt="add subject" src="https://github.com/user-attachments/assets/59d67451-afa8-4b87-9d0c-8080aa8fc02d" /> | <img width="357" height="788" alt="create card" src="https://github.com/user-attachments/assets/a964a8a8-1092-48a1-8817-6c141e5790a2" /> |

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Storage:** Cloud Supabase
- **Theming:** Custom theme provider with dark/light mode

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.22+)
- Dart (3.4+)
- Android Studio / VS Code
- iOS Simulator or Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flashcard-quiz-app.git
   cd flashcard-quiz-app

2. **Install dependencies**

   `flutter pub get`

3. **Run the app**

   `flutter run`

## 🧪 Testing the Features

- Create a subject → Tap "+ New Subject" → Enter name → Create
- Add a card → Tap a subject → "Manage Cards" → "+ New Card"
- Study → Tap a subject → Choose study mode → Start quizzing!
- Change theme → Settings → Choose Light/Dark/System
- View history → Bottom navigation → History tab

## 📂 Project Structure

lib/
├── models/          # Subject, Card, User models
├── screens/         # All UI screens (onboarding, subjects, study modes, etc.)
├── widgets/         # Reusable components (flashcard, heatmap, dialogs)
├── providers/       # State management (subjects, cards, theme, profile)
├── services/        # Storage, CSV import/export
└── utils/           # Helpers, constants, themes

## 📸 Screenshots Folder

Place your screenshots in screenshots/ with these filenames:

screenshots/
├── onboarding.png
├── subjects.png
├── subject_menu.png
├── study_modes.png
├── classic_swiping.png
├── typing_quiz.png
├── manage_cards.png
├── history.png
├── profile.png
├── settings.png
├── add_subject.png
└── card_actions.png

## 🤝 Contributing

Contributions are welcome! For major changes, please open an issue first to discuss what you'd like to change.

1. Fork the project
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See LICENSE for more information.
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📧 Contact

Your Name - Nadeeshana_Lahiru - nadeeshana1998@gmail.com
