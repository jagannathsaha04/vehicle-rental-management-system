package dev.rental.vms.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "vehicles")
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "registration_number", nullable = false, unique = true)
    private String registrationNumber;

    @Column(name = "make", nullable = false)
    private String make;

    @Column(name = "model", nullable = false)
    private String model;

    @Column(name = "category", nullable = false)
    private String category;

    @Column(name = "fuel_type")
    private String fuelType = "Petrol";

    @Column(name = "daily_rate", nullable = false)
    private Double dailyRate;

    @Column(name = "status", nullable = false)
    private String status = "AVAILABLE";

    @Column(name = "seating_capacity")
    private Integer seatingCapacity = 5;

    @Column(name = "renter_name")
    private String renterName;

    @Column(name = "mileage")
    private Integer mileage = 15000;

    // Default Constructor
    public Vehicle() {
    }

    // Parameterized Constructor
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
                '}';
    }
}
