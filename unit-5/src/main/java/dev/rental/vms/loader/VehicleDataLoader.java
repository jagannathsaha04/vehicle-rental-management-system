package dev.rental.vms.loader;

import dev.rental.vms.entity.Vehicle;
import dev.rental.vms.repository.VehicleRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class VehicleDataLoader implements CommandLineRunner {

    private final VehicleRepository vehicleRepository;

    public VehicleDataLoader(VehicleRepository vehicleRepository) {
        this.vehicleRepository = vehicleRepository;
    }

    @Override
    public void run(String... args) {
        try {
            if (vehicleRepository.count() == 0) {
                List<Vehicle> sampleFleet = Arrays.asList(
                    new Vehicle(null, "KA-01-EA-2024", "Toyota", "Camry Hybrid", "Sedan", "Hybrid", 65.0, "AVAILABLE", 5, null, 14200),
                    new Vehicle(null, "MH-02-CB-1988", "Tesla", "Model 3 Long Range", "Electric", "Electric", 95.0, "RENTED", 5, "Vikram Malhotra", 22150),
                    new Vehicle(null, "DL-04-AB-7744", "Hyundai", "Creta SX", "SUV", "Petrol", 55.0, "AVAILABLE", 5, null, 31000),
                    new Vehicle(null, "TN-07-JK-3030", "BMW", "330i M Sport", "Luxury", "Petrol", 140.0, "RENTED", 5, "Ananya Iyer", 18400),
                    new Vehicle(null, "KA-05-MN-9922", "Mahindra", "Thar 4x4", "SUV", "Diesel", 75.0, "MAINTENANCE", 4, null, 27800),
                    new Vehicle(null, "DL-01-XY-5511", "Mercedes-Benz", "C-Class", "Luxury", "Petrol", 160.0, "AVAILABLE", 5, null, 12600),
                    new Vehicle(null, "MH-12-PQ-4412", "Tata", "Nexon EV Max", "Electric", "Electric", 60.0, "AVAILABLE", 5, null, 19500),
                    new Vehicle(null, "HR-26-ZZ-8181", "Ford", "Mustang GT 5.0", "Sports", "Petrol", 210.0, "RENTED", 4, "Rohan Verma", 15800)
                );

                vehicleRepository.saveAll(sampleFleet);
                System.out.println(">> Unit 5: Successfully seeded " + sampleFleet.size() + " sample fleet vehicles into the database.");
            }
        } catch (Exception e) {
            System.err.println(">> Unit 5 Notice: Database initialization notice: " + e.getMessage());
        }
    }
}
