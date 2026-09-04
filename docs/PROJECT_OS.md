# شَطّبها — Project Operating System

Arabic-first product spec for the finishing / contracting **Project OS**.  
UX rule for every screen: **status → next action → owner → deadline → approval / money / time impact?**

Source: business process document (Lead → Warranty), simplified for mobile.

---

## 1. Product model

Four connected pipes around one **Project**:

| Pipe | Purpose |
| --- | --- |
| Sales | Lead → visit → estimate → proposal → contract → initial payment |
| Delivery | Design → selections → approval → schedule → site → inspection |
| Procurement & ops | BOQ → RFQ/PO → delivery → warehouse → contractors |
| Finance | Client installments, contractor payments, cost vs contract, cash signals |

Roles: **Company** (admin/clerk), **Client**, **Contractor**, **Supplier**.

---

## 2. Lifecycle

### Lead statuses
`new` → `contacted` → `site_visit_scheduled` → `visited` → `estimating` → `proposal_sent` → `negotiation` → `won` | `lost`

### Project statuses (after Won)
`contracted` → `survey` → `design` → `selections` → `approved` → `procurement` → `execution` → `inspection` → `snagging` → `handover` → `warranty` → `closed`

Every stage has: status, responsible, deadline, dependencies, documents, financial impact.

---

## 3. Simplified happy paths

### A — Win a deal (company)
1. Create **Lead** (name, phone, email, location, area, finish type, budget).
2. Schedule **Site Visit** + checklist + photos.
3. Enter estimate (**cost** vs **selling price**).
4. Send **Proposal** → negotiate → **Contract** + **Payment Plan**.
5. Record initial installment paid → create **Customer** + **Project** (wizard).

### B — Design & selections (company + client)
1. Company builds design version (inspiration / plans / BOQ).
2. Submit for client review; client approves or requests changes (new version).
3. Client completes **Selections** (tiles, sanitary, doors, paint…).
4. Lock approved design; BOQ may freeze when design-driven.

### C — Change order
Request → price + schedule impact → client approve → optional deposit → apply to BOQ/schedule/payments.

### D — Execute
Schedule tasks/milestones → daily site logs → materials Ordered→Delivered→Issued → progress by trade → inspections → snags → handover package → warranty.

### E — Client day-to-day
One hub: **Progress · Approvals · Payments · Documents**. No cost/margin.

---

## 4. Business rules

1. No site execution unlock without **approved Contract** + required **initial payment**.
2. Final BOQ approval waits on design approval when BOQ is design-based.
3. No purchase of selection-required materials until selection is approved.
4. No Change Order execution without client approval when price or duration changes.
5. Price/duration changes always create a visible Change Order / revision.
6. Material track: Required → Ordered → Delivered → Issued → Consumed → Remaining.
7. Tasks need start, due, assignee, status (optional predecessor).
8. Project cannot close with open **critical** snags.
9. Handover requires final inspection + client approval + required payment + certificate (per contract).
10. Sensitive money/time/approval events append to **Audit Trail**.
11. Parties/projects isolated by `company_id`.
12. Client only sees own projects (`customer_id` ↔ `party_id`).

---

## 5. Screens by role (simple)

### Company
- **Home = المطلوب الآن** (approvals, overdue tasks, payments due, delayed materials)
- Leads, Customers, Projects (status + next action)
- Design / Selections / Change Orders
- Schedule, Daily Logs, Procurement, Warehouse
- Payments, Reports, Handover, Warranty
- Modules under المزيد when not “next action”

### Client
- My project · Progress · Schedule · Design · Selections · Approvals · Payments · Documents · Photos · Requests · Snags · Handover · Warranty

### Contractor
- Jobs · RFQs · Quotes · Tasks · Schedule · Docs · Material requests · Progress · Payment status

### Supplier
- Products · RFQs · POs · Deliveries · Invoices · Payments

---

## 6. Phase acceptance

| Phase | Done when |
| --- | --- |
| 0 | Spec in repo + Jira POS epics/stories replace legacy |
| 1 | Lifecycle status on project; Action Required homes; next-action hub; execution gate |
| 2 | Lead→Contract→Payment Plan wizard creates project |
| 3 | Design versions, selections, change orders end-to-end |
| 4 | Daily logs, snag→handover gate, warranty claims; material state chain |
| 5 | Financial strip, paid-vs-progress, audit trail, command-center aggregates |

---

## 7. Entity map (core)

Lead, SiteVisit, Proposal, Contract, PaymentInstallment, Project (lifecycle_status), DesignVersion, ClientSelection, ChangeOrder, DailySiteLog, WarrantyClaim, ProjectAuditEvent — plus existing Party, DesignBoard/Plans/BOQ, Quote, PO, Warehouse, Milestone/Task, Snag, Handover.
