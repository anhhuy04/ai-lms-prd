# Architecture Patterns: LMS System Structure

**Project:** AI LMS PRD (Learning Management System)
**Researched:** 2026-03-05
**Domain:** Mobile LMS Architecture
**Confidence:** HIGH

---

## Executive Summary

LMS (Learning Management System) architecture follows a well-established pattern across the industry. The core structure centers on **User-Role-Course-Content-Assessment** relationships, with specific modules for workflow management, analytics, and communication. This project follows Clean Architecture with Riverpod, which aligns well with standard LMS patterns.

**Key Finding:** The existing codebase architecture is well-suited for LMS functionality. The domain entities (Class, Assignment, Group, Profile, AssignmentDistribution) map directly to standard LMS components.

---

## Standard LMS Architecture Components

### 1. Core Domain Model

Every LMS revolves around these fundamental entities:

```
┌─────────────────┐     ┌──────────────────┐
│      User       │────▶│      Role        │
│  (authentication│     │ (student/teacher)│
│   profile)      │     └──────────────────┘
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────────┐
│    Class/Course │────▶│    Group         │
│  (organization) │     │ (section/team)   │
└────────┬────────┘     └──────────────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────────┐
│   Assignment   │────▶│   Submission    │
│   (assessment) │     │   (response)    │
└────────┬────────┘     └──────────────────┘
         │
         ▼
┌─────────────────┐
│     Grade       │
│   (feedback)   │
└─────────────────┘
```

### 2. Entity Relationship Mapping

| Standard LMS Entity | This Project Entity | Status |
|---------------------|---------------------|--------|
| User | `Profile` | Implemented |
| Role | `user_role` enum | Implemented |
| Course | `Class` | Implemented |
| Section/Group | `Group` | Implemented |
| Assignment | `Assignment` | Implemented |
| Question | `Question` / `AssignmentQuestion` | Implemented |
| Submission | `Submission` | Pending |
| Grade | `Grade` | Pending |
| Enrollment | `ClassMember` | Implemented |

---

## Recommended Architecture

### Layer Structure

The project already implements Clean Architecture correctly:

```
lib/
├── core/                    # Cross-cutting concerns
│   ├── routes/             # GoRouter + RBAC
│   ├── services/           # Error reporting, Supabase
│   ├── theme/             # Design system
│   └── utils/             # Validation, logging
│
├── domain/                  # Business logic (pure Dart)
│   ├── entities/           # Business models (Freezed)
│   ├── repositories/      # Interface definitions
│   └── usecases/          # Business rules
│
├── data/                    # Data access
│   ├── datasources/       # Supabase queries
│   ├── repositories/      # Interface implementations
│   └── mock/              # Mock data for testing
│
└── presentation/            # UI layer
    ├── views/              # Screens
    ├── providers/          # Riverpod state
    ├── widgets/            # Reusable UI
    └── mappers/            # DTO to Entity
```

### Component Responsibilities

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `ProfileProvider` | User auth state, profile data | Supabase Auth |
| `ClassRepository` | Class CRUD operations | ClassDataSource |
| `AssignmentRepository` | Assignment lifecycle | AssignmentDataSource |
| `GroupRepository` | Group management | GroupDataSource |
| `DistributionService` | Assignment distribution logic | AssignmentDistribution entity |

---

## LMS-Specific Architecture Patterns

### 1. Assignment Lifecycle Pattern

LMS systems follow a consistent assignment workflow:

```
Teacher creates assignment
         │
         ▼
  Distribution (class/group/individual)
         │
         ▼
  Student receives notification
         │
         ▼
  Student completes in workspace
         │
         ▼
  Submission (with auto-save)
         │
         ▼
  Teacher grades / AI grades
         │
         ▼
  Student receives feedback
```

**Project Status:** Distribution is implemented. Workspace and submission are pending.

### 2. Role-Based Access Control (RBAC)

Standard LMS roles and permissions:

| Role | Permissions |
|------|-------------|
| **Admin** | Full system access, user management |
| **Teacher** | Create/edit classes, assignments, grade |
| **Student** | View enrolled classes, submit assignments |

The project implements RBAC via GoRouter redirect guards in `route_guards.dart`.

### 3. Distribution Tree Pattern

For complex assignment distribution, a tree structure works well:

```
AssignmentDistribution
├── type: "all" | "groups" | "individuals"
├── targetClassId: String
├── selectedGroups: List<String>  (optional)
├── selectedStudents: List<String> (optional)
└── excludeStudents: List<String> (optional)
```

The project implements this via `RecipientTreeNode` entity - a sophisticated approach that supports hierarchical selection.

---

## Scalability Considerations

### At Different User Scales

| Concern | 100 Users | 10K Users | 1M Users |
|---------|-----------|-----------|----------|
| **Database** | Single Supabase instance | Connection pooling | Read replicas |
| **State** | In-memory providers | Optimistic updates | Paginated queries |
| **Files** | Supabase Storage | CDN integration | Object storage |
| **Search** | Simple queries | Full-text search | Elasticsearch |

### Project Recommendations

**Current scale (100-10K users):**
- Supabase handles well with standard configuration
- Riverpod state management sufficient
- No pagination needed yet

**Future (10K+ users):**
- Implement cursor-based pagination for lists
- Add Redis caching layer for frequently accessed data
- Consider Edge Functions for complex computations

---

## Anti-Patterns to Avoid

### 1. Monolithic Providers

**Bad:** Single provider managing multiple unrelated concerns

```dart
// AVOID THIS
class LMSProvider extends StateNotifier<LMSState> {
  // Manages auth, classes, assignments, grades...
}
```

**Better:** Separate providers per domain

```dart
// RECOMMENDED (already done)
class AuthNotifier extends _$AuthNotifier { ... }
class ClassListNotifier extends _$ClassListNotifier { ... }
class AssignmentNotifier extends _$AssignmentNotifier { ... }
```

### 2. Direct Supabase Calls in UI

**Bad:** UI component directly calls Supabase

```dart
// AVOID
ElevatedButton(
  onPressed: () async {
    await Supabase.instance.client.from('classes').insert(...);
  },
)
```

**Better:** Repository pattern (already implemented)

```dart
// RECOMMENDED
ElevatedButton(
  onPressed: () {
    ref.read(classRepositoryProvider).createClass(params);
  },
)
```

### 3. Ignoring Offline Scenarios

**Consider for v2:** Implement offline-first with Drift local database for:
- Viewing cached assignments
- Queueing submissions when offline
- Syncing when connectivity returns

---

## Extension Points for AI Features

The architecture supports future AI integration:

### 1. AI Grading Pipeline

```
Submission received
       │
       ▼
┌─────────────────┐
│  AI Service     │ (future edge function)
│  - Analyze      │
│  - Score        │
│  - Feedback     │
└─────────────────┘
       │
       ▼
┌─────────────────┐
│  Grade Entity   │ (pending)
│  - score        │
│  - feedback     │
│  - confidence   │
└─────────────────┘
```

### 2. Recommendation Engine

Future analytics layer would integrate:

```dart
// Future extension
class RecommendationService {
  Future<List<Assignment>> suggestNext(Student student);
  Future<List<Student>> identifyAtRisk(Teacher teacher);
}
```

---

## Data Flow Diagrams

### Standard Data Flow

```
User Action
     │
     ▼
┌─────────────────────────────────────┐
│         Presentation Layer           │
│  ┌─────────────┐  ┌──────────────┐  │
│  │   Screen    │──│  Provider    │  │
│  └─────────────┘  └──────┬───────┘  │
└──────────────────────────┼───────────┘
                          │ ref.read()
                          ▼
┌─────────────────────────────────────┐
│          Domain Layer               │
│  ┌─────────────────────────────┐   │
│  │    Repository Interface     │   │
│  └──────────────┬──────────────┘   │
└─────────────────┼──────────────────┘
                  │ implements
                  ▼
┌─────────────────────────────────────┐
│           Data Layer                │
│  ┌─────────────┐  ┌──────────────┐  │
│  │ Repository  │──│  DataSource  │  │
│  └─────────────┘  └──────┬───────┘  │
└──────────────────────────┼───────────┘
                          │ query
                          ▼
┌─────────────────────────────────────┐
│         Supabase Backend            │
│  ┌─────────────┐  ┌──────────────┐  │
│  │  Database   │──│   Storage    │  │
│  └─────────────┘  └──────────────┘  │
└─────────────────────────────────────┘
```

---

## Architecture Recommendations

### Current Assessment: GOOD

The existing architecture is well-suited for an LMS:

| Aspect | Status | Notes |
|--------|--------|-------|
| Clean layers | ✅ Good | Domain/Data/Presentation separation |
| Repository pattern | ✅ Good | Interface in domain, impl in data |
| State management | ✅ Good | Riverpod with AsyncNotifier |
| Routing + RBAC | ✅ Good | GoRouter with guards |
| Entity modeling | ✅ Good | Freezed models for all entities |

### Recommended Additions for Completeness

| Addition | Purpose | Complexity |
|----------|---------|------------|
| Submission entity | Complete assignment workflow | Medium |
| Grade entity | Feedback and scoring | Medium |
| Analytics layer | Performance dashboards | High |
| Offline support | Better UX | Medium |

---

## Conclusion

The project architecture aligns well with standard LMS patterns. The Clean Architecture with Riverpod provides a solid foundation. Key strengths:

1. **Proper separation of concerns** - Domain layer is pure Dart
2. **Repository pattern** - Abstracted data access
3. **RBAC via routing** - Security enforced at navigation level
4. **Entity modeling** - Comprehensive Freezed models

The main gap is completing the assignment lifecycle (Submission, Grade entities) to enable the full teacher-student workflow.

---

## Sources

- Clean Architecture principles (Martin Fowler)
- Riverpod state management patterns (riverpod.dev)
- Standard LMS entity relationships (Canvas, Moodle, Google Classroom patterns)
- Project codebase analysis

**Confidence:** HIGH - Based on existing codebase analysis combined with standard LMS patterns.
