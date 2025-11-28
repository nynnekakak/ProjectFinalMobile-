# Home Module Cubit Migration Guide

## Quick Reference

| File | Purpose | Lines |
|------|---------|-------|
| `home_state.dart` | 11 state classes with full documentation | 152 |
| `home_cubit.dart` | Business logic with 6 main methods | 106 |
| `home_screen_with_cubit.dart` | Complete example implementation | 426 |
| `README.md` | Detailed documentation | 180+ |

## 🎯 Migration Steps

### Phase 1: Understanding (Read This First)

1. **Read the Documentation**
   - Read `Cubit/README.md` for overview
   - Review `CUBIT_ARCHITECTURE.md` for diagrams
   - Check this file for migration path

2. **Understand the New Structure**
   - 11 different states for different scenarios
   - Cubit handles all business logic
   - Services injected via constructor

3. **Review the Example**
   - Open `home_screen_with_cubit.dart`
   - Compare with original `home_screen.dart`
   - Note the differences

### Phase 2: Integration (Implement in Your Project)

#### Step 1: Update App Router

**File**: `lib/app/config/app_router.dart` or `lib/app/route.dart`

**Current Code**:
```dart
List<Widget> get _pages => [
  HomeScreen(key: _homeScreenKey),
  // ...
];
```

**After (Option A - Keep StateManagement)**:
```dart
List<Widget> get _pages => [
  BlocProvider(
    create: (context) => HomeCubit()..loadSpendings(),
    child: HomeScreen(key: _homeScreenKey),
  ),
  // ...
];
```

**After (Option B - Use New Implementation)**:
```dart
List<Widget> get _pages => [
  BlocProvider(
    create: (context) => HomeCubit()..loadSpendings(),
    child: HomeScreenWithCubit(key: _homeScreenKey),
  ),
  // ...
];
```

#### Step 2: Add Required Imports

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/Home/Cubit/home_cubit.dart';
import 'package:moneyboys/Modules/Home/Cubit/home_state.dart';
import 'package:moneyboys/Modules/Home/home_screen_with_cubit.dart'; // if using new screen
```

#### Step 3: Verify pubspec.yaml

Ensure `flutter_bloc` is in dependencies:
```yaml
dependencies:
  flutter_bloc: ^9.0.0  # or newer
  equatable: ^2.0.0    # for state comparison
```

### Phase 3: Testing (Verify Everything Works)

#### 1. Build the Project
```bash
flutter pub get
flutter clean
flutter pub get
flutter build
```

#### 2. Test Core Functionality
- [ ] Load home screen - data displays correctly
- [ ] Pull to refresh - refreshes data
- [ ] Delete spending - removes item and reloads
- [ ] Edit spending - updates list after edit
- [ ] AI analysis button - shows analysis dialog
- [ ] Error handling - shows error messages

#### 3. Test Edge Cases
- [ ] Empty spendings list
- [ ] Network error during load
- [ ] Rapid refresh clicks
- [ ] Delete while loading
- [ ] Screen rotation during load

### Phase 4: Optional Enhancements

#### A. Use BlocSelector for Performance
```dart
// Instead of BlocBuilder, use BlocSelector for specific properties
BlocSelector<HomeCubit, HomeState, List<Spending>>(
  selector: (state) {
    return state is HomeLoaded ? state.spendings : [];
  },
  builder: (context, spendings) {
    return ListView(
      children: spendings.map((s) => SpendingTile(s)).toList(),
    );
  },
)
```

#### B. Add Retry Logic
```dart
class RetryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.read<HomeCubit>().loadSpendings(),
      child: Text('Retry'),
    );
  }
}
```

#### C. Add Loading Indicator Overlay
```dart
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    final isLoading = state is HomeLoading || state is HomeDeletingSpending;
    return Stack(
      children: [
        HomeContent(),
        if (isLoading)
          Container(
            color: Colors.black26,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  },
)
```

## 🔄 Side-by-Side Comparison

### Before: StatefulWidget Approach

```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Spending> spendings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpendings();
  }

  Future<void> _loadSpendings() async {
    setState(() => isLoading = true);
    try {
      spendings = await SpendingService().getSpendings(userId!);
      setState(() => isLoading = false);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return LoadingWidget();
    return ListWidget(spendings);
  }
}
```

### After: Cubit Approach

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) return LoadingWidget();
        if (state is HomeLoaded) return ListWidget(state.spendings);
        if (state is HomeError) return ErrorWidget(state.message);
        return SizedBox.shrink();
      },
    );
  }
}

// Or more complex pattern:
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeDeleteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) return LoadingWidget();
          if (state is HomeLoaded) return ListWidget(state.spendings);
          return SizedBox.shrink();
        },
      ),
    );
  }
}
```

### Key Differences

| Aspect | Before | After |
|--------|--------|-------|
| State Management | `setState()` | Cubit emits states |
| Error Handling | In catch blocks | Error state classes |
| Loading State | Boolean flag | HomeLoading state |
| Data Lifecycle | In initState | In Cubit methods |
| Testing | Hard to mock | Easy to mock |
| Reusability | Single screen only | Multiple screens |

## 📝 Gradual Migration Path

If you want to keep the original `home_screen.dart` working while implementing Cubit:

### Option 1: Create New Screen (Recommended)
```
✓ Keep old home_screen.dart as backup
✓ Use new home_screen_with_cubit.dart  
✓ Easy to compare and debug
✓ Safe rollback if needed
```

### Option 2: Update Original Screen
```
1. Add BlocProvider wrapper
2. Replace setState() with BlocBuilder
3. Test thoroughly
4. Remove old state management code
5. Delete setState() calls
```

### Option 3: Hybrid Approach
```
1. Run both simultaneously in different routes
2. Gradually migrate features
3. Keep StatefulWidget for some screens
4. Use Cubit for others
```

## 🐛 Troubleshooting

### Issue: "BlocProvider not found"
**Solution**: Wrap screen with BlocProvider in router
```dart
BlocProvider(
  create: (context) => HomeCubit(),
  child: HomeScreen(),
)
```

### Issue: "State not rebuilding"
**Solution**: Check you're using BlocBuilder, not just BlocListener
```dart
// ❌ Wrong - Listener doesn't rebuild UI
BlocListener<HomeCubit, HomeState>(
  listener: (ctx, state) {},
  child: MyContent(),
)

// ✅ Right - Builder rebuilds
BlocBuilder<HomeCubit, HomeState>(
  builder: (ctx, state) => MyContent(),
)
```

### Issue: "Multiple instances of Cubit"
**Solution**: Provide Cubit once at router level, not in each widget
```dart
// ❌ Wrong - creates new Cubit each time
child: BlocProvider(
  create: (_) => HomeCubit(),
  child: HomeScreen(),
)

// ✅ Right - Cubit created once
BlocProvider(
  create: (context) => HomeCubit()..loadSpendings(),
  child: MyApp(),
)
```

### Issue: "Memory leak warnings"
**Solution**: Cubit handles cleanup automatically
- No manual subscription management needed
- Just ensure proper disposal in BlocProvider

### Issue: "State keeps emitting HomeLoading"
**Solution**: Check emit order in Cubit methods
```dart
// ✅ Correct pattern
emit(HomeLoading());
try {
  final data = await service.fetch();
  emit(HomeLoaded(data));
} catch (e) {
  emit(HomeError(e.toString()));
}

// ❌ Wrong - emits wrong order
try {
  emit(HomeLoading());
  final data = await service.fetch();
} catch (e) {
  emit(HomeError(e.toString()));
  emit(HomeLoading()); // Wrong!
}
```

## ✅ Pre-Migration Checklist

- [ ] All services are properly implemented
- [ ] Models (Spending, Category) are correct
- [ ] pubspec.yaml has flutter_bloc dependency
- [ ] No build errors in original project
- [ ] Understand BLoC/Cubit pattern
- [ ] Have test data available
- [ ] Backup original home_screen.dart
- [ ] Team members aware of changes

## ✅ Post-Migration Checklist

- [ ] App builds without errors
- [ ] Home screen displays correctly
- [ ] Pull to refresh works
- [ ] Delete operations work
- [ ] Error messages display properly
- [ ] Navigation to other screens works
- [ ] No console errors/warnings
- [ ] Memory usage is reasonable
- [ ] Performance is acceptable
- [ ] All edge cases handled

## 📚 Next Steps

1. **Short Term**
   - [ ] Implement Phase 1-3
   - [ ] Test on device
   - [ ] Deploy to beta
   - [ ] Get feedback

2. **Medium Term**
   - [ ] Optimize performance (Phase 4A)
   - [ ] Add retry logic (Phase 4B)
   - [ ] Enhance UX (Phase 4C)
   - [ ] Write unit tests

3. **Long Term**
   - [ ] Apply same pattern to other modules
   - [ ] Implement advanced Cubit patterns
   - [ ] Add Cubit persistence
   - [ ] Implement complex state management

## 🎓 Learning Resources

**Files to Study**:
1. Start: `home_state.dart` - Understand all states
2. Then: `home_cubit.dart` - Understand logic
3. Finally: `home_screen_with_cubit.dart` - See implementation

**Key Concepts**:
- States represent UI states (not data mutations)
- Cubit methods trigger state changes
- BlocBuilder listens to state changes
- BlocListener for side effects (snackbars, navigation)

**Documentation**:
- `Cubit/README.md` - Complete reference
- `CUBIT_ARCHITECTURE.md` - Visual diagrams
- This file - Migration steps
