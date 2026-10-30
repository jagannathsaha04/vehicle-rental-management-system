package dev.rental.vms.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;

@Entity
@Table(name = "vehicles")
@Schema(description = "Vehicle entity representing a fleet asset")
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique Database ID", example = "1")
    private Integer id;

    @Column(name = "registration_number", nullable = false, unique = true)
    @Schema(description = "License Plate / Registration Code", example = "KA-01-EA-2024")
    private String registrationNumber;

    @Column(name = "make", nullable = false)
    @Schema(description = "Vehicle Manufacturer / Brand", example = "Toyota")
    private String make;

    @Column(name = "model", nullable = false)
    @Schema(description = "Model Name", example = "Camry Hybrid")
    private String model;

    @Column(name = "category", nullable = false)
    @Schema(description = "Category (Sedan, SUV, Electric, Luxury, Sports)", example = "Sedan")
    private String category;

    @Column(name = "fuel_type")
    @Schema(description = "Fuel Type (Petrol, Diesel, Electric, Hybrid)", example = "Hybrid")
    private String fuelType = "Petrol";

    @Column(name = "daily_rate", nullable = false)
    @Schema(description = "Daily Rental Price in USD", example = "65.0")
    private Double dailyRate;

    @Column(name = "status", nullable = false)
    @Schema(description = "Availability Status (AVAILABLE, RENTED, MAINTENANCE)", example = "AVAILABLE")
    private String status = "AVAILABLE";

    @Column(name = "seating_capacity")
    @Schema(description = "Passenger Seating Capacity", example = "5")
    private Integer seatingCapacity = 5;

    @Column(name = "renter_name")
    @Schema(description = "Name of the Active Customer Renter (if rented)", example = "Vikram Malhotra")
    private String renterName;

    @Column(name = "mileage")
    @Schema(description = "Current Odometer Mileage (km)", example = "14200")
    private Integer mileage = 15000;

    // Constructors
    public Vehicle() {
    }

    public Vehicle(Integer id, String registrationNumber, String make, String model,
                   String category, String fuelType, Double dailyRate, String status,
                   Integer seatingCapacity, String renterName, Integer mileage) {
        this.id = id;
        this.registrationNumber = registrationNumber;
        this.make = make;
        this.model = model;
        this.category = category;
        this.fuelType = fuelType;
        this.dailyRate = dailyRate;
        this.status = status != null ? status : "AVAILABLE";
        this.seatingCapacity = seatingCapacity != null ? seatingCapacity : 5;
        this.renterName = renterName;
        this.mileage = mileage != null ? mileage : 15000;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getRegistrationNumber() {
        return registrationNumber;
    }

    public void setRegistrationNumber(String registrationNumber) {
        this.registrationNumber = registrationNumber;
    }

    public String getMake() {
        return make;
    }

    public void setMake(String make) {
        this.make = make;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getFuelType() {
        return fuelType;
    }

    public void setFuelType(String fuelType) {
        this.fuelType = fuelType;
    }

    public Double getDailyRate() {
        return dailyRate;
    }

    public void setDailyRate(Double dailyRate) {
        this.dailyRate = dailyRate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getSeatingCapacity() {
        return seatingCapacity;
    }

    public void setSeatingCapacity(Integer seatingCapacity) {
        this.seatingCapacity = seatingCapacity;
    }

    public String getRenterName() {
        return renterName;
    }

    public void setRenterName(String renterName) {
        this.renterName = renterName;
    }

    public Integer getMileage() {
        return mileage;
    }

    public void setMileage(Integer mileage) {
        this.mileage = mileage;
    }

    @Override
    public String toString() {
        return "Vehicle{" +
                "id=" + id +
                ", registrationNumber='" + registrationNumber + '\'' +
                ", make='" + make + '\'' +
                ", model='" + model + '\'' +
                ", category='" + category + '\'' +
                ", dailyRate=" + dailyRate +
                ", status='" + status + '\'' +
                ", renterName='" + renterName + '\'' +
                '}';
    }
}
