document.getElementById("signup-form").addEventListener("submit", async function (event) {
    event.preventDefault();

    const username = document.getElementById("username").value;
    const email    = document.getElementById("email").value;
    const password = document.getElementById("password").value;
    const confirm  = document.getElementById("confirm-password").value;

    if (password !== confirm) {
        alert("Passwords do not match!");
        return;
    }

    try {
        const response = await fetch("https://d3bpj9bucrhmjl.cloudfront.net/api/signup", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ username, email, password })
        });

        const result = await response.json();

        if (!response.ok) throw new Error(result.error || "Signup failed");

        alert("Signup successful! Check your email.");
        window.location.href = "/login.html";

    } catch (err) {
        alert(err.message);
    }
});