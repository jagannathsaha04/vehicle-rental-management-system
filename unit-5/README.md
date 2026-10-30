# Unit 5: Vehicle Rental Management System (Final Full Stack Project)

A complete Full Stack Enterprise application with Spring Boot 3 REST API, MySQL database, interactive Swagger / OpenAPI documentation, and a state-of-the-art web frontend supporting full CRUD operations, live rental workflows, and real-time fleet analytics.

## Prerequisites
* Java 17 or Java 21
* Maven
* MySQL running on port 3306 (or runs immediately using the built-in zero-config H2 profile)

## How to Run

### 1. Database Setup (Optional)
The application automatically creates and updates tables using Hibernate. You can also import `database.sql` into MySQL if desired:
```bash
mysql -u root -p < database.sql
```

### 2. Configure Credentials
Update MySQL password in `src/main/resources/application.properties` if needed:
```properties
spring.datasource.password=your_password
```

### 3. Run Spring Boot Backend

**Option A — With MySQL:**
```bash
mvn spring-boot:run
```

**Option B — Instant Zero-Friction In-Memory Mode (No MySQL setup needed):**
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=h2
```

### 4. Open Website & API Docs
Visit in your browser:
* **Web Application:** `http://localhost:8081`
* **Swagger API Docs:** `http://localhost:8081/swagger-ui/index.html`

## CRUD Operations & Features Included
* **Create (POST):** Register new fleet vehicle with full validation via modal dialog.
* **Read (GET):** View all fleet vehicles, live keyword search/filter, and real-time KPI statistics.
* **Update (PUT):** Edit existing vehicle attributes (Daily Rate, Fuel, Mileage, Plate, Category) in real time.
* **Rent / Return (PATCH):** Complete rental checkout & return workflow with customer attribution.
* **Delete (DELETE):** Remove vehicle records with confirmation dialog.
* **Interactive Swagger UI:** Test all REST endpoints with interactive schemas directly in the browser.
