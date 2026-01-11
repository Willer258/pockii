---
stepsCompleted: [1, 2, 3, 4, 5-skipped, 6, 7, 8, 9, 10, 11]
status: complete
inputDocuments:
  - planning-artifacts/product-brief-accountapp-2026-01-06.md
  - planning-artifacts/research/market-technical-accountapp-research-2026-01-06.md
  - project-context.md
  - analysis/brainstorming-session-2026-01-06.md
workflowType: 'prd'
lastStep: 2
documentCounts:
  briefs: 1
  research: 1
  projectContext: 1
  brainstorming: 1
date: 2026-01-06
author: Wilfriedhouinlindjonon
project_name: accountapp
---

# Product Requirements Document - accountapp

**Author:** Wilfriedhouinlindjonon
**Date:** 2026-01-06

---

## Executive Summary

**accountapp** is a personal finance management mobile application designed for people with modest incomes, with a primary focus on the African context. The app transforms passive budget management (spreadsheets, mental calculations) into an intelligent system centered on two key concepts:

1. **"Remaining Budget" (Reste à vivre)** — A single, actionable number showing exactly how much the user can spend today
2. **"Your Patterns" (Tes Patterns)** — Revealing invisible spending habits after one month of data collection

### The Problem

Users are trapped in a monthly debt cycle: borrowing from family/friends at month-end, repaying the following month, leaving less budget, and repeating the cycle. The root cause identified through 5 Whys analysis: **users have never SEEN their own spending patterns visualized**. Without historical visibility, they cannot anticipate recurring obligations and remain in permanent reactive mode.

### The Solution

accountapp provides real-time financial visibility through:
- **Bidirectional flow tracking** — Multiple income sources AND expense categories (not just one fixed salary)
- **Instant "Remaining Budget" updates** — Recalculated after every entry or expense
- **Pattern revelation** — After 30 days, users discover their invisible spending habits
- **Subscription tracking** — Tontines, annual fees, family obligations integrated into calculations
- **Preventive alerts** — Based on personal patterns, not generic thresholds

### What Makes This Special

| Differentiator | Description |
|----------------|-------------|
| **Single number focus** | "Remaining Budget" as the central UI element, not a complex dashboard |
| **Pattern revelation** | First app to show users their invisible spending habits |
| **Bidirectional flow** | Handles multiple incomes and expenses equally |
| **African culture built-in** | Tontines, family obligations, social contributions native to the app |
| **100% offline** | Works without internet, all data stays on device |
| **Supportive tone** | Financial coach that motivates, never guilt-trips |
| **Africa-first, multi-currency** | Designed for African realities, open to other currencies |

## Project Classification

| Attribute | Value |
|-----------|-------|
| **Technical Type** | Mobile App (Flutter cross-platform) |
| **Domain** | Fintech (Personal Finance / Budgeting) |
| **Complexity** | High (fintech domain) |
| **Project Context** | Greenfield — new project |
| **Regulatory Status** | MVP exempt from BCEAO licensing (budgeting tool, no payment processing) |

### Domain Considerations

As a fintech application, accountapp addresses high-complexity concerns:

- **Data Security:** SQLCipher encryption for local database, keys stored in Android Keystore
- **Privacy:** 100% local storage, no cloud sync, no analytics for MVP
- **Compliance:** Budgeting tool only — no money transfers, no KYC/AML requirements
- **SMS Permissions:** Runtime permission requests with clear user explanation

---

## Success Criteria

### User Success

**Definition of Success:** User finishes the month with positive balance (Revenues - Expenses > 0) without borrowing from family/friends.

**Aha Moments (Progressive Revelations):**
| Moment | Timing | Trigger |
|--------|--------|---------|
| Aha #1 | 24h | "Remaining Budget" updates after first entry |
| Aha #2 | 7 days | "7-Day Streak" badge unlocked |
| Aha #3 | 1 month | "Your Patterns" feature revealed |

**Key Behaviors to Track:**
- Daily expense/income entry (target: 1x/day minimum)
- "Remaining Budget" consultation (target: 1x/day)
- 7-day streak completion rate

### Business Success

**3-Month Objectives:**
- Focus: Acquisition + PMF Validation
- Target: 1,000+ Monthly Active Users (MAU)
- Validation: M1 Retention > 30%

**12-Month Objectives:**
- Focus: Retention + Monetization
- Target: 10,000+ MAU with M3 Retention > 20%
- First revenues via freemium model or partnerships

### Technical Success

| Criteria | Target | Measurement |
|----------|--------|-------------|
| App size | < 30MB APK | Build output |
| Offline functionality | 100% MVP features | Manual testing |
| Data security | SQLCipher encrypted | Security review |
| Performance | Smooth on low-end devices | Tecno/Infinix testing |
| SMS parsing accuracy | > 95% (Wave/Orange CI) | Test fixtures |

### Measurable Outcomes (KPIs)

**3 Active KPIs (MVP):**
| KPI | Description | Target | Type |
|-----|-------------|--------|------|
| **7-Day Streak Rate** | % users with 7 consecutive days of entry | > 40% | Leading |
| **M1 Retention** | % users active at M+1 | > 30% | Core |
| **Implicit Save Rate** | % with (Revenues - Expenses) > 0 at month end | > 25% | North Star |

**Month Definition:** Calendar month (1st to last day). "Remaining Budget" resets on the 1st of each month.

---

## Product Scope

### MVP - Minimum Viable Product (1 month)

1. **"Remaining Budget" in real-time**
   - Single number on main screen
   - Color coding: Green (OK) / Orange (Warning) / Red (Danger)
   - Instant update after each entry

2. **Manual entry of incomes AND expenses**
   - Simple interface: Amount + Category + Note (optional)
   - Income categories: Salary, Freelance, Reimbursement, Gift, Other
   - Expense categories: Transport, Food, Leisure, Family, Subscriptions, Other
   - Edit/delete capability

3. **"Your Patterns" (after 1 month)**
   - Auto-unlock after 30 days of data
   - Averages by category
   - Top 3 expense categories
   - Month vs previous month comparison

4. **Subscription tracking**
   - List of recurring obligations (tontines, subscriptions, family)
   - Reminders before due date
   - Integrated into "Remaining Budget" calculation

### Growth Features (Post-MVP v1.1)

- SMS auto-import (Wave, Orange Money - Ivory Coast)
- Advanced preventive alerts based on patterns
- UX improvements based on beta feedback

### Vision (Future v2.0+)

- Voice entry
- Monthly predictions
- Savings circles (community)
- Virtual safe (savings visualization)
- Investment module (ETF, crypto partnerships)
- Multi-user family management
- Regional expansion (other FCFA countries)

---

## User Journeys

### Journey 1: Wilfried - Breaking the Monthly Debt Cycle (Happy Path)

Wilfried is a 27-year-old Full Stack Developer earning 350,000 FCFA per month. Despite having a stable income, he consistently finds himself borrowing from his brother or friends during the last week of every month. He's tried tracking expenses in a Notion table, but it's just a passive list that he rarely checks. The frustration peaks when his girlfriend asks for 15,000 FCFA for a "small thing" and he realizes he has no idea if he can afford it.

One evening, scrolling through Instagram, he sees an ad for accountapp with the tagline "Sais-tu combien tu peux dépenser aujourd'hui?" — it hits home. He downloads the app.

The onboarding takes 90 seconds: monthly income (350,000), fixed expenses (rent 100,000, bills 20,000). Immediately, the screen shows a single big number: **"Remaining Budget: 230,000 FCFA"**. For the first time, Wilfried sees his actual spending power, not just his salary.

The next morning, he buys his usual baguette (300 FCFA) and logs it in 5 seconds. The number updates: **229,700 FCFA**. Throughout the day, he logs transport (200), lunch (1,000), and a spontaneous taxi (2,500). Each time, he watches the number go down. It's oddly satisfying — like a game where he's trying to keep the number green.

By the end of the first week, Wilfried has logged 47 transactions. He's already noticing something: he takes taxis way more than he realized. The app hasn't judged him or told him to stop — it just shows the truth. For the first time in months, he finishes the week knowing exactly where he stands.

### Journey 2: Wilfried - Surviving the Last Week (Edge Case)

It's the 24th of the month. Wilfried opens accountapp and sees the number in orange: **"Remaining Budget: 35,000 FCFA"**. Seven days left, 35,000 FCFA. His stomach tightens — but at least he KNOWS. Last month, he would have discovered this on the 28th when his card got declined.

Then his phone buzzes. His cousin is getting married this weekend — cotisation expected: 10,000 FCFA. He adds it as a planned expense. The number drops to **25,000 FCFA**. Red zone.

Wilfried makes a decision: no taxis this week, only bus. He logs his daily expenses obsessively. When his colleague suggests lunch at a 2,500 FCFA restaurant, Wilfried checks the app, sees **18,000 FCFA** remaining, and suggests the 1,000 FCFA street food instead. No shame, no explanation needed — he just knows his limit.

On the 29th, his girlfriend calls: "Tu peux m'envoyer 5,000 pour un truc?" Wilfried checks: **8,500 FCFA** left. He hesitates, then says honestly: "Je peux t'envoyer 3,000 maintenant, le reste la semaine prochaine." She's surprised by the precision but appreciates the honesty.

The month ends. Remaining budget: **2,200 FCFA**. It's not much, but it's positive. For the first time in eight months, Wilfried didn't borrow a single franc from anyone. He screenshots the green number and sends it to his brother with one word: "Enfin."

### Journey 3: Wilfried - Seeing the Invisible (Aha Moment)

It's been 32 days since Wilfried installed accountapp. He opens the app and sees a new notification: "Your Patterns are ready. Discover where your money really goes."

He taps. The screen transforms into something he's never seen before: his own spending DNA.

**Transport: 47,500 FCFA/month**
"47,000 in transport?!" He knew he took taxis, but not THAT much. The breakdown shows: 28 taxi rides averaging 1,700 FCFA each. The app shows a gentle insight: "On days you wake up after 7am, you take a taxi 80% of the time."

**Food outside: 38,000 FCFA/month**
Wilfried always thought he ate cheaply. But the data shows 1,200 FCFA average per meal, 5 days a week. The app notes: "You spend 2x more on Fridays than other days."

**Subscriptions & Family: 25,000 FCFA/month**
This one doesn't surprise him — but seeing it written makes it real. Tontine 10,000, various family contributions 15,000. The app shows: "You have 3 recurring subscriptions. Next due: Tontine in 12 days."

The real shock comes at the bottom: **"Uncategorized 'Other' expenses: 31,000 FCFA"**. These are the invisible expenses — the random stuff he never tracked. Small purchases, spontaneous gifts, things he can't even remember.

Wilfried sits back. In five minutes, he's learned more about his financial habits than in 27 years of living. The app doesn't tell him what to do — it just shows him the truth. But now that he sees it, he can't unsee it.

He sets a mental goal: next month, transport under 35,000. Not because the app told him to, but because now he knows it's possible.

### Journey Requirements Summary

| Journey | Key Capabilities Required |
|---------|--------------------------|
| **Happy Path** | Onboarding, single-number UI, quick entry, real-time updates |
| **Edge Case** | Warning states, planned expenses, decision support, monthly summary |
| **Aha Moment** | Pattern analysis, category breakdown, behavioral insights, reminders |

### Capability Mapping

**Onboarding Flow**
- Income entry
- Fixed expenses entry
- Immediate "Remaining Budget" display

**Daily Usage**
- Quick expense/income entry (< 10 sec)
- Real-time budget recalculation
- Color-coded status (green/orange/red)
- Transaction history

**Monthly Features**
- Pattern analysis (after 30 days)
- Category breakdown visualization
- Behavioral insights
- Month-end summary

**Subscription Management**
- Recurring expense list
- Due date reminders
- Integration with budget calculation

---

## Innovation & Novel Patterns

### Detected Innovation Areas

accountapp's innovation lies not in technology but in **radical simplification** and **cultural relevance**. While expense tracking apps have existed for decades, none have successfully addressed the specific needs of users with modest incomes in African contexts.

**Core Innovation: Single-Number UX Philosophy**

Traditional budgeting apps overwhelm users with:
- Multiple accounts and balances
- Complex category breakdowns
- Graphs, charts, and dashboards
- Sync issues between devices

accountapp strips everything away to answer ONE question: "How much can I spend today?"

This is a deliberate UX innovation inspired by the insight that **users don't need more information — they need actionable clarity**.

**Pattern Revelation Engine**

Most finance apps show data. accountapp reveals **behavioral insights**:
- "You take taxis 80% of the time when you wake up after 7am"
- "You spend 2x more on Fridays than other days"
- "Your 'Other' category hides 31,000 FCFA of invisible spending"

This transforms passive data into **self-discovery moments** that create lasting behavior change.

**Africa-First Architecture**

Unlike apps adapted from Western markets, accountapp is built from the ground up for African financial realities:
- **Cash-dominant economy** (60-70% of transactions)
- **Mobile Money as primary "bank"** (Wave, Orange Money)
- **Family financial obligations** as first-class citizens
- **Tontines/ROSCAs** as native features, not afterthoughts
- **FCFA integer handling** (no decimal complications)

### Market Context & Competitive Landscape

**Gap Identified:**
- 210M people in FCFA zone
- 96.9% use fintech apps, but only 5.2% use budgeting apps
- No dominant personal finance app in francophone Africa
- Existing apps (Bankin', YNAB, Mint) designed for Western banking systems

**Why This Gap Exists:**
1. Western apps require bank account sync (most Africans use cash + Mobile Money)
2. Complex UIs don't resonate with users who want simplicity
3. Cultural features (tontines, family obligations) are missing entirely
4. Localization is surface-level (language) not deep (financial behavior)

### Validation Approach

| Innovation | Validation Method | Success Criteria |
|------------|-------------------|------------------|
| Single-number UX | Beta user interviews | Users check "Remaining Budget" daily |
| Pattern revelation | 30-day cohort analysis | >50% users have "aha moment" |
| Africa-first features | Feature usage tracking | Tontine/subscription features used by >30% |

**MVP Validation Questions:**
1. Do users actually check the "Remaining Budget" before spending?
2. Does the pattern revelation create measurable behavior change?
3. Are cultural features (tontines) used or ignored?

### Risk Mitigation

| Innovation Risk | Mitigation Strategy |
|-----------------|---------------------|
| Users don't want simplicity (want features) | Start minimal, add features only if requested |
| Pattern insights feel creepy/invasive | Frame as "self-discovery", not surveillance |
| Single-number hides important context | Add optional "details" view, keep hero number |
| Africa-first limits global expansion | Design for Africa, but keep architecture currency-agnostic |

---

## Mobile App Specific Requirements

### Platform Requirements

| Platform | MVP Support | Notes |
|----------|-------------|-------|
| **Android** | ✅ Primary | API 23+ (Android 6.0 Marshmallow) |
| **iOS** | ❌ Post-MVP | Planned for v2.0 — no SMS access on iOS |

**Rationale:** Android-first strategy due to:
- 85%+ smartphone market share in target region (francophone Africa)
- SMS parsing capability (critical for Mobile Money auto-import)
- Target devices: Tecno, Infinix, Samsung A series (< 150 USD)

### Device Permissions

| Permission | Purpose | Required | Fallback |
|------------|---------|----------|----------|
| `READ_SMS` | Parse Mobile Money transaction SMS | Optional | Manual entry |
| `RECEIVE_SMS` | Real-time transaction detection | Optional | Manual entry |
| `POST_NOTIFICATIONS` | Budget alerts and reminders | Required | In-app only |

**Permission UX Flow:**
1. App works 100% without SMS permissions
2. After 7-day streak, suggest SMS import as "upgrade"
3. Clear explanation in French: "Accéder aux SMS Wave/Orange pour import automatique"
4. User can revoke anytime, app continues to work

### Push Notification Strategy

**Notification Types (MVP):**

| Type | Trigger | Frequency |
|------|---------|-----------|
| Subscription Reminder | X days before due date | Once per subscription |
| Budget Warning (Orange) | Remaining < 30% | Once per threshold |
| Budget Alert (Red) | Remaining < 10% | Once per threshold |
| Streak Celebration | 7-day streak achieved | Once |

**Constraints:**
- Maximum 2 notifications per day
- User can disable per category
- No notifications between 22h00 - 07h00
- Tone: Supportive, never guilt-tripping

### Offline Capabilities

| Feature | Offline Support | Sync Behavior |
|---------|-----------------|---------------|
| Expense/Income entry | ✅ Full | N/A (100% local) |
| "Remaining Budget" display | ✅ Full | N/A |
| Transaction history | ✅ Full | N/A |
| Pattern analysis | ✅ Full | N/A |
| Subscription reminders | ✅ Full | Local notifications |

**Note:** MVP is 100% offline. No cloud sync, no backend, no data leaves the device.

### App Size & Performance

| Metric | Target | Constraint |
|--------|--------|------------|
| APK size | < 30MB | SQLCipher adds ~4MB |
| Cold start | < 3s | On Tecno Spark 8 |
| Memory usage | < 150MB | Low-end device support |
| Battery impact | Minimal | WorkManager 15min intervals |

### Localization

| Aspect | MVP Implementation |
|--------|-------------------|
| **UI Language** | French only |
| **Currency** | FCFA (XOF) primary, architecture supports others |
| **Number format** | Space as thousands separator (350 000 FCFA) |
| **Date format** | DD/MM/YYYY (European/African standard) |
| **Future** | English, other FCFA countries (Senegal, Mali, etc.)

---

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Experience MVP — Deliver the transformative "single number" UX that changes spending behavior

**Resource Requirements:**
- Team: Solo developer (Wilfried)
- Timeline: 1 month MVP development
- Budget: Bootstrap (no external funding)
- Testing: Personal Android device + 5-10 beta users

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
1. ✅ Happy Path (Wilfried - Breaking the Monthly Debt Cycle)
2. ✅ Edge Case (Wilfried - Surviving the Last Week)
3. ⚠️ Aha Moment (Pattern revelation — unlocked at Day 30)

**Must-Have Capabilities:**

| Feature | Priority | Rationale |
|---------|----------|-----------|
| "Remaining Budget" real-time display | P0 | Core value proposition |
| Manual expense entry (<10 sec) | P0 | Primary input method |
| Manual income entry | P0 | Bidirectional flow support |
| Color-coded budget status (green/orange/red) | P0 | Instant visual feedback |
| Transaction history (list view) | P0 | Trust and verification |
| Basic category selection | P0 | Pattern analysis foundation |
| Subscription/recurring expense tracking | P1 | Monthly planning essential |
| "Your Patterns" (Category breakdown) | P1 | Unlocked at Day 30 |
| Local notifications (budget alerts) | P1 | Preventive behavior |
| SQLCipher encryption | P0 | Trust and security |

**Explicitly OUT of MVP:**
- ❌ SMS auto-import (Wave/Orange Money) — moved to v1.1
- ❌ Advanced predictive alerts
- ❌ Voice entry
- ❌ Cloud sync / backup
- ❌ iOS version
- ❌ Multi-currency support

### Post-MVP Features

**Phase 2 — Growth (v1.1-1.x):**

| Feature | Why Post-MVP |
|---------|--------------|
| SMS auto-import (Wave CI, Orange CI) | Requires runtime permissions complexity |
| Advanced pattern insights | Needs more user data to validate value |
| Behavioral predictions | Depends on pattern engine maturity |
| UX improvements from beta feedback | Requires real user data |
| Additional expense categories | User-driven customization |

**Phase 3 — Expansion (v2.0+):**

| Feature | Strategic Value |
|---------|-----------------|
| iOS version | Market expansion (15% of target market) |
| Voice entry (STT) | Accessibility, emerging market potential |
| Multi-currency (other FCFA countries) | Regional expansion |
| Family/group management | Household financial planning |
| Savings circles (community feature) | Cultural relevance, retention |
| Investment module | Premium feature / monetization |
| Cloud backup (optional, encrypted) | User request if validated |

### Risk Mitigation Strategy

**Technical Risks:**

| Risk | Impact | Mitigation |
|------|--------|------------|
| SQLCipher integration complexity | High | Use proven flutter_sqlcipher wrapper |
| SMS parsing fragility | Medium | Postpone to v1.1, manual entry fallback |
| Low-end device performance | Medium | Profile on Tecno Spark early |
| WorkManager reliability | Low | Local notifications backup |

**Market Risks:**

| Risk | Impact | Mitigation |
|------|--------|------------|
| Users don't want simplicity | High | Beta test with 5-10 users, iterate UX |
| Pattern insights feel invasive | Medium | Frame as "self-discovery", not surveillance |
| Competition from Mobile Money apps | Low | Niche focus on behavior change, not transactions |

**Resource Risks:**

| Risk | Impact | Mitigation |
|------|--------|------------|
| Solo developer burnout | High | 1-month MVP scope, strict feature cut |
| Scope creep | High | Document explicit "OUT of MVP" list |
| Time overrun | Medium | Priority P0 only for launch, P1 in first week |

### Success Validation Checkpoints

| Checkpoint | Timing | Validation Question |
|------------|--------|---------------------|
| **Alpha** | Week 2 | Does "Remaining Budget" update feel instant? |
| **Beta** | Week 4 | Do 5+ users check budget daily? |
| **Launch** | Week 4+1 | Is 7-Day Streak achievable for 40%? |
| **M1 Review** | Month 2 | M1 Retention > 30%? |

---

## Functional Requirements

### Budget Visibility (Core Value)

- FR1: User can view their current "Remaining Budget" as a single prominent number
- FR2: User can see the "Remaining Budget" update immediately after any transaction entry
- FR3: User can see color-coded budget status (green: OK, orange: warning, red: danger)
- FR4: User can understand their budget status at a glance without scrolling or navigation
- FR5: System recalculates "Remaining Budget" as: Σ(Monthly Incomes) - Σ(Recurring Expenses) - Σ(One-time Expenses) - Σ(Planned Expenses)

### Transaction Management

- FR6: User can add a new expense with amount, category, and optional note
- FR7: User can add a new income with amount, category, and optional note
- FR8: User can complete a transaction entry in under 10 seconds
- FR9: User can select from predefined expense categories (Transport, Food, Leisure, Family, Subscriptions, Other)
- FR10: User can select from predefined income categories (Salary, Freelance, Reimbursement, Gift, Other)
- FR11: User can view a chronological list of all transactions
- FR12: User can edit an existing transaction (amount, category, note)
- FR13: User can delete a transaction
- FR14: User can see transaction date and time for each entry
- FR15: System treats all amounts as integers (FCFA has no decimals)
- FR16: User can backdate a transaction to a previous date within the current month
- FR17: System validates transaction amounts (positive integers only, rejects zero or negative)

### Pattern Analysis ("Your Patterns")

- FR18: System unlocks "Your Patterns" feature after 30 days of data collection
- FR19: User can view average spending by category
- FR20: User can see their top 3 expense categories
- FR21: User can compare current month spending vs previous month
- FR22: User can see total income vs total expenses for the current month
- FR23: User can see day-of-week spending distribution (e.g., "You spend 2x more on Fridays")

### Subscription & Recurring Expense Management

- FR24: User can add a recurring expense (tontine, subscription, family obligation)
- FR25: User can specify due date and frequency for recurring expenses
- FR26: User can view a list of all active subscriptions/recurring expenses
- FR27: User can edit or delete a recurring expense
- FR28: System integrates recurring expenses into "Remaining Budget" calculation
- FR29: System sends reminders before recurring expense due dates

### Planned Future Expenses

- FR30: User can add a planned future expense (one-time, not recurring)
- FR31: User can specify the expected date for a planned expense
- FR32: System deducts planned expenses from "Remaining Budget" before they occur
- FR33: User can convert a planned expense to an actual transaction when paid
- FR34: User can cancel or modify a planned expense

### Notification & Alerts

- FR35: User can receive budget warning notification when remaining budget drops below 30%
- FR36: User can receive budget alert notification when remaining budget drops below 10%
- FR37: User can receive subscription reminder notification before due date
- FR38: User can receive streak celebration notification upon achieving 7-day streak
- FR39: User can configure notification preferences per notification type
- FR40: System limits notifications to maximum 2 per day

### Onboarding & Setup

- FR41: User can complete initial setup in under 2 minutes
- FR42: User can enter their monthly income(s) during onboarding
- FR43: User can enter their fixed monthly expenses during onboarding
- FR44: User can see their initial "Remaining Budget" immediately after onboarding
- FR45: System creates a new budget period on the 1st of each calendar month

### Data Security & Privacy

- FR46: System stores all data locally on device (no cloud sync for MVP)
- FR47: System encrypts the local database using SQLCipher
- FR48: System stores encryption key securely in Android Keystore
- FR49: User can use the app 100% offline without any functionality loss
- FR50: System never transmits user financial data to external servers
- FR51: System retains all transaction history across months for pattern analysis

### User Engagement & Gamification

- FR52: System tracks consecutive days of transaction entry (streak)
- FR53: User can view their current streak count
- FR54: User receives visual celebration upon achieving 7-day streak
- FR55: User can see month-end summary showing final budget balance

### Empty States & Edge Cases

- FR56: User can see meaningful empty state when no transactions exist
- FR57: User can see guidance on first launch before any data entry

---

## Non-Functional Requirements

### Performance

**Rationale:** accountapp cible des appareils low-end (Tecno, Infinix, Samsung A series). La performance est critique pour l'expérience utilisateur.

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| NFR1: Cold start time | < 3 seconds | Time from tap to usable screen on Tecno Spark 8 |
| NFR2: "Remaining Budget" update | < 100ms | Time from transaction save to UI update |
| NFR3: Transaction entry flow | < 10 seconds total | End-to-end time to log an expense |
| NFR4: Screen transitions | < 300ms | Navigation between screens |
| NFR5: App memory usage | < 150MB RAM | Peak usage during normal operation |
| NFR6: APK size | < 30MB | Final release build (SQLCipher adds ~4MB) |
| NFR7: Battery impact | Minimal | No background drain beyond WorkManager 15min intervals |

**Performance Testing:**
- Primary test device: Tecno Spark 8 (or equivalent low-end Android)
- Test with 1,000+ transactions in database
- Profile with Flutter DevTools before release

### Security

**Rationale:** accountapp handles sensitive financial data. Users must trust that their data is private and protected.

| Requirement | Target | Implementation |
|-------------|--------|----------------|
| NFR8: Database encryption | AES-256 via SQLCipher | All local data encrypted at rest |
| NFR9: Encryption key storage | Android Keystore | Key never exposed in memory or logs |
| NFR10: Data transmission | Zero network calls | No data leaves device (MVP) |
| NFR11: Sensitive data logging | Prohibited | No amounts, categories, or personal data in logs |
| NFR12: Screen capture protection | Optional | FLAG_SECURE on sensitive screens (budget, patterns) |
| NFR13: Biometric unlock | Post-MVP | App lock with fingerprint/PIN for v1.1 |

**Security Boundaries:**
- No cloud sync = no data exfiltration risk
- No analytics = no third-party data sharing
- No payments = no PCI-DSS compliance required

### Reliability

**Rationale:** Users depend on accountapp for financial decisions. Data loss would destroy trust.

| Requirement | Target | Implementation |
|-------------|--------|----------------|
| NFR14: Data durability | Zero data loss | SQLite WAL mode, transaction safety |
| NFR15: Crash recovery | Full state restore | App state persisted, resume on restart |
| NFR16: Offline availability | 100% functionality | All MVP features work without network |
| NFR17: Database integrity | Self-healing | Automatic corruption detection and repair |
| NFR18: Month transition | Atomic | Budget period reset is transactional |

**Reliability Testing:**
- Kill app mid-transaction → verify no data corruption
- Simulate low storage → verify graceful handling
- Test month boundary at 23:59 → 00:01 transition

### Accessibility (Baseline)

**Rationale:** MVP focuses on core functionality, but basic accessibility ensures broader usability.

| Requirement | Target | Standard |
|-------------|--------|----------|
| NFR19: Touch targets | Minimum 48x48 dp | Material Design guidelines |
| NFR20: Color contrast | 4.5:1 minimum | WCAG AA for text |
| NFR21: Font scaling | Support system font size | Android accessibility settings respected |
| NFR22: Screen reader | Basic support | TalkBack can read budget and transaction list |

**Post-MVP Accessibility:**
- Voice entry (v2.0)
- High contrast theme
- Full WCAG AA compliance

### Localization

**Rationale:** MVP targets francophone Africa, with architecture supporting future expansion.

| Requirement | Target | Implementation |
|-------------|--------|----------------|
| NFR23: UI language | French only (MVP) | All strings in French |
| NFR24: Number format | Space as thousands separator | "350 000 FCFA" not "350,000" |
| NFR25: Date format | DD/MM/YYYY | European/African standard |
| NFR26: Currency | FCFA (XOF) integers | No decimals, int type only |
| NFR27: Future languages | Architecture ready | String externalization for i18n |
