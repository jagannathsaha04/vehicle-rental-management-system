package dev.rental.vms.service;

import dev.rental.vms.entity.Vehicle;
import dev.rental.vms.repository.VehicleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class VehicleService {

    @Autowired
    private VehicleRepository vehicleRepository;

    // Get all vehicles
    public List<Vehicle> getAllVehicles() {
        return vehicleRepository.findAll();
    }

    // Get vehicle by ID
    public Optional<Vehicle> getVehicleById(int id) {
        return vehicleRepository.findById(id);
    }

    // Save vehicle (Create)
    public Vehicle saveVehicle(Vehicle vehicle) {
        if (vehicle.getRegistrationNumber() != null) {
            vehicle.setRegistrationNumber(vehicle.getRegistrationNumber().trim().toUpperCase());
        }
        if (vehicle.getStatus() == null || vehicle.getStatus().isBlank()) {
            vehicle.setStatus("AVAILABLE");
        }
        return vehicleRepository.save(vehicle);
    }

    // Update vehicle (Update)
    public Vehicle updateVehicle(int id, Vehicle vehicleDetails) {
        Vehicle existing = vehicleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Vehicle not found with ID: " + id));

        if (vehicleDetails.getMake() != null && !vehicleDetails.getMake().isBlank()) {
            existing.setMake(vehicleDetails.getMake());
        }
        if (vehicleDetails.getModel() != null && !vehicleDetails.getModel().isBlank()) {
            existing.setModel(vehicleDetails.getModel());
        }
        if (vehicleDetails.getRegistrationNumber() != null && !vehicleDetails.getRegistrationNumber().isBlank()) {
            existing.setRegistrationNumber(vehicleDetails.getRegistrationNumber().trim().toUpperCase());
        }
        if (vehicleDetails.getCategory() != null && !vehicleDetails.getCategory().isBlank()) {
            existing.setCategory(vehicleDetails.getCategory());
        }
        if (vehicleDetails.getFuelType() != null && !vehicleDetails.getFuelType().isBlank()) {
            existing.setFuelType(vehicleDetails.getFuelType());
        }
        if (vehicleDetails.getDailyRate() != null && vehicleDetails.getDailyRate() > 0) {
            existing.setDailyRate(vehicleDetails.getDailyRate());
        }
        if (vehicleDetails.getStatus() != null && !vehicleDetails.getStatus().isBlank()) {
            existing.setStatus(vehicleDetails.getStatus());
        }
        if (vehicleDetails.getSeatingCapacity() != null) {
            existing.setSeatingCapacity(vehicleDetails.getSeatingCapacity());
        }
        if (vehicleDetails.getRenterName() != null) {
            existing.setRenterName(vehicleDetails.getRenterName());
        }
        if (vehicleDetails.getMileage() != null) {
            existing.setMileage(vehicleDetails.getMileage());
        }

        return vehicleRepository.save(existing);
    }

    // Toggle rental status
    public Vehicle toggleRentalStatus(int id, String newStatus, String renterName) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Vehicle not found with ID: " + id));

        vehicle.setStatus(newStatus);
        if ("RENTED".equalsIgnoreCase(newStatus)) {
            vehicle.setRenterName(renterName != null && !renterName.isBlank() ? renterName.trim() : "Walk-in Customer");
        } else {
            vehicle.setRenterName(null);
        }

        return vehicleRepository.save(vehicle);
    }

    // Delete vehicle (Delete)
    public void deleteVehicle(int id) {
        if (!vehicleRepository.existsById(id)) {
            throw new IllegalArgumentException("Cannot delete: Vehicle not found with ID: " + id);
        }
        vehicleRepository.deleteById(id);
    }

    // Search vehicles
    public List<Vehicle> searchVehicles(String query) {
        if (query == null || query.trim().isEmpty()) {
            return vehicleRepository.findAll();
        }
        return vehicleRepository.searchVehicles(query.trim());
    }

    // Dashboard Statistics
    public Map<String, Object> getStatistics() {
        List<Vehicle> all = vehicleRepository.findAll();
        int available = 0;
        int rented = 0;
        int maintenance = 0;
        double totalRate = 0.0;
        Set<String> categories = new HashSet<>();

        for (Vehicle v : all) {
            if ("AVAILABLE".equalsIgnoreCase(v.getStatus())) available++;
            else if ("RENTED".equalsIgnoreCase(v.getStatus())) rented++;
            else if ("MAINTENANCE".equalsIgnoreCase(v.getStatus())) maintenance++;

            if (v.getDailyRate() != null) {
                totalRate += v.getDailyRate();
            }
            if (v.getCategory() != null && !v.getCategory().isBlank()) {
                categories.add(v.getCategory());
            }
        }

        double avgRate = !all.isEmpty() ? (totalRate / all.size()) : 0.0;

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalFleet", all.size());
        stats.put("available", available);
        stats.put("rented", rented);
        stats.put("maintenance", maintenance);
        stats.put("totalCategories", categories.size());
        stats.put("averageDailyRate", Math.round(avgRate * 100.0) / 100.0);
        return stats;
    }
}
