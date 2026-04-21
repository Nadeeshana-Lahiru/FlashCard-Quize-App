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
| <img width="367" height="800" alt="image" src="https://github.com/user-attachments/assets/5aa64b82-d88f-4c19-b688-4a95b8c4f9da" /> | <img width="360" height="795" alt="image" src="https://github.com/user-attachments/assets/0bd30eaf-8d5e-4d0f-92bd-d449d74931e1" /> | <img width="362" height="793" alt="image" src="https://github.com/user-attachments/assets/cb77edd3-665c-4d29-8b3f-d8ea11b38d2f" /> |

| Study Mode Selection | Classic Swiping | Typing Quiz |
|----------------------|-----------------|-------------|
| <img width="357" height="791" alt="image" src="https://github.com/user-attachments/assets/d481b38a-a02f-4582-b5fa-40e95d91ccaa" /> | <img width="358" height="791" alt="image" src="https://github.com/user-attachments/assets/3d6632a7-d918-44bc-bf11-8466602e3ff5" /> | <img width="357" height="789" alt="image" src="https://github.com/user-attachments/assets/1af8317e-a38e-43e2-a0c0-fb61b80041b7" /> |

| Manage Cards | History View | Profile Screen |
|--------------|--------------|----------------|
| <img width="357" height="790" alt="image" src="https://github.com/user-attachments/assets/edc30343-e528-4f11-ab81-85127b46e62d" /> | <img width="357" height="791" alt="image" src="https://github.com/user-attachments/assets/d4945bd6-1dec-4ebd-af80-2ac07681d47a" /> | <img width="358" height="791" alt="image" src="https://github.com/user-attachments/assets/1ac35a76-e9f5-4df5-883d-d89f11511b8a" /> |

| Settings | Add Subject Dialog | Card Management Actions |
|----------|--------------------|-------------------------|
| <img width="358" height="789" alt="image" src="https://github.com/user-attachments/assets/3435a6d5-aa34-4955-b72e-5f1ad973730a" /> | <img width="357" height="792" alt="image" src="https://github.com/user-attachments/assets/5015b004-d30d-4320-9bdc-a34e6379230e" /> | <img width="355" height="790" alt="image" src="https://github.com/user-attachments/assets/6f7cf430-171d-4fa9-b481-def0e234b4d2" /> |

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

## 📂 Project Structure

lib/
├── models/          # Subject, Card, User models
├── screens/         # All UI screens (onboarding, subjects, study modes, etc.)
├── widgets/         # Reusable components (flashcard, heatmap, dialogs)
├── providers/       # State management (subjects, cards, theme, profile)
├── services/        # Storage, CSV import/export
└── utils/           # Helpers, constants, themes

## 🧪 Testing the Features

- Create a subject → Tap "+ New Subject" → Enter name → Create
- Add a card → Tap a subject → "Manage Cards" → "+ New Card"
- Study → Tap a subject → Choose study mode → Start quizzing!
- Change theme → Settings → Choose Light/Dark/System
- View history → Bottom navigation → History tab

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

## 📧 Contact

Your Name - Nadeeshana_Lahiru - nadeeshana1998@gmail.com
