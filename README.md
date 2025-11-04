# Product Pulse

A Flutter-based product management application built with Firebase Firestore. This app demonstrates real-time database operations and modern mobile development practices.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Overview

Product Pulse provides a straightforward interface for managing product inventories. The application connects to Firebase Firestore to handle all data operations, ensuring information stays synchronized across devices. Users can add products with pricing and descriptions, update existing entries, and remove items as needed.

The interface uses the Catppuccin Mocha color scheme, which provides good contrast and reduces eye strain during extended use. All CRUD operations happen in real-time, so changes appear immediately without requiring manual refreshes.

## Technical Stack

- Flutter framework for cross-platform development
- Firebase Firestore for cloud-based NoSQL database
- Material Design 3 components
- StreamBuilder for reactive UI updates

## Running the Application

Install dependencies with `flutter pub get`. Configure Firebase by running `flutterfire configure` and selecting your project. Create a Firestore database in test mode from the Firebase console. Run the app using `flutter run` with your preferred device target.

