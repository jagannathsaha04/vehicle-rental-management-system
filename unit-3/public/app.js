// ============================================================
// Vehicle Rental Management System - Unit 3 Frontend Client
// Consumes Express & MySQL REST API (/api/vehicles, /api/status, /api/stats)
// ============================================================

let fleetList = [];

// DOM Elements
const statusBanner = document.getElementById("statusBanner");
const statusText = document.getElementById("statusText");
const alertBox = document.getElementById("alertBox");
const vehicleForm = document.getElementById("vehicleForm");
const tableBody = document.getElementById("vehicleTableBody");
const loadingState = document.getElementById("loadingState");
const noRecords = document.getElementById("noRecords");
const searchInput = document.getElementById("searchInput");
const totalCount = document.getElementById("totalCount");

// Stats Elements
const statTotal = document.getElementById("statTotal");
const statAvailable = document.getElementById("statAvailable");
const statRented = document.getElementById("statRented");
const statAvgRate = document.getElementById("statAvgRate");

// 1. Check MySQL / Backend Connection Status
async function checkStatus() {
    try {
        const res = await fetch('/api/status');
        const data = await res.json();

        if (data.connected) {
            statusBanner.className = "status-banner status-online";
            statusText.textContent = `🟢 ${data.message}`;
        } else if (data.usingFallback) {
            statusBanner.className = "status-banner status-fallback";
            statusText.textContent = `🟡 ${data.message}`;
        } else {
            statusBanner.className = "status-banner status-fallback";
            statusText.textContent = `🔴 Database notice: ${data.message || 'Connecting...'}`;
        }
    } catch (err) {
        statusBanner.className = "status-banner status-fallback";
        statusText.textContent = "🔴 Server unreachable. Start server via 'npm start' in unit-3.";
    }
}

// 2. Fetch Dashboard Statistics
async function fetchStats() {
    try {
        const res = await fetch('/api/stats');
        if (res.ok) {
            const data = await res.json();
            statTotal.textContent = data.totalFleet || 0;
            statAvailable.textContent = data.available || 0;
            statRented.textContent = data.rented || 0;
            statAvgRate.textContent = `$${(data.avgDailyRate || 0).toFixed(2)}`;
        }
    } catch (err) {
        console.error("Failed to fetch stats:", err);
    }
}

// 3. READ: Fetch all vehicles from backend/MySQL
async function fetchVehicles() {
    loadingState.classList.remove("d-none");
    noRecords.classList.add("d-none");
    tableBody.innerHTML = "";

    try {
        const res = await fetch('/api/vehicles');
        if (!res.ok) throw new Error(`HTTP Error ${res.status}`);

        fleetList = await res.json();
        loadingState.classList.add("d-none");
        renderTable(fleetList);
        fetchStats();
    } catch (err) {
        loadingState.classList.add("d-none");
        showAlert(`Error loading vehicles from server: ${err.message}`, "danger");
    }
}

// Render Table Rows
function renderTable(list) {
    tableBody.innerHTML = "";
    totalCount.textContent = list.length;

    if (list.length === 0) {
        noRecords.classList.remove("d-none");
        return;
    }
    noRecords.classList.add("d-none");

    list.forEach(v => {
        const tr = document.createElement("tr");

        let statusBadge = "badge-available";
        if (v.status === "RENTED") statusBadge = "badge-rented";
        if (v.status === "MAINTENANCE") statusBadge = "badge-maintenance";

        const toggleLabel = v.status === "AVAILABLE" ? "Rent Out" : (v.status === "RENTED" ? "Return" : "Ready");
        const nextStatus = v.status === "AVAILABLE" ? "RENTED" : "AVAILABLE";

        tr.innerHTML = `
            <td>
                <strong>${escapeHtml(v.make)} ${escapeHtml(v.model)}</strong>
                <div style="font-size: 0.76rem; color: var(--text-muted);">${v.fuel_type || v.fuelType} · ${v.seating_capacity || v.seatingCapacity} seats</div>
            </td>
            <td><code>${escapeHtml(v.registration_number || v.registrationNumber)}</code></td>
            <td><span class="badge badge-category">${escapeHtml(v.category)}</span></td>
            <td><strong>$${parseFloat(v.daily_rate || v.dailyRate).toFixed(2)}</strong>/day</td>
            <td><span class="badge ${statusBadge}">${escapeHtml(v.status)}</span></td>
            <td>
                <div style="display: flex; gap: 6px;">
                    <button class="btn btn-sm btn-action" onclick="toggleStatus(${v.id}, '${nextStatus}')">${toggleLabel}</button>
                    <button class="btn btn-sm btn-danger" onclick="deleteVehicle(${v.id})">Delete</button>
                </div>
            </td>
        `;
        tableBody.appendChild(tr);
    });
}

// 4. CREATE: Insert Vehicle into MySQL
vehicleForm.addEventListener("submit", async function (e) {
    e.preventDefault();

    const payload = {
        registration_number: document.getElementById("plateNumber").value.trim().toUpperCase(),
        make: document.getElementById("make").value.trim(),
        model: document.getElementById("model").value.trim(),
        category: document.getElementById("category").value,
        fuel_type: document.getElementById("fuelType").value,
        daily_rate: parseFloat(document.getElementById("dailyRate").value),
        seating_capacity: parseInt(document.getElementById("seatingCapacity").value) || 5
    };

    try {
        const res = await fetch('/api/vehicles', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        const data = await res.json();
        if (res.ok) {
            showAlert(`Vehicle ${data.registration_number} saved to MySQL!`, "success");
            vehicleForm.reset();
            fetchVehicles();
        } else {
            showAlert(`Failed to save: ${data.error || 'Server error'}`, "danger");
        }
    } catch (err) {
        showAlert(`Request failed: ${err.message}`, "danger");
    }
});

// 5. UPDATE Status (Toggle Rent/Return)
async function toggleStatus(id, newStatus) {
    let renterName = null;
    if (newStatus === "RENTED") {
        renterName = prompt("Enter customer/renter name:", "Alex Johnson");
        if (!renterName) return;
    }

    try {
        const res = await fetch(`/api/vehicles/${id}/status`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status: newStatus, renter_name: renterName })
        });

        if (res.ok) {
            showAlert(`Vehicle #${id} status updated to ${newStatus}.`, "success");
            fetchVehicles();
        } else {
            const data = await res.json();
            showAlert(`Update failed: ${data.error}`, "danger");
        }
    } catch (err) {
        showAlert(`Error: ${err.message}`, "danger");
    }
}

// 6. DELETE Vehicle from MySQL
async function deleteVehicle(id) {
    if (!confirm(`Are you sure you want to permanently delete vehicle ID #${id} from MySQL?`)) {
        return;
    }

    try {
        const res = await fetch(`/api/vehicles/${id}`, { method: 'DELETE' });
        if (res.ok) {
            showAlert(`Vehicle #${id} deleted from database.`, "success");
            fetchVehicles();
        } else {
            const data = await res.json();
            showAlert(`Delete failed: ${data.error}`, "danger");
        }
    } catch (err) {
        showAlert(`Error: ${err.message}`, "danger");
    }
}

// 7. Instant Search Filter
searchInput.addEventListener("input", function (e) {
    const q = e.target.value.toLowerCase().trim();
    if (!q) {
        renderTable(fleetList);
        return;
    }

    const filtered = fleetList.filter(v =>
        (v.make && v.make.toLowerCase().includes(q)) ||
        (v.model && v.model.toLowerCase().includes(q)) ||
        ((v.registration_number || v.registrationNumber || '').toLowerCase().includes(q)) ||
        (v.category && v.category.toLowerCase().includes(q)) ||
        (v.status && v.status.toLowerCase().includes(q))
    );

    renderTable(filtered);
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
    return String(str || '')
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Initial Boot
checkStatus();
fetchVehicles();
