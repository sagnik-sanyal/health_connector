# health_connector_annotation

[![pub package](https://img.shields.io/pub/v/health_connector_annotation.svg)](https://pub.dev/packages/health_connector_annotation)
[![pub points](https://img.shields.io/pub/points/health_connector_annotation?color=2E8B57&label=pub%20points)](https://pub.dev/packages/health_connector_annotation/score)

Annotations for `health_connector` packages.

---

## 📖 Overview

`health_connector_annotation` provides annotations used throughout the `health_connector` ecosystem
to mark API versions and platform support. These annotations help document API availability and
platform-specific features across the codebase.

### 🔧 Features

- **Version Tracking**: Mark when APIs were introduced using semantic versioning
- **Platform Support**: Declare platform-specific API availability
- **Documentation**: Self-documenting code with clear API metadata

---

## 🎯 Requirements

- Dart >=3.9.2

---

## 🚀 Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  health_connector_annotation: ^0.1.0
```

---

## 📖 Usage

### Import Package

```dart
import 'package:health_connector_annotation/health_connector_annotation.dart';
```

### Annotations

#### `@Since`

Marks the version where an API was added. Uses semantic versioning.

```dart
@Since('0.1.0')
class MyClass { ... }

@Since('0.2.0')
void myMethod() { ... }
```

#### `@SupportedHealthPlatforms`

Marks APIs that are supported only on specific health platforms. When called on an unsupported
platform, an error should be thrown.

```dart
@SupportedHealthPlatforms([HealthPlatform.healthConnect])
Future<void> androidOnlyMethod() async { ... }

@SupportedHealthPlatforms([HealthPlatform.appleHealth])
Future<void> iosOnlyMethod() async { ... }

@SupportedHealthPlatforms([HealthPlatform.healthConnect, HealthPlatform.appleHealth])
Future<void> crossPlatformMethod() async { ... }
```

---

## 🤝 Contributing

To report issues or request features, please visit
our [GitHub Issues](https://github.com/fam-tung-lam/health_connector/issues).
