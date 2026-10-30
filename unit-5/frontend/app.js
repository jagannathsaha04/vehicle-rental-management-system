// Determine API Base URL dynamically
const API_BASE = (window.location.protocol.startsWith('http') && window.location.port === '8081')
    ? ''
    : 'http://localhost:8081';

// Global State
let fleetList = [];

// DOM Elements
const backendStatusBanner = document.getElementById("backendStatusBanner");
const backendStatusText = document.getElementById("backendStatusText");
const alertBox = document.getElementById("alertBox");
const tableBody = document.getElementById("vehicleTableBody");
const loadingState = document.getElementById("loadingState");
const noRecords = document.getElementById("noRecords");
const searchInput = document.getElementById("searchInput");

// Stat elements
const statTotal = document.getElementById("statTotal");
const statAvailable = document.getElementById("statAvailable");
const statRented = document.getElementById("statRented");
const statAvgRate = document.getElementById("statAvgRate");

// Modals
const addModal = document.getElementById("addModal");
const editModal = document.getElementById("editModal");

// Forms
const addVehicleForm = document.getElementById("addVehicleForm");
const editVehicleForm = document.getElementById("editVehicleForm");

// 1. Check Backend Status
async function checkBackendStatus() {
    try {
        const response = await fetch(`${API_BASE}/api/status`);
        const data = await response.json();

        if (response.ok && data.connected) {
            backendStatusBanner.className = "status-banner status-online";
            backendStatusText.textContent = `🟢 ${data.message} | Connected to Spring Boot 3 & MySQL`;
            return true;
        } else {
            backendStatusBanner.className = "status-banner status-error";
            backendStatusText.textContent = `🔴 Spring Boot status check failed.`;
            return false;
        }
    } catch (err) {
        backendStatusBanner.className = "status-banner status-error";
        backendStatusText.textContent = `🔴 Spring Boot API offline. Run 'mvn spring-boot:run' inside unit-5 (Port 8081).`;
        return false;
    }
}

// 2. Fetch Dashboard Statistics
async function fetchStats() {
    try {
        const response = await fetch(`${API_BASE}/api/vehicles/stats`);
        if (response.ok) {
            const stats = await response.json();
            statTotal.textContent = stats.totalFleet || 0;
            statAvailable.textContent = stats.available || 0;
            statRented.textContent = stats.rented || 0;
            statAvgRate.textContent = `$${(stats.averageDailyRate || 0).toFixed(2)}`;
        }
    } catch (err) {
        console.error("Failed to load statistics:", err);
    }
}

// 3. READ: Fetch all vehicles
async function fetchVehicles() {
    loadingState.classList.remove("d-none");
    noRecords.classList.add("d-none");
    tableBody.innerHTML = "";

    try {
        const response = await fetch(`${API_BASE}/api/vehicles`);
        if (!response.ok) {
            throw new Error(`Spring Boot returned HTTP ${response.status}`);
        }

        fleetList = await response.json();
        loadingState.classList.add("d-none");

        renderTable(fleetList);
        fetchStats();
    } catch (err) {
        loadingState.classList.add("d-none");
        showAlert(`Failed to fetch fleet records: ${err.message}`, "danger");
    }
}

// Render Table Rows
function renderTable(list) {
    tableBody.innerHTML = "";

    if (!list || list.length === 0) {
        noRecords.classList.remove("d-none");
        return;
    }
    noRecords.classList.add("d-none");

    list.forEach(v => {
        const tr = document.createElement("tr");

        let statusClass = "badge-available";
        if (v.status === "RENTED") statusClass = "badge-rented";
        if (v.status === "MAINTENANCE") statusClass = "badge-maintenance";

        const toggleBtn = v.status === "AVAILABLE"
            ? `<button class="btn btn-sm btn-rent" onclick="toggleRental(${v.id}, 'RENTED')">Rent Out</button>`
            : (v.status === "RENTED"
                ? `<button class="btn btn-sm btn-return" onclick="toggleRental(${v.id}, 'AVAILABLE')">Return</button>`
                : `<button class="btn btn-sm btn-rent" onclick="toggleRental(${v.id}, 'AVAILABLE')">Ready</button>`);

        tr.innerHTML = `
            <td>${v.id}</td>
            <td>
                <strong>${escapeHtml(v.make)} ${escapeHtml(v.model)}</strong>
                <div style="font-size: 0.74rem; color: var(--text-muted);">${v.seatingCapacity || 5} Seats · ${v.mileage || 15000} km</div>
            </td>
            <td><code>${escapeHtml(v.registrationNumber)}</code></td>
            <td><span class="badge badge-category">${escapeHtml(v.category)}</span></td>
            <td>${escapeHtml(v.fuelType || 'Petrol')}</td>
            <td><span class="badge-rate">$${parseFloat(v.dailyRate).toFixed(2)}</span><span style="font-size: 0.75rem; color: var(--text-muted);">/d</span></td>
            <td><span class="badge ${statusClass}">${escapeHtml(v.status)}</span></td>
            <td>${v.renterName ? `<span style="color: #6ee7b7; font-weight: 500;">👤 ${escapeHtml(v.renterName)}</span>` : '<span style="color: var(--text-muted);">—</span>'}</td>
            <td>
                <div style="display: flex; gap: 6px;">
                    <button class="btn btn-sm btn-edit" onclick="openEditModal(${v.id})">Edit</button>
                    ${toggleBtn}
                    <button class="btn btn-sm btn-delete" onclick="deleteVehicle(${v.id}, '${escapeHtml(v.make + ' ' + v.model)}')">Delete</button>
                </div>
            </td>
        `;
        tableBody.appendChild(tr);
    });
}

// 4. CREATE: Add new vehicle
addVehicleForm.addEventListener("submit", async function (e) {
    e.preventDefault();

    const vehicleData = {
        registrationNumber: document.getElementById("addPlate").value.trim().toUpperCase(),
        make: document.getElementById("addMake").value.trim(),
        model: document.getElementById("addModel").value.trim(),
        category: document.getElementById("addCategory").value,
        fuelType: document.getElementById("addFuel").value,
        dailyRate: parseFloat(document.getElementById("addRate").value),
        seatingCapacity: parseInt(document.getElementById("addSeats").value) || 5,
        mileage: parseInt(document.getElementById("addMileage").value) || 15000,
        status: "AVAILABLE",
        renterName: null
    };

    try {
        const response = await fetch(`${API_BASE}/api/vehicles`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(vehicleData)
        });

        if (response.ok) {
            const saved = await response.json();
            showAlert(`Vehicle "${saved.make} ${saved.model}" added successfully!`, "success");
            closeAddModal();
            fetchVehicles();
        } else {
            const err = await response.text();
            showAlert(`Failed to add vehicle: ${err}`, "danger");
        }
    } catch (err) {
        showAlert(`Error creating vehicle: ${err.message}`, "danger");
    }
});

// 5. UPDATE: Edit existing vehicle
function openEditModal(id) {
    const v = fleetList.find(item => item.id === id);
    if (!v) return;

    document.getElementById("editId").value = v.id;
    document.getElementById("editPlate").value = v.registrationNumber;
    document.getElementById("editMake").value = v.make;
    document.getElementById("editModel").value = v.model;
    document.getElementById("editCategory").value = v.category;
    document.getElementById("editFuel").value = v.fuelType || "Petrol";
    document.getElementById("editRate").value = v.dailyRate;
    document.getElementById("editStatus").value = v.status || "AVAILABLE";
    document.getElementById("editRenter").value = v.renterName || "";

    editModal.classList.remove("d-none");
}

function closeEditModal() {
    editModal.classList.add("d-none");
    editVehicleForm.reset();
}

editVehicleForm.addEventListener("submit", async function (e) {
    e.preventDefault();

    const id = document.getElementById("editId").value;
    const updatedData = {
        registrationNumber: document.getElementById("editPlate").value.trim().toUpperCase(),
        make: document.getElementById("editMake").value.trim(),
        model: document.getElementById("editModel").value.trim(),
        category: document.getElementById("editCategory").value,
        fuelType: document.getElementById("editFuel").value,
        dailyRate: parseFloat(document.getElementById("editRate").value),
        status: document.getElementById("editStatus").value,
        renterName: document.getElementById("editRenter").value.trim() || null
    };

    try {
        const response = await fetch(`${API_BASE}/api/vehicles/${id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(updatedData)
        });

        if (response.ok) {
            showAlert(`Vehicle #${id} updated successfully!`, "success");
            closeEditModal();
            fetchVehicles();
        } else {
            const err = await response.text();
            showAlert(`Failed to update vehicle: ${err}`, "danger");
        }
    } catch (err) {
        showAlert(`Error updating vehicle: ${err.message}`, "danger");
    }
});

// 6. TOGGLE RENTAL (Rent / Return)
async function toggleRental(id, newStatus) {
    let renterName = null;
    if (newStatus === "RENTED") {
        renterName = prompt("Enter customer / renter full name:", "David Miller");
        if (!renterName) return;
    }

    try {
        const res = await fetch(`${API_BASE}/api/vehicles/${id}/status`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status: newStatus, renterName: renterName })
        });

        if (res.ok) {
            showAlert(`Vehicle #${id} status changed to ${newStatus}.`, "success");
            fetchVehicles();
        } else {
            const err = await res.text();
            showAlert(`Rental update failed: ${err}`, "danger");
        }
    } catch (err) {
        showAlert(`Error updating rental: ${err.message}`, "danger");
    }
}

// 7. DELETE: Delete Vehicle
async function deleteVehicle(id, name) {
    if (!confirm(`Are you sure you want to permanently delete vehicle "${name}" (ID: ${id})?`)) {
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/api/vehicles/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            showAlert(`Vehicle "${name}" deleted successfully.`, "success");
            fetchVehicles();
        } else {
            const err = await response.text();
            showAlert(`Failed to delete vehicle: ${err}`, "danger");
        }
    } catch (err) {
        showAlert(`Error deleting vehicle: ${err.message}`, "danger");
    }
}

// 8. SEARCH: Instant Search / Filter
searchInput.addEventListener("input", function (e) {
    const q = e.target.value.toLowerCase().trim();
    if (!q) {
        renderTable(fleetList);
        return;
    }

    const filtered = fleetList.filter(v =>
        (v.make && v.make.toLowerCase().includes(q)) ||
        (v.model && v.model.toLowerCase().includes(q)) ||
        (v.registrationNumber && v.registrationNumber.toLowerCase().includes(q)) ||
        (v.category && v.category.toLowerCase().includes(q)) ||
        (v.fuelType && v.fuelType.toLowerCase().includes(q)) ||
        (v.renterName && v.renterName.toLowerCase().includes(q))
    );

    renderTable(filtered);
});

// Modal helpers
function openAddModal() {
    addModal.classList.remove("d-none");
}

function closeAddModal() {
    addModal.classList.add("d-none");
    addVehicleForm.reset();
}

// Show alert banner
function showAlert(message, type = "success") {
    alertBox.textContent = message;
    alertBox.className = `alert alert-${type}`;
    setTimeout(() => {
        alertBox.className = "alert d-none";
    }, 4000);
}

// Escape HTML
function escapeHtml(str) {
    return String(str || '')
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Close modals when clicking outside
window.addEventListener("click", function(event) {
    if (event.target === addModal) closeAddModal();
    if (event.target === editModal) closeEditModal();
});

// Initialization
checkBackendStatus();
fetchVehicles();
