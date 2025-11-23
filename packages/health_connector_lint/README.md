# health_connector_lint

Shared lint rules for all health_connector packages.

## Usage

Add to your package's `pubspec.yaml`:

```yaml
dev_dependencies:
  health_connector_lint: ^0.1.1
```

Include in your `analysis_options.yaml`:

```yaml
include: package:health_connector_lint/analysis_options.yaml
```

## Customization

You can override specific rules in your package's `analysis_options.yaml`:

```yaml
include: package:health_connector_lint/analysis_options.yaml

linter:
  rules:
    # Disable a rule from health_connector_lint
    public_member_api_docs: false
```
