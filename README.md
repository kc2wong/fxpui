# FXPUI

A proof of concept project to build a web application using Flutter Web.  After learning flutter for a period of time, I decide to build a more practical web application with Flutter 

### Key Features
- Theming support
- Multi-language support
- Animated effect
    - Page navigation
    - Expand / collapse search criteria pane
- State management and event streaming with Business Logic Component (Bloc)
    - Propagate / restore page data from Bloc state during page navigation
    - Change of page data maintained by TextEditingController
    - Bloc listener to manage followings
        - Hide / show to loading indicator
        - Display toast message
        - Toggle language / theme
        - Page navigation
- Dependency Injection
- Integration with Mock API server
- Reusable Widgets
    - Standardize look and feel
    - (Try to) adopt Microsoft FluentUI design guideline

### To Start
1. Install latest Flutter SDK (version 2.10.x or 3.0.x)
2. Enable Flutter web support
    - `flutter config --enable-web`
3. Download required dependency
    - `flutter pub get`
4. Start the web application
    - `flutter run -d chrome`

Live Demo at https://fxpui-flutter.web.app


