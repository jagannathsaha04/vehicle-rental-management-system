# Vehicle Rental Management System

A 5-Unit progressive Full Stack Development project demonstrating the evolution from static web pages to a full-fledged Spring Boot & MySQL enterprise application, accompanied by a comprehensive relational SQL database analytics package.

---

## 📁 Unit Overview

| Unit | Title | Technologies | Description |
| :--- | :--- | :--- | :--- |
| **[Unit 1](./unit-1)** | Frontend Basics | HTML5, CSS3 | Static fleet dashboard, vehicle records table, badges, and add vehicle form. |
| **[Unit 2](./unit-2)** | Client-side Scripting | HTML5, CSS3, JavaScript | Form validation (license plate regex, rate bounds), dynamic DOM fleet table, search filter, and localStorage. |
| **[Unit 3](./unit-3)** | Database Connectivity | HTML, CSS, JS, MySQL, Express | Connects MySQL database (`vehicle_rental_db`) directly to the website via Node.js/Express. |
| **[Unit 4](./unit-4)** | Backend Integration | Spring Boot 3, REST API, MySQL | Connects Spring Boot REST backend (`port 8081`) with the web interface. |
| **[Unit 5](./unit-5)** | Full CRUD Final Project | Spring Boot 3, JPA, MySQL, Web UI, Swagger | Complete enterprise application with Create, Read, Update, Delete, live fleet analytics & Swagger documentation. |
| **[SQL Project](./vehicle-rental-sql)** | Database Architecture & Analytics | MySQL, Relational Design | 10 business queries, ER diagram, stored procedures, triggers, and automated rental calculation. |

---

## 🚀 Quick Start by Unit

* **Unit 1:** Open `unit-1/index.html` in your web browser.
* **Unit 2:** Open `unit-2/index.html` in your web browser.
* **Unit 3:** In `unit-3/`: run `npm install && npm start`, then open `http://localhost:3000`.
* **Unit 4:** In `unit-4/`: run `mvn spring-boot:run` (or with H2: `mvn spring-boot:run -Dspring-boot.run.profiles=h2`), then open `http://localhost:8081`.
* **Unit 5:** In `unit-5/`: run `mvn spring-boot:run` (or with H2: `mvn spring-boot:run -Dspring-boot.run.profiles=h2`), then open `http://localhost:8081`.
  * **Swagger UI:** `http://localhost:8081/swagger-ui.html`

---

## 🚗 Domain Model: Fleet & Rental Attributes

Each vehicle record in the system contains:
* **Registration / License Plate:** Unique identifier (e.g., `KA-01-EA-2024`, `MH-02-CB-1988`)
* **Make & Model:** Vehicle manufacturer and model name (e.g., `Toyota Camry Hybrid`, `Tesla Model 3`)
* **Category:** Vehicle classification (`Sedan`, `SUV`, `Electric`, `Luxury`, `Sports`)
* **Daily Rate ($/day):** Pricing rate for rental
* **Fuel Type:** `Petrol`, `Diesel`, `Electric`, `Hybrid`
* **Status:** `AVAILABLE`, `RENTED`, `MAINTENANCE`
* **Seating Capacity:** 4, 5, 7 seats
* **Mileage:** Odometer reading in kilometers
* **Renter Details:** Current customer renting the vehicle (when status is RENTED)
