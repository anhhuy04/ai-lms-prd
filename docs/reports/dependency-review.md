# Dependency Review Report

**Generated:** 2026-01-21  
**Purpose:** Review unused dependencies and decide whether to keep or remove them

## Summary

After analyzing the codebase, the following dependencies were reviewed:

### 1. Drift (Local Database) - **KEEP**

**Status:** Added to `pubspec.yaml` but not yet used in code

**Decision:** **KEEP** for future offline-first capabilities

**Reasoning:**
- According to `activeContext.md`, Drift is planned for local database
- Offline-first capability will be needed for better user experience
- `drift_dev` is commented out due to conflict with `retrofit_generator`, but this can be resolved when needed
- No immediate need to remove as it doesn't cause issues

**Action:** Document in `techContext.md` that Drift will be implemented when offline-first features are needed

### 2. Retrofit + Dio (Networking) - **KEEP**

**Status:** Added to `pubspec.yaml` but not yet used in code

**Decision:** **KEEP** for future external API calls

**Reasoning:**
- According to `activeContext.md`, Retrofit is planned for external API calls
- Currently only using Supabase client, but external APIs may be needed later
- `retrofit_generator` has version conflict with `drift_dev`, but this is manageable
- No immediate need to remove as it doesn't cause issues

**Action:** Document in `techContext.md` that Retrofit/Dio will be used when external API integration is needed

### 3. Freezed - **KEEP (ACTIVELY USED)**

**Status:** **ACTIVELY USED** in domain entities

**Decision:** **KEEP** - Already integrated and working

**Usage:**
- `lib/domain/entities/class.dart` - Uses `@freezed` annotation
- `lib/domain/entities/profile.dart` - Uses `@freezed` annotation
- `lib/domain/entities/class_member.dart` - Uses `@freezed` annotation
- `lib/domain/entities/group.dart` - Uses `@freezed` annotation
- `lib/domain/entities/create_class_params.dart` - Uses `@freezed` annotation
- `lib/domain/entities/update_class_params.dart` - Uses `@freezed` annotation
- And more...

**Action:** Continue using Freezed for all domain entities. Consider migrating remaining plain classes to Freezed when convenient.

## Recommendations

1. **Keep Drift and Retrofit** - They are planned for future features and don't cause issues
2. **Continue using Freezed** - Already integrated and working well
3. **Document future use cases** - Update `techContext.md` with clear documentation about when these dependencies will be used
4. **Monitor dependency conflicts** - The `drift_dev` vs `retrofit_generator` conflict should be resolved when implementing these features

## Next Steps

- [ ] Update `techContext.md` with dependency status and future plans
- [ ] Monitor dependency updates for conflict resolution
- [ ] Plan implementation timeline for Drift (offline-first) and Retrofit (external APIs)
