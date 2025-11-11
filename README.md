# Product Pulse

A Flutter-based inventory management application built with Firebase Firestore for homelab equipment tracking. This app demonstrates real-time database operations and modern mobile development practices with advanced filtering and analytics.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Overview

Product Pulse provides a comprehensive interface for managing homelab equipment inventories. The application connects to Firebase Firestore to handle all data operations, ensuring information stays synchronized across devices in real-time. Users can track products with detailed information including name, category, quantity, price, and descriptions.

The interface uses the Catppuccin Mocha color scheme, which provides excellent contrast and reduces eye strain during extended use. All CRUD operations happen in real-time, so changes appear immediately without requiring manual refreshes.

## Features

### Authentication
- **User Registration**: Email and password registration with validation
  - Email must be in valid format (e.g., test@gsu.com)
  - Password must be at least 6 characters
- **User Sign In**: Secure login with Firebase Authentication
- **Profile Screen**: View user email and manage account
- **Change Password**: Update password from profile screen
- **Logout**: Sign out functionality with redirect to login screen
- **Session Management**: Automatic authentication state tracking

### Core Functionality
- **Create**: Add new inventory items with validation
- **Read**: View all items in real-time with automatic updates
- **Update**: Edit existing items with pre-filled forms
- **Delete**: Remove items with confirmation dialogs

### Data Model
Each product includes:
- **name** (String): Product name
- **quantity** (int): Stock quantity with low/out of stock indicators
- **price** (double): Product price in USD
- **category** (String): Product category (Networking, Storage, Computing, Power, Cooling, Monitoring, Accessories)
- **description** (String): Detailed product description
- **createdAt** (DateTime): Timestamp with automatic Firestore conversion

## Enhanced Features Implemented

### 1. Advanced Search & Filtering
- **Real-time Search**: Search products by name or description as you type
- **Category Filters**: Filter by 7 equipment categories with visual chip selection
- **Stock Status Filters**: Filter by "All", "In Stock", "Low Stock" (<5 items), or "Out of Stock"
- **Visual Indicators**: Color-coded badges for low stock (yellow) and out of stock (red) items
- **Responsive UI**: Horizontal scrolling filter chips for easy navigation

### 2. Data Insights Dashboard
Accessible via dashboard icon in app bar, provides:
- **Summary Statistics**:
  - Total unique items count
  - Total inventory value (quantity × price)
  - Number of categories
  - Total stock quantity
- **Out of Stock Alert**: Lists all items with 0 quantity
- **Low Stock Warning**: Shows items with quantity < 5
- **Category Breakdown**: Detailed analysis per category including:
  - Item count per category
  - Total value per category
  - Total quantity per category
  - Sorted by total value (highest first)

## Technical Stack

- **Flutter**: Cross-platform mobile development framework
- **Firebase Authentication**: Secure user authentication and management
- **Firebase Firestore**: Cloud-based NoSQL database with real-time sync
- **Material Design 3**: Modern UI components
- **StreamBuilder**: Reactive UI updates
- **Catppuccin Mocha**: Custom dark theme for reduced eye strain

## Project Structure

```
lib/
├── main.dart                          # App entry point with auth state management
├── models/
│   └── product.dart                   # Product data model with Firestore conversion
├── services/
│   ├── auth_service.dart              # Firebase Authentication operations
│   └── firebase_service.dart          # Firestore CRUD operations
├── screens/
│   ├── auth_screen.dart               # Login and registration screen
│   ├── profile_screen.dart            # User profile with logout and password change
│   ├── product_list_screen.dart       # Main screen with search & filters
│   ├── add_edit_product_screen.dart   # Form for adding/editing products
│   └── dashboard_screen.dart          # Analytics dashboard
└── theme/
    └── catppuccin_theme.dart          # Custom color scheme
```