# health_connector_annotation

Annotations for `health_connector` packages.

## Overview

This package provides annotations used throughout the `health_connector` ecosystem to mark API
versions and platform support.

## Annotations

### `@Since`

Marks the version where an API was added. Uses semantic versioning.

**Example:**
```dart
@Since('0.1.0')
class MyClass { ... }
```

### `@SupportedHealthPlatforms`

Marks APIs that are supported only on specific health platforms. When called on an unsupported
platform, an error should be thrown.

**Example:**
```dart
@SupportedHealthPlatforms([HealthPlatform.healthConnect])
Future<void> androidOnlyMethod() async { ... }
```

## Usage

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  health_connector_annotation:
    path: ../health_connector_annotation
```

Then import the annotations:

```dart
import 'package:health_connector_annotation/health_connector_annotation.dart';
```
