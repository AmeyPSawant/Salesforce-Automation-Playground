# AI-Powered Student Scholarship Application Auto-Reviewer

### 📌 Project Overview

This project demonstrates how **Salesforce** can be used to automate the initial review of student scholarship applications using AI-assisted analysis.

The system:

- Accepts scholarship applications
- Analyzes essays using AI (sentiment + reasoning)
- Auto-approves, rejects, or flags applications for manual review
- Logs AI decisions transparently for auditability

This project focuses on Salesforce Flow, clean data modeling, and AI-readiness rather than just UI clicks.

<hr>

### 🎯 Problem Statement

Scholarship committees often receive hundreds of applications. Manual screening is:

- Time-consuming
- Inconsistent
- Prone to bias or fatigue

This solution automates the first-pass review, allowing human reviewers to focus only on edge cases.

<hr>

### 🛠️ Tech Stack

- Salesforce Developer Org
- Education Data Architecture (EDA)
- Salesforce Flow (Record-Triggered + Screen Flow)
- Custom Objects & Fields
- AI integration-ready design (Einstein / External LLM via Apex in later phase)
- GitHub for documentation and version control (GitHub)

<hr>

### 🧩 Architecture Overview (High Level)

1. A student submits a Scholarship Application in Salesforce
2. A record-triggered Flow automatically starts
3. The application essay is sent to an AI service for analysis
4. AI insights are evaluated against business rules
5. The application is approved, rejected, or routed for human review
6. Applicants and reviewers are notified automatically

<hr>

### 🎥 Demo Walkthrough

A short demo showing:

- Submission of a scholarship application
- AI-driven evaluation
- Automatic decision routing
- Notifications and reviewer task creation

▶️ Demo Video: [Click here](https://www.youtube.com/watch?v=Psoa1toGyQ8)
