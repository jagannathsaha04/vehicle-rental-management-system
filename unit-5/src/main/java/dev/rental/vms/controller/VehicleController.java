package dev.rental.vms.controller;

import dev.rental.vms.entity.Vehicle;
import dev.rental.vms.service.VehicleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "*")
@Tag(name = "Vehicle Rental Controller", description = "Complete CRUD REST APIs for Vehicle Fleet and Rental Operations")
public class VehicleController {

    @Autowired
    private VehicleService vehicleService;

    // Backend health / info check
    @GetMapping("/api/status")
    @Operation(summary = "Check backend and database health status")
    public Map<String, Object> getStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("connected", true);
        status.put("message", "Spring Boot Final CRUD Backend is running on port 8081");
        status.put("database", "MySQL (vehicle_rental_db)");
        status.put("swaggerDocs", "/swagger-ui/index.html");
        return status;
    }

    // READ: Get all vehicles
    @GetMapping({"/api/vehicles", "/getAll"})
    @Operation(summary = "Get list of all vehicles in fleet")
    public List<Vehicle> getAllVehicles() {
        return vehicleService.getAllVehicles();
    }

    // READ: Get vehicle by ID
    @GetMapping({"/api/vehicles/{id}", "/getVehicle/{id}"})
    @Operation(summary = "Get a specific vehicle by ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Vehicle found"),
        @ApiResponse(responseCode = "404", description = "Vehicle not found")
    })
    public ResponseEntity<?> getVehicleById(@PathVariable @Parameter(description = "Vehicle ID") int id) {
        Optional<Vehicle> vehicle = vehicleService.getVehicleById(id);
        if (vehicle.isPresent()) {
            return ResponseEntity.ok(vehicle.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Vehicle not found with ID: " + id);
    }

    // CREATE: Add new vehicle
    @PostMapping({"/api/vehicles", "/addVehicle"})
    @Operation(summary = "Create / Register a new vehicle in fleet")
    @ApiResponse(responseCode = "201", description = "Vehicle registered successfully")
    public ResponseEntity<Vehicle> addVehicle(@RequestBody Vehicle vehicle) {
        Vehicle saved = vehicleService.saveVehicle(vehicle);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // UPDATE: Update existing vehicle details
    @PutMapping({"/api/vehicles/{id}", "/updateVehicle/{id}"})
    @Operation(summary = "Update an existing vehicle details by ID")
    public ResponseEntity<?> updateVehicle(@PathVariable int id, @RequestBody Vehicle vehicle) {
        try {
            Vehicle updated = vehicleService.updateVehicle(id, vehicle);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    // PATCH: Toggle rental status (Rent / Return)
    @PatchMapping({"/api/vehicles/{id}/status", "/toggleRental/{id}"})
    @Operation(summary = "Toggle vehicle rental status (AVAILABLE, RENTED, MAINTENANCE)")
    public ResponseEntity<?> toggleRentalStatus(
            @PathVariable int id,
            @RequestBody Map<String, String> payload) {
        String newStatus = payload.getOrDefault("status", "AVAILABLE");
        String renterName = payload.get("renterName");
        try {
            Vehicle updated = vehicleService.toggleRentalStatus(id, newStatus, renterName);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    // DELETE: Delete vehicle by ID
    @DeleteMapping({"/api/vehicles/{id}", "/deleteVehicle/{id}"})
    @Operation(summary = "Delete a vehicle record from fleet by ID")
    public ResponseEntity<String> deleteVehicle(@PathVariable int id) {
        try {
            vehicleService.deleteVehicle(id);
            return ResponseEntity.ok("Vehicle deleted successfully with ID: " + id);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    // SEARCH: Search vehicles by keyword
    @GetMapping("/api/vehicles/search")
    @Operation(summary = "Search vehicles by Make, Model, License Plate, Category, or Fuel")
    public List<Vehicle> searchVehicles(@RequestParam("query") @Parameter(description = "Search keyword") String query) {
        return vehicleService.searchVehicles(query);
    }

    // STATS: Get summary statistics for dashboard
    @GetMapping("/api/vehicles/stats")
    @Operation(summary = "Get live fleet summary stats for dashboard cards")
    public Map<String, Object> getStats() {
        return vehicleService.getStatistics();
    }
}
