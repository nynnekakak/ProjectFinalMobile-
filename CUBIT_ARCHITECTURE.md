# Home Module Cubit - Visual Architecture Guide

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      UI Layer (Widget)                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ HomeScreen / HomeScreenWithCubit                        │   │
│  │ • Displays based on HomeState                           │   │
│  │ • Triggers Cubit methods on user action                 │   │
│  │ • Handles navigation and UI events                      │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────┬──────────────────────────────────────────┘
                         │
                  BlocBuilder/Listener
                         │
┌────────────────────────▼──────────────────────────────────────────┐
│                  State Management Layer                           │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    HomeCubit                             │   │
│  │  ┌──────────────────────────────────────────────────┐    │   │
│  │  │ Public Methods:                                  │    │   │
│  │  │ • loadSpendings()                                │    │   │
│  │  │ • refreshSpendings()                             │    │   │
│  │  │ • deleteSpending(spendingId)                     │    │   │
│  │  │ • notifySpendingUpdated()                        │    │   │
│  │  │ • getAIAdvice()                                  │    │   │
│  │  │ • reset()                                        │    │   │
│  │  └──────────────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    HomeState                             │   │
│  │  • HomeInitial                 • HomeLoaded              │   │
│  │  • HomeLoading                 • HomeError               │   │
│  │  • HomeDeletingSpending        • HomeDeleteError         │   │
│  │  • HomeSpendingDeleted         • HomeSpendingUpdated     │   │
│  │  • HomeRefreshing              • HomeAILoading           │   │
│  │  • HomeAILoaded                • HomeAIError             │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────┬──────────────────────────────────────────┘
                         │
                  Cubit Methods Call
                         │
┌────────────────────────▼──────────────────────────────────────────┐
│                  Data/Service Layer                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Services:                                                │   │
│  │ • SpendingService - CRUD operations on spendings        │   │
│  │ • CategoryService - Get categories                      │   │
│  │ • UserPreferences - User ID management                  │   │
│  │ • GeminiService - AI analysis                           │   │
│  │ • BudgetService - Get budget data                       │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────┬──────────────────────────────────────────┘
                         │
                  API Calls / Database
                         │
                    Backend/Database
```

## State Transition Diagram

```
                        ┌─────────────────┐
                        │  HomeInitial    │
                        └────────┬────────┘
                                 │
                        (loadSpendings)
                                 │
                    ┌────────────▼────────────┐
                    │   HomeLoading           │
                    └────────────┬────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
              ┌─────▼────────┐        ┌──────▼──────┐
              │  HomeLoaded  │        │  HomeError  │
              └──┬──┬──┬──┬──┘        └─────────────┘
                 │  │  │  │
        ┌────────┘  │  │  └────────────────┐
        │           │  │                   │
   (delete)  (refresh)(update)      (getAdvice)
        │           │  │                   │
   ┌────▼──┐   ┌───▼──▼──┐          ┌─────▼──────┐
   │Delete │   │Refreshing│         │ AILoading  │
   │Spending   │          │         │            │
   └────┬──┘   └───┬──────┘         └─────┬──────┘
        │          │                       │
        ├──────────┘                       │
        │                            ┌─────▼──────┐
        │                            │ AILoaded   │
        │                            │ or Error   │
        │                            └────────────┘
        │
        ├─────── (Success)
        │
   ┌────▼──────┐
   │ HomeLoaded│ (cycle continues)
   └───────────┘
```

## Data Flow Example: Delete Spending

```
User UI                      Cubit                        Services
  │                           │                              │
  ├──────delete(id)──────────►│                              │
  │                           │                              │
  │◄──HomeDeletingSpending────│                              │
  │  (show loading/disable)   │                              │
  │                           ├─deleteSpending(id)──────────►│
  │                           │                              │
  │                           │                   (API call)
  │                           │                              │
  │                           │◄─── (success/error) ────────┤
  │                           │                              │
  │                           ├─loadSpendings()─────────────►│
  │                           │                              │
  │                           │         (loading fresh data) │
  │                           │                              │
  │                           │◄─── updated data ──────────┤
  │                           │                              │
  │◄──HomeLoaded──────────────│                              │
  │  (show new list)          │                              │
```

## Usage Pattern: Complete Flow

```
┌─────────────────────────────────────────────────────────┐
│                   App Startup                           │
└──────────────────────┬──────────────────────────────────┘
                       │
    ┌──────────────────▼──────────────────┐
    │ Create HomeCubit instance in        │
    │ BlocProvider                        │
    └──────────────────┬──────────────────┘
                       │
    ┌──────────────────▼──────────────────┐
    │ Call cubit.loadSpendings()          │
    │ (emits HomeLoading)                 │
    └──────────────────┬──────────────────┘
                       │
    ┌──────────────────▼──────────────────┐
    │ Fetch from SpendingService          │
    │ Fetch from CategoryService          │
    └──────────────────┬──────────────────┘
                       │
    ┌──────────────────▼──────────────────┐
    │ Emit HomeLoaded with data           │
    │ BlocBuilder rebuilds UI             │
    └──────────────────┬──────────────────┘
                       │
    ┌──────────────────▼──────────────────┐
    │ UI Displayed with spendings list    │
    │ User can interact with items        │
    └──────────────────┬──────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   (delete)       (refresh)      (view AI)
        │              │              │
        ▼              ▼              ▼
   ┌────────┐   ┌─────────┐   ┌──────────┐
   │Delete  │   │Refresh  │   │Get AI    │
   │item    │   │data     │   │Analysis  │
   └────┬───┘   └────┬────┘   └────┬─────┘
        │            │              │
        └─────────────┴──────────────┘
              │
         (Emit new state)
              │
         (UI updates)
```

## File Relationships

```
home_screen_with_cubit.dart
         │
         ├─ imports ──► home_cubit.dart
         │                    │
         │                    ├─ imports ──► home_state.dart
         │                    │
         │                    └─ injects:
         │                         • SpendingService
         │                         • CategoryService
         │                         • UserPreferences
         │                         • GeminiService
         │                         • BudgetService
         │
         └─ uses:
              • BlocProvider
              • BlocBuilder
              • BlocListener
              • context.read<HomeCubit>()
```

## Integration Points

```
App Router (route.dart)
    │
    ├─ BlocProvider (HomeCubit)
    │   │
    │   ├─ HomeScreen (original)
    │   │   └─ OR
    │   │
    │   └─ HomeScreenWithCubit (example)
    │       │
    │       ├─ BlocBuilder (listen to state)
    │       │
    │       ├─ BlocListener (handle errors)
    │       │
    │       └─ context.read<HomeCubit> (trigger actions)
    │
    ├─ Navigation Events
    │   ├─ Edit Spending ──► cubit.notifySpendingUpdated()
    │   └─ Add Spending ──► cubit.refreshSpendings()
    │
    └─ FAB Actions
        ├─ Chat button ──► navigate to AIChatPage
        └─ Analysis button ──► cubit.getAIAdvice()
```

## State Management Patterns

```
Pattern 1: Simple State Check
    BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return state is HomeLoading 
          ? Loading()
          : state is HomeLoaded
            ? Content(state.spendings)
            : Error();
      },
    )

Pattern 2: Listen to Specific States
    BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeDeleteError) {
          showSnackBar(state.message);
        }
      },
      child: HomeContent(),
    )

Pattern 3: Trigger Actions
    ElevatedButton(
      onPressed: () {
        context.read<HomeCubit>().deleteSpending(id);
      },
      child: Text('Delete'),
    )

Pattern 4: Multi-Listener
    BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeDeleteError) handleDelete();
        if (state is HomeAIError) handleAIError();
        if (state is HomeError) handleGeneralError();
      },
      child: HomeContent(),
    )
```

## Testing Strategy

```
Unit Tests:
├─ Test loadSpendings()
│  ├─ emits HomeLoading then HomeLoaded
│  └─ handles errors → HomeError
├─ Test deleteSpending()
│  ├─ emits HomeDeletingSpending
│  ├─ calls service
│  └─ reloads data
├─ Test getAIAdvice()
│  ├─ emits HomeAILoading
│  └─ handles errors → HomeAIError
└─ Test refresh operations

Widget Tests:
├─ Test HomeScreenWithCubit rendering
├─ Test error display
├─ Test loading states
└─ Test user interactions
```

## Performance Considerations

```
✓ BlocBuilder rebuilds only when HomeState changes
✓ Equatable ensures proper state comparison
✓ Cubit handles all async operations
✓ Error states prevent UI crashes
✓ Loading states prevent multiple calls
✓ State persistence reduces API calls
```

## Error Handling Flow

```
Operation Triggered
    │
    ▼
Try Block
    │
    ├─ Success ──► Emit Success State ──► UI Update
    │
    └─ Exception
        │
        ├─ Network Error ──► emit XError("Network error")
        ├─ Service Error ──► emit XError("Service error")
        └─ Parse Error ──► emit XError("Parse error")
        │
        ▼
    UI shows error message
    │
    └─ User can retry or dismiss
```
