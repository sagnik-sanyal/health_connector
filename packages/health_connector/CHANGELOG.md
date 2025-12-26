## 2.0.0

> **Note**: This release has breaking changes.
>
> See the [Migration Guide](../../doc/guides/migration_guides/migration-guide-v1.x.x-to-v2.x.x.md) for detailed instructions on upgrading from v1.x.x to v2.0.0.

- **BREAKING** **FEAT**: Introduce `TimeDuration` unit and replace `Number` with it for sleep data types. ([459798dd](https://github.com/fam-tung-lam/health_connector/commit/459798dd25d3ff014b824f4d9d7f79aa27ac0f53))
- **BREAKING** **FEAT**: Introduce `HealthConnector interface with default`HealthConnectorImpl` implementation. ([5bbe4f8c](https://github.com/fam-tung-lam/health_connector/commit/5bbe4f8c51bf84155c641df4086b07cda2b09021))
- **BREAKING** **FEAT**: Unify deletion API with polymorphic request pattern. ([f67cf5ae](https://github.com/fam-tung-lam/health_connector/commit/f67cf5ae0cda0a513c37b844aa44e8815fde0996))
- **BREAKING** **REFACTOR**: Remove support for "delete-then-create" logic for iOS HealthKit. ([e79b1772](https://github.com/fam-tung-lam/health_connector/commit/e79b177270ebe925b20b0309a5a31e9d44e648b5))
- **BREAKING** **REFACTOR**: Simplify `aggregate` and `readRecord` APIs by removing request/response wrappers. ([31673d12](https://github.com/fam-tung-lam/health_connector/commit/31673d12b945e017a9a2b34bfef539cdec4fea23))
- **BREAKING** **REFACTOR**: Remove support for individual nutrient data types on Android Health Connect. ([a9f7c9e4](https://github.com/fam-tung-lam/health_connector/commit/a9f7c9e47f9c0390ba4dc4eb3d6d7ed01e5772f1))
- **BREAKING** **REFACTOR**: Standardize and synchronize error codes across platforms. ([121df395](https://github.com/fam-tung-lam/health_connector/commit/121df395899bf3ba919a4d51a3c29527c01ace0d))
- **FEAT**: Implement atomic batch writes on iOS HealthKit and Android Health Connect. ([9dbbd181](https://github.com/fam-tung-lam/health_connector/commit/9dbbd181792039140a704ebe404a4d03d6191f95)) ([c1c8c3df](https://github.com/fam-tung-lam/health_connector/commit/c1c8c3dfe32a8624e4249b2cc84f8b7e499e936c))
- **FEAT**: Add support for exercise session data type and record. ([d36b528c](https://github.com/fam-tung-lam/health_connector/commit/d36b528c7f6ec5b7ae3a33e0e8137c557c870e46))
- **FEAT**: Add `updateRecords` API for batch record updates. ([04e5463e](https://github.com/fam-tung-lam/health_connector/commit/04e5463e96552c04c331b8025d6e5d831e28953e))
- **FEAT**: Implement `HealthConnectorInfiPListService` for validating the application's Info.plist configuration. ([7846492f](https://github.com/fam-tung-lam/health_connector/commit/7846492fd7ad77c1da66ed3f9a08d1bf6361a59d))
- **FEAT**: Add full support for distance records and data types. ([84e27c08](https://github.com/fam-tung-lam/health_connector/commit/84e27c0821bad311aaf7bf6f1d2b577b50365700))
- **FEAT**: Add full support for speed records and data types. ([f07714db](https://github.com/fam-tung-lam/health_connector/commit/f07714db7b9302eea65e19aabab9e036bafbcab6))
- **PERF**: Use HealthKit batch delete API instead of for-loop deletion. ([b4159af1](https://github.com/fam-tung-lam/health_connector/commit/b4159af1ff015cf9890feab2418a22bc1e034b99))
- **FIX**: Preserve record IDs in Health Connect update operations. ([298f98f0](https://github.com/fam-tung-lam/health_connector/commit/298f98f09f047bfe4f6db06fe161ae25ddba61ca))
- **FIX**: Implement missing health record objects deletion for correlation sample types. ([655d865e](https://github.com/fam-tung-lam/health_connector/commit/655d865e8dce71c69280fefce476335164b04b4f))
- **FIX**: Fix IDs validation in `DeleteRecordsByIdsRequest` factory constructor. ([d37817e5](https://github.com/fam-tung-lam/health_connector/commit/d37817e584163d7c140fef4868f54edda9c1528e))

## 1.4.0

- **FEAT**: Add blood glucose data type. ([eed289b4](https://github.com/fam-tung-lam/health_connector/commit/eed289b40c6d079b0997f16ad7f75881f84ec196)) ([c018d008](https://github.com/fam-tung-lam/health_connector/commit/c018d008bbf012bfa1c609025bd41d920dd4b53a)) ([18803d0f](https://github.com/fam-tung-lam/health_connector/commit/18803d0f6b182595f1dc1d747cdb8760a7423f1f))

## 1.3.0

- **DEPS**: Update a dependency to the latest release.
- **FEAT**: Add VO2Max data type. ([1f885539](https://github.com/fam-tung-lam/health_connector/commit/1f8855396649275b9bc16e62dbbd2b66ef6745e0)) ([2a61940f](https://github.com/fam-tung-lam/health_connector/commit/2a61940f010c7f8e7bfca438c5f969ed178193ad)) ([3e51085a](https://github.com/fam-tung-lam/health_connector/commit/3e51085a1602e50febddde9f501002ec6867d649))
- **FEAT**: Add respiratory rate data type. ([75ba9138](https://github.com/fam-tung-lam/health_connector/commit/75ba913811f39879cb81c6eb121e1cf789ef5311)) ([b6081fa6](https://github.com/fam-tung-lam/health_connector/commit/b6081fa6f99772e0b64b7ca272acf822854cc766)) ([a67dabba](https://github.com/fam-tung-lam/health_connector/commit/a67dabba093393d4064f60f99769edb71d584236))
- **FEAT**: Add oxygen saturation data type. ([8c0876b0](https://github.com/fam-tung-lam/health_connector/commit/8c0876b04480b311a3b8d516a2977a11feaff6b8)) ([51022aa1](https://github.com/fam-tung-lam/health_connector/commit/51022aa15d7d2d1c91b3512517f1edbbb0af9473)) ([b8928fc7](https://github.com/fam-tung-lam/health_connector/commit/b8928fc785128757bd57d9b07c7ce6c0d436912f))
- **FEAT**: Add resting heart rate data type. ([7bb5bbea](https://github.com/fam-tung-lam/health_connector/commit/7bb5bbea8b385d0915ec34257964e53f1d3fc4b5)) ([17bbf3b1](https://github.com/fam-tung-lam/health_connector/commit/17bbf3b142a15b17bf4ffb5a51ada4ca5b3fef0f)) ([4972b907](https://github.com/fam-tung-lam/health_connector/commit/4972b9078563225fee0aa7b8506102d9955867e4))

## 1.2.2

- **DEPS**: Update `health_connector_lint` to the latest version.

## 1.2.1

- **FIX**: Map blood pressure types to corresponding HealthKit types. ([ff057529](https://github.com/fam-tung-lam/health_connector/commit/ff057529d7397b80196b6063036526842973ff8d))

## 1.2.0

- **FEAT**: Add support for blood pressure data types.

## 1.1.0

- **FEAT**: Add support for nutrient and nutrition records and data types. ([77e3a8d0](https://github.com/fam-tung-lam/health_connector/commit/77e3a8d00e6afaf43f56a24eb7c55621d82f63ad))

## 1.0.0

- **FEAT**: Implement `HealthConnector` facade providing unified API across platforms.
- **FEAT**: Add support for common health data types.
