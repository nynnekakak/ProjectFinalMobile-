# Setting Module Cubit Structure Documentation

## Overview

The Setting module's Cubit implementation provides centralized state management for all user settings, profile management, and account-related operations.

---

## Files Created

### 1. `setting_state.dart`
**Purpose**: Define all state classes for Setting module

**States (16 total)**:
- `SettingInitial` - Initial state
- `SettingLoading` - Loading user data
- `SettingLoaded(user, categories, userId)` - Data loaded successfully
- `SettingError(message)` - General error
- `SettingUpdatingProfile` - Updating profile
- `SettingProfileUpdated(user)` - Profile updated
- `SettingProfileUpdateError(message)` - Profile update error
- `SettingChangingPassword` - Changing password
- `SettingPasswordChanged` - Password changed
- `SettingPasswordChangeError(message)` - Password change error
- `SettingLoadingCategories` - Loading categories
- `SettingCategoriesLoaded(categories)` - Categories loaded
- `SettingCategoriesError(message)` - Categories error
- `SettingAddingCategory` - Adding category
- `SettingCategoryAdded` - Category added
- `SettingAddCategoryError(message)` - Add category error
- `SettingDeletingCategory(categoryId)` - Deleting category
- `SettingCategoryDeleted(categoryId)` - Category deleted
- `SettingDeleteCategoryError(message, categoryId)` - Delete category error
- `SettingLoggingOut` - Logging out
- `SettingLoggedOut` - Logged out
- `SettingLogoutError(message)` - Logout error
- `SettingDeletingAccount` - Deleting account
- `SettingAccountDeleted` - Account deleted
- `SettingDeleteAccountError(message)` - Delete account error
- `SettingRefreshing(user, categories)` - Refreshing data

**Key Properties**:
```dart
SettingLoaded(
  UserModel user,              // Current user
  List<Category> categories,   // User's categories
  String? userId,             // User ID
)
```

---

### 2. `setting_cubit.dart`
**Purpose**: Business logic for Setting module

**Dependencies**:
```dart
UserService        // User operations (CRUD)
CategoryService    // Category management
UserPreferences    // Local storage (user ID, preferences)
```

**Public Methods** (9 total):

#### 1. `loadUserProfile()`
- **Purpose**: Load user profile and categories on init
- **Emits**: Loading → (Loaded | Error)
- **Side Effects**: Caches userId internally

```dart
await context.read<SettingCubit>().loadUserProfile();
```

#### 2. `refreshUserData()`
- **Purpose**: Pull-to-refresh for profile and categories
- **Emits**: Refreshing → (Loaded | Error)
- **Note**: Can call from SettingLoaded state or will auto-load

#### 3. `updateUserProfile({name, email, profileImageUrl})`
- **Purpose**: Update user profile information
- **Emits**: UpdatingProfile → (ProfileUpdated | ProfileUpdateError)
- **Implementation**: Creates new UserModel with updated fields

```dart
context.read<SettingCubit>().updateUserProfile(
  name: 'John Doe',
  email: 'john@example.com',
);
```

#### 4. `changePassword({currentPassword, newPassword})`
- **Purpose**: Change user password
- **Emits**: ChangingPassword → (PasswordChanged | PasswordChangeError)
- **Note**: Placeholder - implement actual API call

```dart
context.read<SettingCubit>().changePassword(
  currentPassword: 'oldPass123',
  newPassword: 'newPass456',
);
```

#### 5. `loadCategories()`
- **Purpose**: Fetch all user categories
- **Emits**: LoadingCategories → (CategoriesLoaded | CategoriesError)

#### 6. `addCategory({name, type, icon})`
- **Purpose**: Create new category
- **Emits**: AddingCategory → (CategoryAdded | AddCategoryError) → CategoriesLoaded

#### 7. `deleteCategory(categoryId)`
- **Purpose**: Delete a category
- **Emits**: DeletingCategory → (CategoryDeleted | DeleteCategoryError) → CategoriesLoaded

#### 8. `logout()`
- **Purpose**: Logout user
- **Emits**: LoggingOut → (LoggedOut | LogoutError)
- **Side Effects**: Clears stored userId

#### 9. `deleteAccount()`
- **Purpose**: Delete user account
- **Emits**: DeletingAccount → (AccountDeleted | DeleteAccountError)
- **Side Effects**: Removes user from database and clears localStorage

#### 10. `reset()`
- **Purpose**: Reset Cubit to initial state
- **Emits**: SettingInitial

---

### 3. `setting_screen_with_cubit.dart`
**Purpose**: Complete working example showing Cubit integration

**Key Features**:
- ✅ BlocProvider setup for Cubit
- ✅ BlocBuilder for state rendering
- ✅ BlocListener for side effects
- ✅ Pull-to-refresh functionality
- ✅ Error handling with retry
- ✅ Multiple sections (Profile, Categories, Account)
- ✅ Dialogs for password change and confirmations

**Sections**:
1. **Profile Section**: User avatar and basic info
2. **Personal Information**: Name/email editing with save button
3. **Categories Section**: List of user categories with delete option
4. **Account Actions**: Logout and delete account buttons

---

## Usage Examples

### 1. Basic Setup in Routes

```dart
// In your app router / routes.dart
BlocProvider(
  create: (context) => SettingCubit()..loadUserProfile(),
  child: const SettingScreenWithCubit(),
)
```

### 2. Using in Widget

```dart
class MySettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        if (state is SettingLoading) {
          return const CircularProgressIndicator();
        } else if (state is SettingLoaded) {
          return Text('Welcome, ${state.user.name}');
        } else if (state is SettingError) {
          return Text('Error: ${state.message}');
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```

### 3. Listening for Side Effects

```dart
BlocListener<SettingCubit, SettingState>(
  listener: (context, state) {
    if (state is SettingProfileUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    } else if (state is SettingLoggedOut) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/signin',
        (route) => false,
      );
    }
  },
  child: MyContent(),
)
```

### 4. Triggering Actions

```dart
// Update profile
context.read<SettingCubit>().updateUserProfile(
  name: _nameController.text,
  email: _emailController.text,
);

// Change password
context.read<SettingCubit>().changePassword(
  currentPassword: oldPass,
  newPassword: newPass,
);

// Logout
context.read<SettingCubit>().logout();

// Delete account
context.read<SettingCubit>().deleteAccount();
```

---

## Architecture Pattern

```
┌─────────────────────────────────────────┐
│        UI Layer (Widget/Screen)         │
│  • SettingScreenWithCubit               │
│  • BlocProvider, BlocBuilder, Listener  │
└────────────────┬────────────────────────┘
                 │ BlocBuilder/Listener
                 ▼
┌─────────────────────────────────────────┐
│    State Management (Cubit)              │
│  • SettingCubit (9 methods)             │
│  • Emits SettingState subclasses        │
└────────────────┬────────────────────────┘
                 │ Calls
                 ▼
┌─────────────────────────────────────────┐
│       Data/Service Layer                 │
│  • UserService                          │
│  • CategoryService                      │
│  • UserPreferences                      │
└─────────────────────────────────────────┘
```

---

## Error Handling

All methods follow a consistent error handling pattern:

```dart
try {
  emit(LoadingState());
  // Perform async operation
  emit(SuccessState());
} catch (e) {
  emit(ErrorState('Failed: ${e.toString()}'));
}
```

**Error Recovery**:
- Listeners can trigger retry logic: `context.read<SettingCubit>().loadUserProfile()`
- UI shows error message with retry button
- Failed state doesn't clear previously loaded data

---

## Best Practices

1. **Always wrap with BlocProvider at route level**:
   ```dart
   // ✅ Good
   BlocProvider(
     create: (context) => SettingCubit()..loadUserProfile(),
     child: SettingScreen(),
   )
   
   // ❌ Bad
   BlocProvider(
     create: (context) => SettingCubit(),  // Will create multiple instances
     child: Column(...),
   )
   ```

2. **Use BlocSelector for specific properties**:
   ```dart
   BlocSelector<SettingCubit, SettingState, String?>(
     selector: (state) => state is SettingLoaded ? state.user.name : null,
     builder: (context, name) => Text(name ?? ''),
   )
   ```

3. **Handle all state variants**:
   ```dart
   // ✅ Good
   if (state is SettingLoading) { ... }
   else if (state is SettingLoaded) { ... }
   else if (state is SettingError) { ... }
   
   // ❌ Bad
   if (state is SettingLoading) { ... }
   else { ... }  // Covers SettingLoaded, SettingError, and more
   ```

4. **Don't store Cubit instances**:
   ```dart
   // ❌ Bad
   SettingCubit? _cubit;
   
   @override
   void initState() {
     _cubit = SettingCubit();  // Creates multiple instances
   }
   
   // ✅ Good
   context.read<SettingCubit>()  // Access from context
   ```

---

## Common Patterns

### Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<SettingCubit>().refreshUserData();
  },
  child: BlocBuilder<SettingCubit, SettingState>(
    // Your content
  ),
)
```

### Retry Logic

```dart
if (state is SettingError) {
  return Column(
    children: [
      Text(state.message),
      ElevatedButton(
        onPressed: () => context.read<SettingCubit>().loadUserProfile(),
        child: const Text('Retry'),
      ),
    ],
  );
}
```

### Multiple State Listeners

```dart
BlocListener<SettingCubit, SettingState>(
  listener: (context, state) {
    if (state is SettingProfileUpdated) {
      _showSnackBar('Profile updated');
    } else if (state is SettingPasswordChanged) {
      _showSnackBar('Password changed');
    } else if (state is SettingLoggedOut) {
      _navigateToLogin();
    }
  },
  child: BlocBuilder<SettingCubit, SettingState>(
    builder: (context, state) { ... },
  ),
)
```

---

## Integration Checklist

- [ ] Import all state classes in screens
- [ ] Wrap router with BlocProvider
- [ ] Add BlocListener for navigation/snackbars
- [ ] Add BlocBuilder for UI rendering
- [ ] Handle loading, loaded, and error states
- [ ] Test all 9 Cubit methods
- [ ] Verify error messages are user-friendly
- [ ] Test pull-to-refresh
- [ ] Test retry logic

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Cubit not found in context" | Ensure BlocProvider is above BlocBuilder/BlocListener |
| "State not updating" | Make sure you're emitting new state instances |
| "Multiple Cubit instances" | Use `context.read()` instead of creating new instances |
| "Memory leaks" | BlocProvider handles cleanup automatically on dispose |

---

## Next Steps

1. **Replace existing Setting screens** with SettingScreenWithCubit
2. **Update navigation** to use new Cubit-based flow
3. **Add tests** using BlocTest pattern
4. **Extend functionality** by adding new states/methods as needed
5. **Apply same pattern** to other modules (Budget, Expense, Monitor)

---

**Created**: For Setting Module State Management Refactoring
**Version**: 1.0
**Last Updated**: Current Session
