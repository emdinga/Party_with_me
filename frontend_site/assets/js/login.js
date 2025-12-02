document.getElementById("login-form").addEventListener("submit", async function (event) {
    event.preventDefault();

    const email    = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    if (!email || !password) {
        alert("Please enter both email and password.");
        return;
    }

    try {
        const response = await fetch("https://d3bpj9bucrhmjl.cloudfront.net/api/login", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password })
        });

        const result = await response.json();

        if (!response.ok) throw new Error(result.error || "Login failed");

        // Save tokens in localStorage (optional, depending on your frontend auth logic)
        localStorage.setItem("accessToken", result.accessToken);
        localStorage.setItem("idToken", result.idToken);
        localStorage.setItem("refreshToken", result.refreshToken);

        alert("Login successful!");
        window.location.href = "/dashboard.html"; // redirect after login

    } catch (err) {
        alert(err.message);
    }
});