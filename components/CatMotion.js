.pragma library

// Inputs are percentages, rather than the service's 0..1 fraction.
function phaseFor(load, current) {
    if (!Number.isFinite(load))
        return current;
    // A one percentage point dead band prevents chattering at the boundaries.
    if (current === "sleep" && load < 6)
        return "sleep";
    if (current === "run" && load >= 14)
        return "run";
    if (load < 5)
        return "sleep";
    return load < 15 ? "walk" : "run";
}
