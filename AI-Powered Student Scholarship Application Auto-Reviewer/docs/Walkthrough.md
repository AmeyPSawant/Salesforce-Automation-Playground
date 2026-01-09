# Walkthrough – AI-Powered Student Scholarship Application Auto-Reviewer

This walkthrough documents the exact build steps of the automation from a Salesforce developer’s point of view.  
It focuses on Flow design, Apex integration, and execution order.

---

## Step 1: Create the Scholarship Application Object

Create a custom object:

**Object API Name:** `Scholarship_Application__c`

### Required Fields

- Applicant Name (Text)
- Email (Email)
- GPA (Number, 2 decimal)
- Essay (Long Text Area)
- Status (Picklist: New, Approved, Rejected, Manual Review)
- AI Sentiment Score (Number)
- AI Analysis (Long Text Area)
- Approval Reasoning (Long Text Area)

All AI outputs are written back to the record for transparency and auditability.

---

## Step 2: Seed Test Records

Create multiple Scholarship Application records manually:

- High GPA with a strong essay
- Low GPA with a weak essay
- Average GPA with an ambiguous essay

This is required because Flow Debug runs in rollback mode and does not persist changes.

---

## Step 3: Create the Record-Triggered Flow

### Flow Type

Record-Triggered Flow

### Trigger Configuration

- Object: Scholarship Application
- Trigger: When a record is created
- Entry Conditions:
  - Status equals `New`
  - Essay is not null
- Optimize for: Actions and Related Records

---

## Step 4: Add a Scheduled Path for AI Processing

Create a Scheduled Path named:

**AI Analysis Async**

- Offset: 0 minutes after record creation

The Immediate Path performs no actions and ends immediately.

This ensures:

- No record-locking conflicts
- Safe external callouts
- Production-style async execution

---

## Step 5: Get the Current Application Record

Inside the scheduled path, add a Get Records element:

- Object: Scholarship Application
- Filter: `Id = $Record.Id`
- Store: All fields
- Retrieve: Only the first record

This guarantees the Flow uses the latest committed data.

---

## Step 6: Build the AI Prompt

Add an Assignment element to construct the AI prompt.

The prompt includes:

- Applicant name
- GPA
- Essay content
- Explicit instructions requesting:
  - Sentiment score (0–100)
  - Strengths
  - Concerns
  - Recommendation
  - Reasoning

The completed prompt is stored in a Flow variable passed to Apex.

**Prompt Used**

```
You are a scholarship application reviewer. Analyze this application and provide: 1. Sentiment score (0-100) 2. Key strengths 3. Any concerns or red flags 4. Recommendation (APPROVE, REJECT, or MANUAL_REVIEW)  Applicant: {!$Record.Applicant_Name__c} GPA: {!$Record.GPA__c} Essay: {!$Record.Essay__c}  Respond in JSON format: score: number strengths: text concerns: text recommendation: APPROVE | REJECT | MANUAL_REVIEW reasoning: text
```

---

## Step 7: Call Hugging Face AI (Apex Action)

Add a custom Apex Action that:

- Sends the prompt to Hugging Face
- Handles authentication and HTTP headers
- Returns the raw AI response

All API logic is intentionally isolated in Apex to keep Flow readable.

---

## Step 8: Store the Raw AI Response

Add an Assignment element to:

- Capture the raw AI response text
- Store it in a Flow variable for downstream processing

This preserves traceability and simplifies debugging.

---

## Step 9: Extract Structured AI Data (Apex Action)

Add a second Apex Action that:

- Parses the AI response
- Extracts:
  - Sentiment score
  - Recommendation
  - Reasoning text

Each value is returned to Flow as a discrete output variable.

---

## Step 10: Route Based on AI Analysis

Add a Decision element with the following outcomes:

### Auto Approve

- GPA meets or exceeds the approval threshold
- AI recommendation is positive

### Auto Reject

- GPA falls below the rejection threshold
- AI recommendation is negative

### Manual Review

- Default outcome for all ambiguous cases

AI assists the decision but does not override deterministic business rules.

---

## Step 11: Update the Application Record

Each decision path uses an Update Records element to set:

- Status
- AI Sentiment Score
- AI Analysis
- Approval Reasoning

All AI-generated values are persisted on the record.

---

## Step 12: End the Flow

Each branch ends cleanly after updating the record.

The Flow is intentionally scoped to decisioning only.  
Notifications, tasks, or dashboards can be added later.

---

## Step 13: Validate with Real Records

Create new Scholarship Application records and:

- Wait for the scheduled path to execute
- Refresh the record
- Confirm:
  - Correct status update
  - AI fields populated
  - Expected routing behavior

---

## Step 14: Demo Execution Flow

For demos:

1. Create a new Scholarship Application
2. Show initial Status set to `New`
3. Wait for async execution
4. Refresh and show final decision and AI reasoning

---

## Final Result

- Flow handles orchestration
- Apex handles AI integration
- Decisions remain explainable
- Async execution mirrors production patterns
