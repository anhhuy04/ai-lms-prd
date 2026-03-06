# Tech Vision Template

> Template cho tech vision trong memory-bank/tech-vision/

---

```markdown
# Tech Vision: [Feature Name]

| Metadata | Value |
|----------|-------|
| Date | [YYYY-MM-DD] |
| Status | [Draft/Approved/In Progress/Completed] |
| Proposed By | [User/AI] |
| Version | 1.0.0 |

---

## 1. Executive Summary

### 🎯 Goal
[Một đoạn ngắn 1-2 câu mô tả mục tiêu của feature]

### 📋 Description
[Mô tả chi tiết hơn về feature]

### 👥 Target Users
- [User group 1]
- [User group 2]

---

## 2. Problem Statement

### Current Issues
- [Issue 1]: [Mô tả]
- [Issue 2]: [Mô tả]

### Opportunities
- [Opportunity 1]: [Mô tả]
- [Opportunity 2]: [Mô tả]

---

## 3. Proposed Architecture

### 3.1 Technology Stack

| Component | Choice | Reason | Alternative |
|-----------|--------|--------|-------------|
| Frontend | [Flutter] | [reasons] | [Web/React Native] |
| State | [Riverpod] | [reasons] | [Provider/Bloc] |
| Backend | [Supabase] | [reasons] | [Firebase/Custom] |
| Database | [PostgreSQL] | [reasons] | [MongoDB/Firebase] |
| Real-time | [Supabase Realtime] | [reasons] | [WebSocket] |
| Storage | [Supabase Storage] | [reasons] | [S3/Firebase Storage] |

### 3.2 Architecture Layers

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Screens, Widgets, Providers)          │
├─────────────────────────────────────────┤
│            Domain Layer                 │
│  (Entities, Repository Interfaces)      │
├─────────────────────────────────────────┤
│             Data Layer                  │
│  (Repository Impl, DataSources)         │
├─────────────────────────────────────────┤
│           External Services             │
│  (Supabase, Storage, Edge Functions)    │
└─────────────────────────────────────────┘
```

### 3.3 Data Flow

```
[User Action]
    ↓
[Provider/Notifier]
    ↓
[Repository Interface]
    ↓
[Repository Implementation]
    ↓
[DataSource]
    ↓
[Supabase/API]
```

---

## 4. Features & Scope

### In Scope
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

### Out of Scope
- [Feature A]: [Reason]
- [Feature B]: [Reason]

---

## 5. Database Design

### 5.1 Tables Required

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| [table_1] | [purpose] | id, [columns] |
| [table_2] | [purpose] | id, [columns] |

### 5.2 Relationships

```
[Table A] 1───N [Table B]
[Table B] N───1 [Table C]
```

### 5.3 RLS Policies

| Table | Policy | Condition |
|-------|--------|-----------|
| [table] | [policy_name] | [condition] |

---

## 6. API Requirements

### 6.1 REST Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| /[resource] | GET | List [resources] |
| /[resource] | POST | Create [resource] |
| /[resource]/{id} | GET | Get [resource] |
| /[resource]/{id} | PUT | Update [resource] |
| /[resource]/{id} | DELETE | Delete [resource] |

### 6.2 Real-time Subscriptions

| Channel | Events | Purpose |
|---------|--------|---------|
| [channel] | [INSERT, UPDATE, DELETE] | [purpose] |

---

## 7. Dependencies

### 7.1 Packages

```yaml
dependencies:
  - [package]: ^version  # [reason]
  - [package]: ^version  # [reason]

dev_dependencies:
  - [dev_package]: ^version  # [reason]
```

### 7.2 External Services

| Service | Purpose | Configuration |
|---------|---------|---------------|
| [Supabase] | Backend | URL, Anon Key |
| [Sentry] | Error tracking | DSN |
| [Storage] | File storage | Bucket config |

---

## 8. Implementation Plan

### Phase 1: Foundation
- [ ] Setup project structure
- [ ] Create database tables
- [ ] Implement RLS policies
- [ ] Create basic providers

### Phase 2: Core Features
- [ ] Implement [feature 1]
- [ ] Implement [feature 2]
- [ ] Implement [feature 3]

### Phase 3: Polish
- [ ] Add loading states
- [ ] Add error handling
- [ ] Performance optimization

---

## 9. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | [Low/Med/High] | [Low/Med/High] | [Mitigation] |
| [Risk 2] | [Low/Med/High] | [Low/Med/High] | [Mitigation] |

---

## 10. Compatibility & Conflicts

### 10.1 With Existing Features
| Feature | Compatibility | Notes |
|---------|---------------|-------|
| [Feature A] | ✅ Compatible | [notes] |
| [Feature B] | ⚠️ Need coordination | [notes] |

### 10.2 Conflicts Identified
| Conflict | Resolution |
|----------|------------|
| [Conflict 1] | [Resolution] |
| [Conflict 2] | [Resolution] |

---

## 11. Future Considerations

### Scalability
- [ ] Support [N] concurrent users
- [ ] Handle [M] records per table

### Extensibility
- [ ] Easy to add [new feature]
- [ ] Plugin architecture for [extension]

### Technical Debt
- [ ] [Debt 1]: [How to address]
- [ ] [Debt 2]: [How to address]

---

## 12. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| [Metric 1] | [target] | [method] |
| [Metric 2] | [target] | [method] |

---

## 13. Related Documents

- [Screen Specs]: `memory-bank/plan/[screens].md`
- [Database Schema]: `docs/database/`
- [API Docs]: `docs/api/`

---

## 14. Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Tech Lead | | | |
| Product Owner | | | |
| Developer | | | |
```

---

## Quick Reference

| Section | Purpose |
|---------|---------|
| Executive Summary | 1-2 câu về mục tiêu |
| Architecture | Tech stack + data flow |
| Database | Tables + relationships |
| Implementation | Phased approach |
| Risks | What could go wrong |
| Compatibility | Conflicts với features khác |
