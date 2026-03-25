# Phase 5: Personalized Recommendations - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-25
**Phase:** 05-personalized-recommendations
**Areas discussed:** 5 (Screen Location x2, Recommendation Engine, Trigger & Timing, Resource Types, Peer Comparison)

---

## Screen Location (REC-01: Teacher)

| Option | Description | Selected |
|--------|-------------|----------|
| ATC Dashboard | Badge/tray "Students Needing Attention" trên ATC dashboard | |
| Dedicated Tab | Tab riêng "Gợi ý" cho teacher | |
| Both Dashboard + Tab | Badge ở dashboard + tab riêng khi bấm vào | ✓ |

**User's choice:** Both Dashboard + Tab
**Notes:** Teacher thấy badge/tray ngay khi vào trang chấm bài + full tab riêng khi cần chi tiết.

---

## Screen Location (REC-02: Student)

| Option | Description | Selected |
|--------|-------------|----------|
| Extend Analytics Screen | Section "Gợi ý học tập" dưới strengths/weaknesses | |
| Dedicated Tab | Tab riêng "Gợi ý" cho student | |
| Both Analytics + Tab | Gợi ý trong analytics + quick-access từ dashboard | ✓ |

**User's choice:** Both Analytics + Tab
**Notes:** "Phòng khám + Hộp thuốc đầu giường" (Clinic + Bedside Pillbox). Analytics = context-aware ("bác sĩ kê đơn"). Tab = 3 actions khẩn cấp nhất, không cognitive overload. Priority ranking: Tab hiển thị 3 gợi ý khẩn cấp nhất. Data sources: student_skill_mastery (macro) + submission_answers.ai_feedback JSONB (micro).

---

## Recommendation Engine

| Option | Description | Selected |
|--------|-------------|----------|
| Rule-based | mastery < 0.5, score giảm 2 bài → gợi ý. Fast, predictable, no API cost | |
| AI-generated | AI phân tích sâu. Cần Phase 6 complete | |
| Hybrid | Rule-based nền tảng + AI enhancement khi Phase 6 ready. Single sink: ai_recommendations table | ✓ |

**User's choice:** Hybrid
**Notes:** "Bác sĩ Nội trú + Bác sĩ Chuyên khoa" (Resident vs Specialist). Rule-based = quantitative metrics (AVG, COUNT trên DB). AI = qualitative/pedagogy qua ai_queue. Dumb UI: SELECT * FROM ai_recommendations WHERE dismissed = false.

---

## Trigger & Timing

| Option | Description | Selected |
|--------|-------------|----------|
| On-demand | Tính toán real-time khi user vào screen. Fresh nhưng chậm, không acceptable | |
| Background job | Cron định kỳ (mỗi đêm/giờ). Fast nhưng data có thể outdated | |
| Hybrid (On-event + Cron) | DB Trigger khi graded + pg_cron định kỳ 2:00 AM quét macro patterns | ✓ |

**User's choice:** Hybrid (On-event + Background Cron)
**Notes:** "Dây chuyền kiểm định + Đội tuần tra đêm" (Assembly Line + Night Patrol). On-event: fresh alert ngay khi submission graded. Cron: phát hiện "mastery giảm dần 3 bài kiểm tra liên tiếp" — không thể bằng single-event trigger. Dumb UI: Pre-computed data, không on-demand query.

---

## Resource Types (REC-02: Student)

| Option | Description | Selected |
|--------|-------------|----------|
| Curated links | videos, PDFs, articles | ✓ |
| AI-generated paths | AI generate personalized study plan (quá đắt, hallucination risk) | |
| Practice assignments | Bài tập ôn luyện từ weaknesses | ✓ |

**User's choice:** Both Curated links + Practice assignments
**Notes:** "Hiệu thuốc + Phòng tập Vật lý trị liệu" (Pharmacy + Rehab Gym). Không thể chỉ phát tờ rơi (links) mà phải bắt patient tập (practice). JSONB resources column: videos, documents, exercises (UUIDs → join với assignments). Closed-loop: practice → work_sessions → skill mastery → radar refresh → new recommendations.

---

## Peer Comparison (REC-03)

| Option | Description | Selected |
|--------|-------------|----------|
| Within Analytics | Badge + percentile inline, no dedicated screen | |
| Dedicated Peer Tab | Full leaderboard + distribution chart | |
| Both inline + detailed view | Quick-glance badge + deep analysis (dual radar) khi tap | ✓ |

**User's choice:** Both inline + detailed view
**Notes:** "Chiếc gương chiếu hậu" (Rearview Mirror). Quick-glance: "Top 15% của lớp" badge + dual-line chart (student vs class avg). Deep: Dual Radar Chart — xanh = student's mastery, xám = class avg. NO LEADERBOARD (tối kỵ). CRITICAL: SECURITY DEFINER RPC bắt buộc. Frontend tuyệt đối không nhận raw scores của students khác.

---

## Claude's Discretion

Areas deferred to Claude:
- Badge design và color scheme cụ thể
- Số lượng recommendations hiển thị mặc định (3 cho Tab, full cho Analytics)
- Empty state messages
- Animation/transitions

## Deferred Ideas

- AI-generated personalized study paths — deferred to Phase 6
- Misconception grouping (qualitative) — deferred to Phase 6 AI
- Push notifications cho new recommendations — future enhancement
- Real-time recommendation status updates — future enhancement
