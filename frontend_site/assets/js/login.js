document.getElementById("login-form").addEventListener("submit", async function (event) {
    event.preventDefault();

    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    try {
        const response = await fetch("https://d3bpj9bucrhmjl.cloudfront.net/login.html", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password })
        });

        const result = await response.json();

        if (!response.ok) throw new Error(result.error || "Login failed");

        // Store tokens
        localStorage.setItem("id_token", result.idToken);
        localStorage.setItem("access_token", result.accessToken);
        localStorage.setItem("refresh_token", result.refreshToken);

        alert("Login successful!");
        window.location.href = "/members_home.html";

    } catch (err) {
        alert(err.message);
    }
});
