# 💰 Expense Management App

An Android application developed using **Java** and **Android Studio** that helps users track their daily expenses, manage budgets, and analyze their financial habits.

---

## 📱 Features

- ✅ Add, edit, and delete expenses  
- 📊 View expenses by category and date  
- 💾 Offline data storage using **SQLite Database**  
- 📈 Summary of total spending  
- 🔍 Search and filter transactions  
- 🧭 Simple and user-friendly interface  

---

## 🧠 Project Overview

- Android development (Java)
- Database management (SQLite)
- UI/UX design
- MVC architecture patterns

---

## ⚙️ Tech Stack

| Component | Technology |
|------------|-------------|
| **Language** | Java |
| **IDE** | Android Studio |
| **Database** | SQLite |
| **Architecture** | MVC|
| **UI Design** | XML Layouts |
| **Version Control** | Git & GitHub |

---

## 🧩 SWOT Analysis

| **Category** | **Key Points** |
|---------------|----------------|
| **Strengths** | Stable platform (Java + Android), offline storage, good learning project |
| **Weaknesses** | No cloud sync, limited UI/UX, local-only data |
| **Opportunities** | Add Firebase, charts, or AI features |
| **Threats** | Strong competition, tech shift to Kotlin/Flutter |

---

## 🚀 Future Enhancements

- ☁️ Integrate **Firebase** for cloud sync and authentication  
- 🔐 Implement **data encryption** for security  
- 📈 Add **expense charts and statistics**  
- 💡 AI-based spending suggestions  
- 🌙 Dark mode for better UX  

---

## 🧑‍💻 Team Members

| Name | Role | Responsibility |
|------|------|----------------|
| [Trần Đăng Bảo Khương] | Team Leader / Developer | Overall project management, main coding |
| [Trần Ngọc Tiến] | Backend / Database | SQLite, CRUD operations |
| [Trần Bảo Minh] | UI/UX Designer | Layouts, icons, user interface |
| [Lê Trần Tuấn Hùng] | Tester / Documentation | Testing, report writing |

---

## 🏁 How to Run

1. Clone this repository:
   ```bash
   git clone https://github.com/nynnekakak/ProjectFinalMobile-.git

## Java 21 (developer setup)

This project has been updated to target Java 21 for the Android build (compileOptions and Kotlin `jvmTarget`). To build locally you should have a Java 21 JDK installed and configured.

Recommended steps (Windows / PowerShell):

1. Install a Java 21 JDK (Eclipse Adoptium / Temurin, Oracle, or other distribution).
2. Set JAVA_HOME for your user or session. Example (PowerShell session):

```powershell
$env:JAVA_HOME = 'C:\\Program Files\\Java\\jdk-21'
``` 

To persist for your user, run as admin or use PowerShell to set a User environment variable:

```powershell
[Environment]::SetEnvironmentVariable('JAVA_HOME','C:\\Program Files\\Java\\jdk-21','User')
``` 

3. (Optional) If you prefer a project-specific JDK, uncomment and set `org.gradle.java.home` in `android/gradle.properties` to the absolute JDK path.

Notes:
- If your Gradle or Kotlin plugin versions do not support Java 21 bytecode target, you may need to upgrade Gradle/AGP/Kotlin first or use a supported compatibility level.
- After installing Java 21 and setting `JAVA_HOME`, run the Android build from the project root using the Gradle wrapper:

```powershell
.\android\gradlew.bat assembleDebug
```

If you run into build errors after switching to Java 21, paste the build output here and I can help troubleshoot.
