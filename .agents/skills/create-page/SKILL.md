---
name: create-page
description: Automates the process of adding a new Flutter screen/page, creating the view file, registering it in app_router.dart, and running build_runner.
---
# Create Page Skill

Use this skill when you need to create a new screen (view) and route it in the Flutter application.

## Step-by-Step Instructions

Follow these steps to add a new page to the mobile application:

### 1. Identify or Create the Feature Folder
Locate the feature under `submissions/ozgur-sak-login/mobile/lib/features/`.
- If the feature is new, create the directories:
  - `submissions/ozgur-sak-login/mobile/lib/features/<feature_name>/`
  - `submissions/ozgur-sak-login/mobile/lib/features/<feature_name>/view/screens/`
  - `submissions/ozgur-sak-login/mobile/lib/features/<feature_name>/view/widgets/`
  - `submissions/ozgur-sak-login/mobile/lib/features/<feature_name>/viewmodel/`
  - `submissions/ozgur-sak-login/mobile/lib/features/<feature_name>/data/`

### 2. Create the View (Screen) File
Create the new view file at `submissions/ozgur-sak-login/mobile/lib/features/<feature_name>/view/screens/<screen_name_snake_case>_view.dart`.
Ensure that the class is annotated with `@RoutePage()` from `auto_route` and ends with `View`.

**Template:**
```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class <ScreenNamePascalCase>View extends StatelessWidget {
  const <ScreenNamePascalCase>View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('<ScreenNameTitle>'),
      ),
      body: const Center(
        child: Text('<ScreenNameTitle> View'),
      ),
    );
  }
}
```

### 3. Register the Route in `app_router.dart`
Modify the file [app_router.dart](file:///c:/Users/nisap/vbt_staj/staj-2026-intern-assignments/submissions/ozgur-sak-login/mobile/lib/core/route/app_router.dart):
1. **Import the new view** at the top of the file using a relative path, e.g.:
   ```dart
   import '../../features/<feature_name>/view/screens/<screen_name_snake_case>_view.dart';
   ```
2. **Add the route configuration** inside the `routes` list:
   ```dart
   AutoRoute(page: <ScreenNamePascalCase>Route.page, path: '/<screen_name_url_path>'),
   ```
   *(Note: AutoRoute automatically generates `Route` classes by replacing `View` with `Route` as defined in `@AutoRouterConfig(replaceInRouteName: 'View,Route')`)*.

### 4. Run Code Generation
Open the terminal in `submissions/ozgur-sak-login/mobile` and run the build runner:
```bash
dart run build_runner build --delete-conflicting-outputs
```
Verify that the output `app_router.gr.dart` compiles successfully.
