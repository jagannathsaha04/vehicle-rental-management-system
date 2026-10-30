package dev.rental.vms.controller;

import dev.rental.vms.entity.Vehicle;
import dev.rental.vms.service.VehicleService;
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
public class VehicleController {

    @Autowired
    private VehicleService vehicleService;

    // Backend health / info check
    @GetMapping("/api/status")
    public Map<String, Object> getStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("connected", true);
        status.put("message", "Spring Boot Vehicle Rental REST API is running on port 8081");
        status.put("system", "Vehicle Rental Management System (Unit 4)");
        return status;
    }

    // READ: Get all vehicles
    @GetMapping({"/api/vehicles", "/getAll"})
    public List<Vehicle> getAllVehicles() {
        return vehicleService.getAllVehicles();
    }

    // READ: Get vehicle by ID
    @GetMapping({"/api/vehicles/{id}", "/getVehicle/{id}"})
    public ResponseEntity<?> getVehicleById(@PathVariable int id) {
        Optional<Vehicle> vehicle = vehicleService.getVehicleById(id);
        if (vehicle.isPresent()) {
            return ResponseEntity.ok(vehicle.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Vehicle not found with ID: " + id);
    }

    // CREATE: Add new vehicle
    @PostMapping({"/api/vehicles", "/addVehicle"})
    public ResponseEntity<Vehicle> addVehicle(@RequestBody Vehicle vehicle) {
        Vehicle saved = vehicleService.saveVehicle(vehicle);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // UPDATE: Update vehicle details
    @PutMapping({"/api/vehicles/{id}", "/updateVehicle/{id}"})
    public ResponseEntity<?> updateVehicle(@PathVariable int id, @RequestBody Vehicle vehicle) {
        try {
            Vehicle updated = vehicleService.updateVehicle(id, vehicle);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    // PATCH: Toggle rental status
    @PatchMapping("/api/vehicles/{id}/status")
    public ResponseEntity<?> toggleRentalStatus(@PathVariable int id, @RequestBody Map<String, String> payload) {
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
    public List<Vehicle> searchVehicles(@RequestParam("query") String query) {
        return vehicleService.searchVehicles(query);
    }

    // STATS: Get summary statistics for dashboard cards
    @GetMapping("/api/vehicles/stats")
    public Map<String, Object> getStats() {
        return vehicleService.getStatistics();
    }
}
