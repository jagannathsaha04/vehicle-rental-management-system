package dev.rental.vms.repository;

import dev.rental.vms.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Integer> {

    @Query("SELECT v FROM Vehicle v WHERE UPPER(v.registrationNumber) = UPPER(:reg)")
    Optional<Vehicle> findByRegistrationNumber(@Param("reg") String reg);

    List<Vehicle> findByStatus(String status);

    List<Vehicle> findByCategoryIgnoreCase(String category);

    @Query("SELECT v FROM Vehicle v WHERE " +
           "LOWER(v.make) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(v.model) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(v.registrationNumber) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(v.category) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(v.fuelType) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Vehicle> searchVehicles(@Param("query") String query);
}
