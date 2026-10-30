// ============================================================
// Vehicle Rental Management System - Unit 2 JavaScript
// DOM Manipulation, Form Validation, Real-Time Filtering & LocalStorage
// ============================================================

// Initial sample fleet
const initialFleet = [
    {
        id: 1,
        registrationNumber: "KA-01-EA-2024",
        make: "Toyota",
        model: "Camry Hybrid",
        category: "Sedan",
        fuelType: "Hybrid",
        dailyRate: 65.0,
        status: "AVAILABLE",
        seatingCapacity: 5
    },
    {
        id: 2,
        registrationNumber: "MH-02-CB-1988",
        make: "Tesla",
        model: "Model 3 Long Range",
        category: "Electric",
        fuelType: "Electric",
        dailyRate: 95.0,
        status: "RENTED",
        seatingCapacity: 5
    },
    {
        id: 3,
        registrationNumber: "DL-04-AB-7744",
        make: "Hyundai",
        model: "Creta SX",
        category: "SUV",
        fuelType: "Petrol",
        dailyRate: 55.0,
        status: "AVAILABLE",
        seatingCapacity: 5
    },
    {
        id: 4,
        registrationNumber: "TN-07-JK-3030",
        make: "BMW",
        model: "330i M Sport",
        category: "Luxury",
        fuelType: "Petrol",
        dailyRate: 140.0,
        status: "RENTED",
        seatingCapacity: 5
    },
    {
        id: 5,
        registrationNumber: "KA-05-MN-9922",
        make: "Mahindra",
        model: "Thar 4x4",
        category: "SUV",
        fuelType: "Diesel",
        dailyRate: 75.0,
        status: "MAINTENANCE",
        seatingCapacity: 4
    },
    {
        id: 6,
        registrationNumber: "DL-01-XY-5511",
        make: "Mercedes-Benz",
        model: "C-Class",
        category: "Luxury",
        fuelType: "Petrol",
        dailyRate: 160.0,
        status: "AVAILABLE",
        seatingCapacity: 5
    },
    {
        id: 7,
        registrationNumber: "MH-12-PQ-4412",
        make: "Tata",
        model: "Nexon EV Max",
        category: "Electric",
        fuelType: "Electric",
        dailyRate: 60.0,
        status: "AVAILABLE",
        seatingCapacity: 5
    },
    {
        id: 8,
        registrationNumber: "HR-26-ZZ-8181",
        make: "Ford",
        model: "Mustang GT 5.0",
        category: "Sports",
        fuelType: "Petrol",
        dailyRate: 210.0,
        status: "RENTED",
        seatingCapacity: 4
    }
];

// Initialize fleet from LocalStorage or default
let fleet = JSON.parse(localStorage.getItem("vms_fleet"));
if (!fleet || fleet.length === 0) {
    fleet = [...initialFleet];
    saveFleet();
}

// DOM Elements
const vehicleForm = document.getElementById("vehicleForm");
const plateInput = document.getElementById("plateNumber");
const makeInput = document.getElementById("make");
const modelInput = document.getElementById("model");
const categorySelect = document.getElementById("category");
const fuelTypeSelect = document.getElementById("fuelType");
const dailyRateInput = document.getElementById("dailyRate");
const seatingSelect = document.getElementById("seatingCapacity");
const resetFormBtn = document.getElementById("resetFormBtn");
const resetFleetBtn = document.getElementById("resetFleetBtn");
const searchInput = document.getElementById("searchInput");
const tableBody = document.getElementById("vehicleTableBody");
const totalCount = document.getElementById("totalCount");
const noRecords = document.getElementById("noRecords");
const alertBox = document.getElementById("alertBox");

// Stat Elements
const statTotal = document.getElementById("statTotal");
const statAvailable = document.getElementById("statAvailable");
const statRented = document.getElementById("statRented");
const statAvgRate = document.getElementById("statAvgRate");

// Helper: Save to LocalStorage
function saveFleet() {
    localStorage.setItem("vms_fleet", JSON.stringify(fleet));
}

// Update Real-time KPI Stats
function updateStats() {
    const total = fleet.length;
    const available = fleet.filter(v => v.status === "AVAILABLE").length;
    const rented = fleet.filter(v => v.status === "RENTED").length;
    const totalRate = fleet.reduce((acc, v) => acc + (parseFloat(v.dailyRate) || 0), 0);
    const avgRate = total > 0 ? (totalRate / total) : 0;

    statTotal.textContent = total;
    statAvailable.textContent = available;
    statRented.textContent = rented;
    statAvgRate.textContent = `$${avgRate.toFixed(2)}`;
}

// Render Fleet in Table
function renderTable(list) {
    tableBody.innerHTML = "";
    totalCount.textContent = list.length;

    if (list.length === 0) {
        noRecords.classList.remove("d-none");
        return;
    }
    noRecords.classList.add("d-none");

    list.forEach(vehicle => {
        const tr = document.createElement("tr");

        let statusClass = "badge-available";
        if (vehicle.status === "RENTED") statusClass = "badge-rented";
        if (vehicle.status === "MAINTENANCE") statusClass = "badge-maintenance";

        const toggleBtnLabel = vehicle.status === "AVAILABLE" ? "Rent Out" : (vehicle.status === "RENTED" ? "Return" : "Ready");

        tr.innerHTML = `
            <td>
                <strong>${escapeHtml(vehicle.make)} ${escapeHtml(vehicle.model)}</strong>
                <div style="font-size: 0.76rem; color: var(--text-muted);">${vehicle.fuelType} · ${vehicle.seatingCapacity} seats</div>
            </td>
            <td><code>${escapeHtml(vehicle.registrationNumber)}</code></td>
            <td><span class="badge badge-category">${escapeHtml(vehicle.category)}</span></td>
            <td><strong>$${parseFloat(vehicle.dailyRate).toFixed(2)}</strong><span style="font-size: 0.75rem; color: var(--text-muted);">/day</span></td>
            <td><span class="badge ${statusClass}">${escapeHtml(vehicle.status)}</span></td>
            <td>
                <div style="display: flex; gap: 6px;">
                    <button class="btn btn-sm btn-action" onclick="toggleStatus(${vehicle.id})">${toggleBtnLabel}</button>
                    <button class="btn btn-sm btn-danger" onclick="deleteVehicle(${vehicle.id})">Delete</button>
                </div>
            </td>
        `;
        tableBody.appendChild(tr);
    });

    updateStats();
}

// Form Validation
function validateForm() {
    let isValid = true;

    // Reset error messages
    document.querySelectorAll(".error-msg").forEach(el => el.textContent = "");
    document.querySelectorAll(".input-error").forEach(el => el.classList.remove("input-error"));

    // Plate Validation
    const plateVal = plateInput.value.trim().toUpperCase();
    if (!plateVal) {
        showFieldError("plateError", plateInput, "License / Plate number is required.");
        isValid = false;
    } else if (plateVal.length < 4) {
        showFieldError("plateError", plateInput, "Plate number must be at least 4 characters.");
        isValid = false;
    } else {
        const exists = fleet.some(v => v.registrationNumber.toUpperCase() === plateVal);
        if (exists) {
            showFieldError("plateError", plateInput, "A vehicle with this plate number is already registered.");
            isValid = false;
        }
    }

    // Make Validation
    const makeVal = makeInput.value.trim();
    if (!makeVal) {
        showFieldError("makeError", makeInput, "Manufacturer / Make is required.");
        isValid = false;
    } else if (makeVal.length < 2) {
        showFieldError("makeError", makeInput, "Make must be at least 2 characters.");
        isValid = false;
    }

    // Model Validation
    const modelVal = modelInput.value.trim();
    if (!modelVal) {
        showFieldError("modelError", modelInput, "Model name is required.");
        isValid = false;
    }

    // Category Validation
    if (!categorySelect.value) {
        showFieldError("categoryError", categorySelect, "Please select a vehicle category.");
        isValid = false;
    }

    // Fuel Type Validation
    if (!fuelTypeSelect.value) {
        showFieldError("fuelError", fuelTypeSelect, "Please select a fuel type.");
        isValid = false;
    }

    // Daily Rate Validation
    const rateVal = parseFloat(dailyRateInput.value);
    if (isNaN(rateVal) || rateVal <= 0) {
        showFieldError("rateError", dailyRateInput, "Enter a valid daily rate greater than 0.");
        isValid = false;
    }

    return isValid;
}

function showFieldError(errorId, inputEl, message) {
    document.getElementById(errorId).textContent = message;
    inputEl.classList.add("input-error");
}

// Handle Add Vehicle Form Submit
vehicleForm.addEventListener("submit", function (e) {
    e.preventDefault();

    if (!validateForm()) return;

    const newVehicle = {
        id: Date.now(),
        registrationNumber: plateInput.value.trim().toUpperCase(),
        make: makeInput.value.trim(),
        model: modelInput.value.trim(),
        category: categorySelect.value,
        fuelType: fuelTypeSelect.value,
        dailyRate: parseFloat(dailyRateInput.value),
        status: "AVAILABLE",
        seatingCapacity: parseInt(seatingSelect.value) || 5
    };

    fleet.unshift(newVehicle);
    saveFleet();
    renderTable(fleet);
    clearForm();
    showAlert(`Vehicle "${newVehicle.make} ${newVehicle.model}" registered successfully!`, "success");
});

// Toggle Vehicle Status (Rent / Return / Available)
function toggleStatus(id) {
    const vehicle = fleet.find(v => v.id === id);
    if (!vehicle) return;

    if (vehicle.status === "AVAILABLE") {
        vehicle.status = "RENTED";
        showAlert(`Vehicle ${vehicle.registrationNumber} marked as RENTED.`, "info");
    } else if (vehicle.status === "RENTED") {
        vehicle.status = "AVAILABLE";
        showAlert(`Vehicle ${vehicle.registrationNumber} returned & marked as AVAILABLE.`, "success");
    } else {
        vehicle.status = "AVAILABLE";
        showAlert(`Vehicle ${vehicle.registrationNumber} maintenance completed & ready to rent!`, "success");
    }

    saveFleet();
    applyFilter();
}

// Delete Vehicle
function deleteVehicle(id) {
    const vehicle = fleet.find(v => v.id === id);
    if (!vehicle) return;

    if (confirm(`Are you sure you want to remove ${vehicle.make} ${vehicle.model} (${vehicle.registrationNumber}) from fleet?`)) {
        fleet = fleet.filter(v => v.id !== id);
        saveFleet();
        applyFilter();
        showAlert(`Vehicle removed from fleet.`, "danger");
    }
}

// Search / Filter
function applyFilter() {
    const q = searchInput.value.toLowerCase().trim();
    if (!q) {
        renderTable(fleet);
        return;
    }

    const filtered = fleet.filter(v =>
        v.make.toLowerCase().includes(q) ||
        v.model.toLowerCase().includes(q) ||
        v.registrationNumber.toLowerCase().includes(q) ||
        v.category.toLowerCase().includes(q) ||
        v.fuelType.toLowerCase().includes(q) ||
        v.status.toLowerCase().includes(q)
    );

    renderTable(filtered);
}

searchInput.addEventListener("input", applyFilter);

// Form Clear Helper
function clearForm() {
    vehicleForm.reset();
    document.querySelectorAll(".error-msg").forEach(el => el.textContent = "");
    document.querySelectorAll(".input-error").forEach(el => el.classList.remove("input-error"));
}

resetFormBtn.addEventListener("click", clearForm);

// Reset Fleet to Defaults
resetFleetBtn.addEventListener("click", () => {
    if (confirm("Reset fleet inventory to default sample vehicles?")) {
        fleet = [...initialFleet];
        saveFleet();
        renderTable(fleet);
        showAlert("Fleet inventory reset to initial samples.", "info");
    }
});

// Show Notification Alert
function showAlert(message, type = "success") {
    alertBox.textContent = message;
    alertBox.className = `alert alert-${type}`;
    setTimeout(() => {
        alertBox.className = "alert d-none";
    }, 3500);
}

// Escape HTML
function escapeHtml(str) {
    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Initial Load
renderTable(fleet);
