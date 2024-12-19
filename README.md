# Hedieaty - Gift List Management App

Welcome to **Hedieaty**, the ultimate app designed to simplify and enhance the experience of creating, managing, and sharing gift wish lists for any special occasion. Whether it's a birthday, wedding, graduation, or holiday, **Hedieaty** streamlines gift-giving, making it more fun, efficient, and collaborative.

### Version 1.0.0
- Initial deployment to Amazon Appstore.
- You can now download the app from the [Amazon Appstore](https://www.amazon.com/dp/B0DQVP9DRT/ref=mp_s_a_1_2?crid=NEN5EDPWOBNS&dib=eyJ2IjoiMSJ9.EcsHMnrnMkIy34TATUPZ1IPa8Jn9WjLxsdd1qsAUYpo.AjDgj62L_j7iCEfPsQ4NpLrdFUx_pKpgxJF9sRVFe2Q&dib_tag=se&keywords=hedietary&qid=1734585084&s=mobile-apps&sprefix=hedieaty%2Caps%2C245&sr=1-2#lookInside).

![Amazon Appstore](https://img.shields.io/badge/Amazon_Appstore-Available-green)

## Key Features

### 1. **User-Friendly Interface**
   - Create, manage, and customize gift lists for all your special occasions.
   - Effortless navigation with a clean and intuitive UI that enhances the user experience.

### 2. **Gift List Management**
   - **Create Custom Events:** Easily add new events or gift lists directly from your account.
   - **Manage Events:** Edit, delete, and organize your events seamlessly.
   - **Gift Management:** Add, edit, and remove gifts with the option to include images, descriptions, categories, and prices.
   - **Pledge System:** Friends and family can pledge to buy specific gifts, and their pledges are instantly updated in real time.

### 3. **Real-Time Syncing with Firebase**
   - Sync your gift lists and event data across all devices with Firebase Realtime Database.
   - Real-time updates on gift status, including pledged and purchased gifts, with color-coded indicators for easy tracking.
   - Firebase Authentication for secure user accounts and authentication.

### 4. **Offline Functionality**
   - **Offline Mode:** Access and manage your gift lists even without an internet connection, with automatic sync when back online.
   - View the latest updates from your gift lists and events, and interact with them offline.
   - **Local Database (SQLite):** Local storage of user profiles, events, and gifts to ensure a smooth offline experience.

### 5. **Gift Search and Filtering**
   - **Advanced Search:** Find the perfect gift with ease by searching and filtering gifts by name, category, or event date.
   - Sorting options available for gifts and events to make management even easier.

### 6. **Notifications**
   - **In-App Notifications:** Be notified when someone pledges a gift for your event.
   - **Push Notifications:** Receive alerts about gift status changes, even when the app is in the background.
   - **Custom Alerts:** Get notifications when your friends have pledged to buy your gifts or even purchased it.

### 7. **Photo Support**
   - Easily upload gift images and view them in full-screen mode for a better shopping experience.

### 8. **Customization and Design**
   - **Dark Mode:** A sleek dark mode for a more comfortable viewing experience.
   - Smooth, engaging animations for transitions and user actions, ensuring a delightful app experience.

### 9. **Data Integrity and Validation**
   - **Data Validation:** Ensure the integrity of user inputs, including required fields and valid date formats.
   - Adherence to MVC (Model-View-Controller) design pattern, ensuring clean and maintainable code.

### 10. **Periodic Data Synchronization**
   - **Scheduled Syncs:** Automatic synchronization with Firebase every 10 days using the WorkManager package to keep all devices up to date with the latest data.
   - Clear local data and fetch the latest updates from Firebase during sync.

### 11. **Testing and Automation**
   - **End-to-End Testing:** Ensure that core workflows such as signing in, creating events, and managing gifts are bug-free.
   - **Automated Testing:** Powershell and Bash scripts for running tests and generating logs, ensuring smooth testing with no manual intervention.

### 12. **Comprehensive User Profiles**
   - Manage your personal details and set preferences in your user profile.
   - Keep track of your created events, gifts, and pledged items.
   - See an overview of your pledged gifts and track your participation in your friends' gift lists.

---

## Technology Stack

- **Frontend:** Built with Flutter for cross-platform support (Android, iOS).
- **Backend:** Firebase Realtime Database for data synchronization and Firebase Authentication for secure logins.
- **Local Storage:** SQLite database for offline data persistence.
- **Notifications:** Firebase Cloud Messaging for in-app and push notifications.
- **Synchronization:** WorkManager for periodic synchronization between local and cloud databases.

---

## Installation

### Prerequisites
- Flutter SDK
- Firebase Account

### Clone the Repository

```bash
git clone https://github.com/rafikghaly/Hedieaty.git
cd hedieaty
```

### Setup Firebase

1. Create a Firebase project.
2. Add Firebase to your Flutter project by following the instructions for [iOS](https://firebase.flutter.dev/docs/overview#ios) and [Android](https://firebase.flutter.dev/docs/overview#android).
3. Enable Firebase Authentication, Firestore, and Firebase Cloud Messaging.

### Run the Application

```bash
flutter pub get
flutter run
```

---

## Contribution

We welcome contributions from the community! If you'd like to contribute, please fork the repository and submit a pull request. Here's how you can get started:

1. **Fork the Repo** - Click on the "Fork" button at the top right of this page.
2. **Clone the Repo** - Clone your forked repository to your local machine.
3. **Create a Branch** - Create a feature branch for your changes.
4. **Make Your Changes** - Modify the code and commit your changes.
5. **Submit a Pull Request** - Push your changes to your fork and create a pull request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **Flutter**: For creating a powerful, flexible framework to build apps for multiple platforms.
- **Firebase**: For real-time database and authentication solutions.
- **SQLite**: For providing a reliable local database solution.

---

We hope **Hedieaty** makes your gift-giving experiences more enjoyable and organized! Enjoy using the app, and feel free to open an issue if you have any questions or feedback.
