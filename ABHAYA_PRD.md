# Product Requirements Document: ABHAYA
### A Community-Powered, Offline-Capable Women's Safety Platform

**Version:** 1.0
**Status:** Draft for Review
**Owner:** Product Team

---

## 1. Executive Summary

Dozens of women's safety apps already exist (bSafe, Life360, Noonlight, SafetiPin, Circle of 6, government apps like Raksha/112 India). Most converge on the same feature set: a panic button, live location sharing with contacts, and maybe a fake-call tool. They share the same core weaknesses:

- They **assume a smartphone, a data connection, and a charged battery** — exactly the conditions most likely to fail during an actual emergency (basements, elevators, poor network areas, dead batteries, snatched phones).
- They rely entirely on **personal contacts who may not be reachable in real time** (asleep, at work, far away), rather than anyone nearby who could actually intervene in seconds.
- They stop at the alert. **Almost none help after the incident** — no evidence that holds up legally, no path to filing a police report, no connection to counseling or legal aid.
- Activation is often **not discreet** — requiring an unlock, an app open, a shake, or a shout — which is exactly what an attacker will notice and stop.
- Most are **subscription-gated or built for smartphone-owning urban users**, leaving out the women most exposed to risk (rural areas, low-end devices, low literacy, low income).

**ABHAYA's differentiation is not "another panic button."** It is built around three ideas competitors don't combine:

1. **Works when everything else fails** — offline SOS via SMS/USSD, Bluetooth mesh relay to nearby phones, and a feature-phone/IVR mode.
2. **Nearby help, not just distant contacts** — a verified "Guardian Network" of nearby registered users and vetted volunteers who can physically respond in the golden first minutes, alongside personal contacts.
3. **Full incident lifecycle, not just the alert** — automatic tamper-evident evidence capture, one-tap FIR/police filing where available, and a warm handoff to legal aid and counseling partners — so the app is still useful the day *after* the emergency.

---

## 2. Problem Statement

Women modify their daily behavior — routes, timing, clothing, who they tell — because of a persistent, reasonable fear of harassment or violence. Existing safety technology reduces anxiety marginally but rarely changes outcomes in the moments that matter, because:

| Failure mode | Why it happens |
|---|---|
| No signal / no data | Most apps need internet to send alerts; underground transit, rural roads, and building interiors often have none |
| Phone taken or dropped | Apps require ongoing phone access to keep functioning (holding to talk, keeping screen on) |
| Contacts unavailable | A single "emergency contact" may be asleep, driving, or hours away |
| Alert without response | Notifying someone is not the same as someone arriving; most apps have no concept of proximity-based response |
| No usable evidence | Screenshots and self-reported location aren't strong evidence; recordings, if any, aren't time-stamped or tamper-proof |
| Dead end after the SOS | Almost no app connects the user to police filing, legal aid, or mental health support afterward |
| Cost and access barriers | Premium tiers, smartphone-only design, and English-first UX exclude exactly the users at highest risk |

## 3. Competitive Landscape (Existing Solutions)

| App | Core strength | Core gap |
|---|---|---|
| **bSafe** | Voice-activated SOS, auto audio/video recording, fake-call feature | Needs data connectivity; evidence isn't legally chain-of-custody verified; no nearby-responder network |
| **Life360** | Strong family location sharing, geofencing | Built for family tracking, not stranger-danger response; no panic escalation to non-family helpers |
| **Noonlight** | Direct dispatch to professional emergency services | Subscription-based; US-centric dispatch integration; no offline mode |
| **SafetiPin** | Crowdsourced area safety scores, safer-route suggestions | Passive/preventive only — no real-time incident response layer |
| **Circle of 6** | Simple, fast one-tap alert to trusted contacts | Contacts-only; no proximity responders, no evidence capture |
| **Government apps (e.g., 112 India, Raksha)** | Official police integration | Clunky UX, low awareness, inconsistent response times, no community layer |
| **Google Personal Safety** | Built into OS, no install needed | Limited to supported devices; minimal features beyond basic emergency sharing |

**The gap nobody has filled:** an app that (a) still works without signal, (b) can summon *physical proximity* help within a minute, not just notify someone far away, and (c) supports the user through the legal/emotional aftermath — while staying accessible to non-premium, non-smartphone, non-English users.

## 4. Product Vision

> "Help should not depend on having good signal, a charged phone, or a friend awake at 2 a.m. Help should be as close as the nearest verified person, and it should not end the moment the alert is sent."

## 5. Target Users

- **Primary:** Women aged 16–45 in urban and semi-urban areas commuting, working late shifts, traveling alone, or living independently.
- **Secondary:** Students in hostels/college campuses; solo/domestic travelers; gig workers (delivery, ride-hail) at higher on-street exposure.
- **Tertiary (accessibility-first):** Women in low-connectivity/rural regions and feature-phone users, reached via SMS/USSD/IVR rather than the full app.
- **Guardian Network volunteers:** Background-checked community responders (can include off-duty security personnel, NGO volunteers, participating shopkeepers/"safe spot" partners) plus opted-in nearby app users.

## 6. Goals & Success Metrics

| Goal | Metric | Target (Year 1) |
|---|---|---|
| Fast help in emergencies | Median time from SOS to first responder acknowledgment | < 90 seconds |
| Works under real conditions | % of SOS events successfully delivered with zero/poor connectivity | > 95% |
| Community depth | Verified Guardian Network responders per active city | 1 per 500 users |
| Trust & retention | 90-day retention of activated users | > 55% |
| Reach beyond smartphones | % of registered users using SMS/USSD/IVR mode | Track & grow from launch |
| Real-world usefulness | % of post-incident users who complete a follow-up support flow (legal/counseling) when offered | > 30% |
| Safety, not surveillance | % of users who report the app respects their privacy (survey) | > 90% |

## 7. Differentiated Feature Set

### 7.1 Core MVP (table stakes — must match existing apps)
- One-tap SOS with live location sharing to personal emergency contacts
- Discreet trigger: power-button sequence, home-screen widget, and lock-screen gesture (no need to unlock or open the app)
- Fake call / fake screen to de-escalate a situation without revealing the app is active
- Route sharing ("walk me home") with automatic check-in timers
- Safety-scored route suggestions using crowdsourced incident/lighting/foot-traffic data (building on the SafetiPin model, but merged into the response flow rather than kept separate)

### 7.2 Differentiator 1 — Works Without Signal or Battery
- **SMS/USSD fallback:** if data is unavailable, SOS and location automatically fall back to SMS to contacts and a lightweight carrier-level USSD emergency code.
- **Bluetooth mesh relay:** nearby phones running ABHAYA (even strangers, opted in) silently relay the SOS packet toward a phone with signal — no personal data exchanged, just relay of an encrypted alert.
- **Low-battery mode:** below 10% battery, the app pre-arms a one-press SOS that fires before the phone dies and shares last-known location automatically.
- **Feature-phone/IVR access:** a dedicated short code lets any phone (even non-smartphone) dial in to trigger an alert and share the caller's approximate cell-tower location.

### 7.3 Differentiator 2 — The Guardian Network (Proximity Response)
- In addition to personal contacts, the SOS simultaneously notifies **verified nearby Guardian Network members** within a configurable radius (e.g., 500m), ranked by proximity and response history.
- Guardians are vetted through ID verification, background-check integration where legally available, and a rating system; they can be volunteers, participating local businesses ("safe spot" partners with a visible decal), or off-duty security professionals.
- Users can pre-select trust levels: contacts-only, contacts + verified guardians, or contacts + guardians + nearby opted-in users (broadest reach, used for the most severe alert tier).
- Guardians see only what's necessary (approximate location, alert severity) — never full profile data — preserving the user's privacy even while asking for help.

### 7.4 Differentiator 3 — Full Incident Lifecycle, Not Just the Alert
- **Tamper-evident evidence capture:** on trigger, the app auto-records audio/video and cryptographically timestamps and hashes the file (stored to a write-once log) so it can support a police report or legal case — addressing the "screenshots aren't evidence" gap.
- **One-tap FIR/police filing** integration in regions where digital police reporting APIs exist; where they don't, the app generates a pre-filled incident report the user can bring to a station.
- **Warm handoff to support services:** post-incident, the app offers direct connection to legal-aid NGOs, counseling hotlines, and medical services, tracked (with consent) so the user isn't left alone after the immediate danger passes.
- **False-alarm-friendly design:** a simple, non-punitive cancel/confirm step so users aren't discouraged from testing or lightly triggering the app, but Guardians are told quickly if it's a false alarm to avoid alert fatigue.

### 7.5 Differentiator 4 — Built for Everyone, Not Just Premium Smartphone Users
- Free core safety features forever; monetization comes from B2B/B2G (see Section 11), not from gating SOS behind a paywall.
- Icon-first, low-literacy-friendly UI; full multilingual support including regional languages, not just English.
- Designed to run well on low-end Android devices with minimal storage/RAM footprint.

### 7.6 AI-Assisted Passive Protection (opt-in)
- On-device (not cloud) audio distress detection (screams, specific keywords) that can trigger the discreet SOS flow without any manual action — processed locally to avoid always-on cloud audio streaming, which is a major privacy concern with "always listening" competitors.
- Predictive route risk alerts using crowdsourced incident density, time-of-day, and lighting data, offered proactively before the user heads out, not just reactively during a walk.

## 8. Non-Goals (Explicitly Out of Scope for V1)
- Replacing professional emergency dispatch/police services (ABHAYA escalates to them, it does not replace them)
- Continuous, always-on location tracking of the user by anyone other than explicitly chosen contacts during an active session
- Selling or monetizing any location or incident data
- Full legal-case management (the app connects to legal aid; it does not provide legal representation)

## 9. Key User Flows

1. **Silent SOS trigger** → App confirms via haptic (not sound) → Alert + location sent via best available channel (data → SMS → BLE mesh → cached-for-later) → Personal contacts + Guardian Network notified by proximity → Evidence capture begins → User can de-escalate (fake call) or continue.
2. **Walk-me-home** → User starts a timed session → Automatic check-ins → If check-in missed, escalates automatically to SOS flow.
3. **Post-incident support** → After SOS is closed, app checks in 1 hour and 24 hours later → Offers legal-aid/counseling connection with one tap, fully optional.
4. **Guardian onboarding** → ID verification → Background-check integration (where available) → Training module (de-escalation basics, what to do/not do) → Activated in network.
5. **Low-connectivity/feature-phone flow** → Dial short code or send keyword SMS → Location shared via cell-tower triangulation → Contacts alerted via SMS.

## 10. Non-Functional Requirements

- **Privacy & data minimization:** end-to-end encryption for location/alert data; on-device processing for AI features; no data resale; clear, short-form consent language (not buried legal text).
- **Reliability:** SOS delivery must degrade gracefully (data → SMS → BLE mesh → cached retry) rather than fail silently.
- **Battery efficiency:** background location/monitoring services optimized to add no more than ~3–5% additional daily battery drain in passive mode.
- **Accessibility:** WCAG-compliant UI, multilingual, low-literacy icon design, feature-phone parity for core SOS.
- **Security:** evidence files write-once and hashed to prevent tampering; Guardian access strictly scoped and logged.
- **Legal/regional compliance:** integrate with local emergency systems (e.g., 112 in India, 911 in the US, 112 in EU) and comply with regional data-protection law (e.g., DPDP Act in India, GDPR in EU).

## 11. Monetization & Sustainability
- **Freemium for individuals:** core SOS, Guardian Network access, and evidence capture are free forever.
- **B2B:** enterprise safety add-ons for employers (corporate cab/late-shift safety programs), campuses, and gig-economy platforms (ride-hail, delivery) needing duty-of-care tools.
- **B2G/NGO partnerships:** government and NGO sponsorship to fund the Guardian Network vetting infrastructure and feature-phone/IVR access in underserved regions.
- **Optional premium tier:** advanced features like extended evidence cloud storage, family multi-device plans, and travel-specific tools (e.g., international emergency numbers, embassy contacts).

## 12. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| False alarms overwhelming Guardian Network | Tiered escalation (contacts first, then guardians for higher-severity/unconfirmed alerts); quick false-alarm cancellation |
| Guardian Network safety/vetting failures | Mandatory ID + background-check integration, ratings, ability to report/deactivate guardians instantly |
| Privacy backlash over "always listening" AI | Strictly on-device, opt-in only, clear indicator when active, no cloud audio streaming |
| Legal liability if a Guardian's response goes wrong | Clear terms of service positioning Guardians as community responders (not deputized agents), training modules on what NOT to do, insurance partnership exploration |
| Low adoption of feature-phone/IVR channel | Partner with telecom carriers for pre-loaded short codes and public awareness campaigns |
| Regional variation in police/API integration | Phase rollout market-by-market; fallback to "generate pre-filled report" where no API integration exists |

## 13. Roadmap (Phased)

**Phase 1 (0–4 months) — Core + Offline Resilience**
Core MVP feature set + SMS/USSD fallback + low-battery pre-arm mode.

**Phase 2 (4–8 months) — Guardian Network Launch**
Guardian vetting pipeline, proximity-based alert routing, pilot in 2–3 cities with NGO/local business partnerships.

**Phase 3 (8–12 months) — Full Incident Lifecycle**
Tamper-evident evidence capture, police API integrations (market-by-market), legal-aid/counseling partner network.

**Phase 4 (12–18 months) — Passive AI Protection & Scale**
On-device distress detection, predictive route risk, feature-phone/IVR expansion via carrier partnerships, B2B/B2G rollout.

## 14. Open Questions for Stakeholder Review
- Which markets should pilot the Guardian Network first, and what background-check infrastructure is realistically available there?
- Which telecom partners are needed for USSD/short-code access, and what does that commercial relationship look like?
- What is the right liability/insurance framework for volunteer Guardians?
- How should the app handle jurisdictions with no digital police-reporting API at all?
