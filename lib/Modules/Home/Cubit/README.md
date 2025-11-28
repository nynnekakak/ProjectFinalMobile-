# Home Module Cubit Structure Documentation

## Overview

The Home module has been refactored to use a Cubit-based architecture for state management. This separation of concerns improves code maintainability, testability, and reusability.

## Files Created

### 1. `home_state.dart`
Contains all state classes for the Home module:

- **HomeInitial**: Initial state when app starts
- **HomeLoading**: Loading state when fetching spendings/categories
- **HomeLoaded**: Successfully loaded data
  - `spendings`: List of spending records
  - `categoryMap`: Map of categories by ID
  - `userId`: Current user ID
  
- **HomeError**: Error state with message
- **HomeDeletingSpending**: State during spending deletion
- **HomeSpendingDeleted**: After successful deletion
- **HomeDeleteError**: Error during deletion
- **HomeSpendingUpdated**: After spending is updated
- **HomeRefreshing**: Refreshing data (pull to refresh)
- **HomeAILoading**: Loading AI advice
- **HomeAILoaded**: AI advice ready
- **HomeAIError**: Error getting AI advice

### 2. `home_cubit.dart`
Main Cubit class managing business logic:

#### Methods:

```dart
// Load initial data
Future<void> loadSpendings()

// Refresh data (pull to refresh)
Future<void> refreshSpendings()

// Delete a spending record
Future<void> deleteSpending(String spendingId)

// Notify that spending has been updated after edit
Future<void> notifySpendingUpdated()

// Get AI analysis advice
Future<void> getAIAdvice()

// Reset to initial state
void reset()
```

#### Dependencies:
- SpendingService
- CategoryService
- UserPreferences
- GeminiService
- BudgetService

## Usage Examples

### 1. Basic Usage in Widget

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/Home/Cubit/home_cubit.dart';
import 'package:moneyboys/Modules/Home/Cubit/home_state.dart';

// Wrap screen with BlocProvider
BlocProvider(
  create: (context) => HomeCubit()..loadSpendings(),
  child: const HomeScreenWithCubit(),
)
```

### 2. Building UI based on State

```dart
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    if (state is HomeLoading) {
      return const CircularProgressIndicator();
    } else if (state is HomeLoaded) {
      return ListView(
        children: state.spendings.map((spending) {
          return SpendingTile(spending: spending);
        }).toList(),
      );
    } else if (state is HomeError) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  },
)
```

### 3. Triggering Actions

```dart
// Load data
context.read<HomeCubit>().loadSpendings();

// Delete spending
context.read<HomeCubit>().deleteSpending(spendingId);

// Refresh data
context.read<HomeCubit>().refreshSpendings();

// Get AI advice
context.read<HomeCubit>().getAIAdvice();
```

### 4. Listening to State Changes

```dart
BlocListener<HomeCubit, HomeState>(
  listener: (context, state) {
    if (state is HomeDeleteError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: const HomeScreen(),
)
```

## Migration from StatefulWidget

### Before (StatefulWidget):
```dart
class _HomeScreenState extends State<HomeScreen> {
  List<Spending> spendings = [];
  bool isLoading = true;

  void _loadSpendings() async {
    setState(() => isLoading = true);
    // Load data...
  }

  void _deleteSpending(String id) async {
    await SpendingService().deleteSpending(id);
    await _loadSpendings();
  }
}
```

### After (Cubit):
```dart
// In your screen
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    if (state is HomeLoading) {
      // Show loading
    } else if (state is HomeLoaded) {
      // Show loaded data
    }
  },
)

// Trigger actions
context.read<HomeCubit>().deleteSpending(id);
context.read<HomeCubit>().loadSpendings();
```

## Benefits of This Structure

1. **Separation of Concerns**: UI logic separated from business logic
2. **Testability**: Easy to test Cubit independently
3. **Reusability**: Can use same Cubit in multiple screens
4. **Scalability**: Easy to add new states and methods
5. **State Persistence**: Automatic state management
6. **Error Handling**: Centralized error handling
7. **Performance**: Efficient rebuild with BlocBuilder

## Example Implementation File

See `home_screen_with_cubit.dart` for a complete example of how to use the new Cubit structure.

### Key Points in Example:
- Proper error handling with BlocListener
- State-based conditional rendering
- Proper context reading for triggering Cubit methods
- FAB management based on loading state
- Pull-to-refresh integration

## Migration Checklist

- [x] Create `home_state.dart` with all states
- [x] Create `home_cubit.dart` with business logic
- [x] Extract loading logic from StatefulWidget
- [x] Separate delete, refresh, and AI logic
- [ ] Update existing `home_screen.dart` to use Cubit (optional)
- [ ] Add tests for Cubit
- [ ] Update app router to provide Cubit

## Next Steps

1. **Update App Router**: Modify the route configuration to provide HomeCubit
2. **Replace StatefulWidget**: Gradually migrate `home_screen.dart` to use Cubit
3. **Add Tests**: Write unit tests for `home_cubit.dart`
4. **Performance Optimization**: Use BlocSelector for specific state properties
5. **Error Recovery**: Implement retry logic for failed operations

## Troubleshooting

### Issue: State not updating
- Ensure you're using `BlocBuilder` or `BlocListener`
- Check that Cubit is provided in widget tree

### Issue: Widget not rebuilding
- Use `BlocBuilder` for rebuilding on state change
- Check state equatable implementation

### Issue: Memory leaks
- Cubit handles cleanup automatically
- No need for manual subscription management
