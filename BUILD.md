# SoundScribe Windows Build Guide

## Prerequisites

1. **Install Flutter SDK**
   - Download from: https://flutter.dev/docs/get-started/install/windows
   - Extract to: `C:\flutter`
   - Add to PATH: `C:\flutter\bin`

2. **Enable Desktop Support**
   ```bash
   flutter config --enable-windows-desktop
   ```

3. **Install Visual Studio Build Tools**
   - Download Visual Studio 2022 with C++ desktop development workload

## Build Commands

### Development Build
```bash
flutter build windows
```

### Release Build
```bash
flutter build windows --release
```

### Output Location
```
build\windows\x64\runner\Release\
```

## Troubleshooting

### Error: Missing Visual Studio
- Install Visual Studio 2022 with "Desktop development with C++"

### Error: Flutter not recognized
- Restart terminal after installing Flutter
- Run: `flutter doctor`

### Error: Permission denied
- Run terminal as Administrator
