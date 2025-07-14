# Squash Training App - Architecture Documentation

## 🏗️ Architecture Overview

### Current Implementation (Native Android)
The app is built as a native Android application using Java, with a traditional Activity-based architecture and SQLite for data persistence.

### Planned Architecture (Mascot-Based UI)
Future implementation will feature an innovative drag-based navigation system with an animated mascot character and AI voice integration.

## 📁 Project Structure

### Current Directory Layout
```
SquashTrainingApp/
├── android/
│   ├── app/
│   │   └── src/main/
│   │       ├── java/com/squashtrainingapp/
│   │       │   ├── MainActivity.java
│   │       │   ├── ChecklistActivity.java
│   │       │   ├── RecordActivity.java
│   │       │   ├── ProfileActivity.java
│   │       │   ├── CoachActivity.java
│   │       │   ├── HistoryActivity.java
│   │       │   ├── DatabaseHelper.java
│   │       │   └── models/
│   │       │       ├── Exercise.java
│   │       │       └── Record.java
│   │       └── res/
│   │           ├── layout/
│   │           ├── values/
│   │           └── drawable/
│   └── gradle/
├── scripts/
│   ├── production/
│   └── utility/
└── docs/
```

### Planned Modular Structure
```
com.squashtrainingapp/
├── activities/          # Screen activities
├── mascot/             # Mascot system
│   ├── MascotView.java
│   ├── DragHandler.java
│   ├── AnimationController.java
│   └── ZoneManager.java
├── ai/                 # AI and voice
│   ├── VoiceRecognitionManager.java
│   ├── AIChatbotActivity.java
│   └── AIResponseEngine.java
├── database/           # Data persistence
│   ├── DatabaseHelper.java
│   ├── migrations/
│   └── repositories/
├── models/             # Data models
├── ui/
│   ├── adapters/
│   ├── animations/
│   └── widgets/
└── utils/              # Utilities
```

## 🎨 UI Architecture

### Current Navigation Model
```
MainActivity (Bottom Navigation)
├── HomeFragment
├── ChecklistActivity
├── RecordActivity
├── ProfileActivity
└── CoachActivity
```

### Planned Mascot Navigation
```
MascotHomeActivity
├── MascotView (Center)
├── DragZones
│   ├── ProfileZone (Top)
│   ├── ChecklistZone (Top-Left)
│   ├── CoachZone (Top-Right)
│   ├── RecordZone (Bottom-Left)
│   ├── HistoryZone (Bottom-Right)
│   └── SettingsZone (Bottom)
└── VoiceOverlay (On Long Press)
```

## 💾 Data Architecture

### Database Schema

#### Tables
1. **exercises**
   ```sql
   CREATE TABLE exercises (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       name TEXT NOT NULL,
       category TEXT,
       is_completed INTEGER DEFAULT 0
   );
   ```

2. **records**
   ```sql
   CREATE TABLE records (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       exercise_name TEXT,
       sets INTEGER,
       reps INTEGER,
       duration INTEGER,
       intensity INTEGER,
       condition INTEGER,
       fatigue INTEGER,
       memo TEXT,
       created_at DATETIME DEFAULT CURRENT_TIMESTAMP
   );
   ```

3. **user**
   ```sql
   CREATE TABLE user (
       id INTEGER PRIMARY KEY,
       name TEXT,
       level INTEGER,
       xp INTEGER,
       total_sessions INTEGER,
       total_calories INTEGER,
       total_hours REAL,
       current_streak INTEGER
   );
   ```

### Data Flow
```
UI Layer (Activities)
    ↓↑
DatabaseHelper (Singleton)
    ↓↑
SQLite Database
```

## 🔌 Component Architecture

### Current Components

#### MainActivity
- **Purpose**: Main navigation hub
- **Features**: Bottom navigation, fragment management
- **Dependencies**: All activity screens

#### DatabaseHelper
- **Pattern**: Singleton
- **Features**: CRUD operations, data migrations
- **Thread Safety**: Synchronized methods

#### Activity Lifecycle
```
onCreate() → Initialize UI
onResume() → Refresh data
onPause() → Save state
onDestroy() → Clean resources
```

### Planned Mascot Components

#### MascotView
```java
public class MascotView extends View {
    - Character rendering
    - Idle animations
    - Drag detection
    - Expression changes
}
```

#### DragHandler
```java
public class DragHandler {
    - Gesture detection
    - Zone calculations
    - Drag physics
    - Snap-back animation
}
```

#### VoiceRecognitionManager
```java
public class VoiceRecognitionManager {
    - Long press detection
    - Speech-to-text
    - Command parsing
    - Action dispatch
}
```

## 🎯 Design Patterns

### Current Patterns
1. **Singleton**: DatabaseHelper
2. **MVC**: Activity-Layout-Model
3. **Observer**: Click listeners
4. **Adapter**: RecyclerView adapters

### Planned Patterns
1. **Command**: Voice command processing
2. **State**: Mascot animation states
3. **Strategy**: Navigation strategies
4. **Factory**: Screen creation

## 🔄 State Management

### Current State
- **Activity State**: Bundle save/restore
- **Database State**: SQLite persistence
- **UI State**: View state preservation

### Planned State Management
```
StateManager
├── NavigationState
├── MascotState
├── VoiceState
└── UserState
```

## 🎨 Theme Architecture

### Color System
```xml
<!-- colors.xml -->
<color name="dark_background">#0D0D0D</color>
<color name="dark_surface">#1A1A1A</color>
<color name="volt_green">#C9FF00</color>
<color name="text_primary">#FFFFFF</color>
<color name="text_secondary">#B3B3B3</color>
```

### Style Hierarchy
```
AppTheme (Dark)
├── ActivityTheme
├── CardTheme
├── ButtonTheme
└── TextTheme
```

## 🚀 Performance Architecture

### Current Optimizations
- Database queries on background thread
- View recycling in lists
- Lazy loading of resources
- Memory-efficient image handling

### Planned Optimizations
- Mascot rendering on GPU
- Voice processing on separate thread
- Animation frame caching
- Predictive zone loading

## 🔒 Security Architecture

### Current Security
- Local data only (no network)
- SQL injection prevention
- Input validation

### Planned Security
- API key encryption
- Voice data privacy
- Secure command validation
- Permission management

## 📡 Integration Points

### Current Integrations
- SQLite database
- Android system services
- File system for icons

### Planned Integrations
- OpenAI API (coaching)
- Google Speech API (voice)
- YouTube API (tutorials)
- Analytics services

## 🧪 Testing Architecture

### Test Structure
```
tests/
├── unit/
│   ├── DatabaseTests
│   ├── ModelTests
│   └── UtilTests
├── integration/
│   ├── ActivityTests
│   └── NavigationTests
└── ui/
    ├── ScreenTests
    └── InteractionTests
```

### Automated Testing
- Unit tests for business logic
- Integration tests for database
- UI tests for user flows
- Performance benchmarks

## 📊 Build Architecture

### Build Variants
```groovy
buildTypes {
    debug {
        debuggable true
        minifyEnabled false
    }
    release {
        minifyEnabled true
        proguardFiles 'proguard-rules.pro'
    }
}
```

### Dependency Management
- Gradle for build automation
- Maven Central for libraries
- Local libs for custom components

## 🔮 Future Architecture Considerations

### Scalability
- Modular component design
- Lazy loading strategies
- Efficient data caching
- Background processing

### Maintainability
- Clear separation of concerns
- Comprehensive documentation
- Consistent coding standards
- Automated testing

### Extensibility
- Plugin architecture for features
- Theme customization system
- Configurable navigation
- API abstraction layer

---

**Last Updated**: 2025-07-14
**Architecture Version**: 2.0 (Planned)
**Current Implementation**: 1.0 (Native Android)