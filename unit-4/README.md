# Unit 4: Vehicle Rental Management System (Spring Boot + Website)

Connects a Spring Boot 3 RESTful API backend (`port 8081`) with a modern interactive web frontend.

## Prerequisites
* Java 17 or Java 21
* Maven
* MySQL (or runs immediately using the built-in zero-config H2 profile)

## Setup Steps

### 1. Database Configuration
Update MySQL credentials in `src/main/resources/application.properties` if needed:
```properties
spring.datasource.password=your_password
```

### 2. Run Spring Boot Backend
Open a terminal in the `unit-4` directory and run:

**With MySQL:**
```bash
mvn spring-boot:run
```

**Zero-Friction In-Memory Mode (No MySQL setup needed):**
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=h2
```
*(Or run `VehicleRentalApplication.java` directly in your IDE).*

### 3. Open Website
Open your browser at:
```
http://localhost:8081
```
*(Or open `frontend/index.html` in your browser).*

## Key REST Endpoints
* `GET    /api/vehicles` - Retrieve all vehicles
* `GET    /api/vehicles/{id}` - Retrieve specific vehicle by ID
* `POST   /api/vehicles` - Add new vehicle to fleet
* `PUT    /api/vehicles/{id}` - Update vehicle details
* `PATCH  /api/vehicles/{id}/status` - Toggle rent/return status
* `DELETE /api/vehicles/{id}` - Delete vehicle from fleet
* `GET    /api/vehicles/search?query=...` - Live search filter
* `GET    /api/vehicles/stats` - Summary KPI statistics
