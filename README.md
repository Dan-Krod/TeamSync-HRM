# TeamSync-HRM - Human Resource Management System (HRM)

StaffFlow is a comprehensive HRM web application designed to streamline employee management, time tracking, and HR processes. The system provides a unified platform for both administrators and employees to manage daily HR operations efficiently.

## 🚀 Features

*   **Employee Directory:** Complete records including personal details, contact info, job titles, and department hierarchy.
*   **Leave Management:** Automated request and approval workflows for vacations, sick leaves, and business trips.
*   **Time & Attendance:** Work schedule tracking and daily presence logging.
*   **Recruitment System:** Job vacancy management and applicant tracking.
*   **Document Management:** Secure storage for HR documents, contracts, and internal orders.
*   **Employee Self-Service Portal:** A personal dashboard for employees to submit leave requests, view salary details, and track their schedule.
*   **HR Analytics & Reporting:** Real-time dashboards generating reports on departmental headcount, payroll expenses, and leave statistics.

## 🛠 Tech Stack (To Be Updated)

*   **Backend:** Python (REST API)
*   **Frontend:** Flutter Web / HTML
*   **Database:** PostgreSQL / SQLite
*   **Architecture & Patterns:** GoF Design Patterns, GRASP, SOLID principles.

## 🏗 System Architecture & Use Cases

The application architecture relies on a strict separation of concerns among different user roles (Employees, Managers, HR, Candidates) and external APIs. 

### 1. Business Processes (Use Cases)
Defines user roles and core system workflows (`<<include>>` and `<<extend>>`).
* 📄 [Read Use Case Documentation](docs/use_cases.md)
* 🖼️ **Diagram:** `docs/diagrams/use_case.png`

### 2. Class Architecture (UML & GoF Patterns)
Illustrates the Layered Architecture, REST controllers, and the implementation of 5 GoF patterns (Facade, State, Strategy, Composite, Factory Method) adhering to SOLID principles.
* 📄 [Read Class Architecture Documentation](docs/class_diagram.md)
* 🖼️ **Diagram:** `docs/diagrams/class.png`

### 3. Database Schema (ER Diagram)
A robust relational database schema consisting of 8 tables, designed to support multiple business roles and modular scaling (e.g., isolated recruitment data).
* 📄 [Read Database Schema Documentation](docs/database_schema.md)
* 🖼️ **Diagram:** `docs/database/schema.png`

## 📂 Project Structure

*(To be populated as the project evolves)*

## ⚙️ Setup Instructions

*(To be added)*