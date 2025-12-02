const express = require('express');
const AWS = require('aws-sdk');
const cors = require('cors');

const app = express();
app.use(express.json());

// Allow only your CloudFront frontend domain
app.use(cors({
    origin: "https://d3bpj9bucrhmjl.cloudfront.net",
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));

// ------------------------------
// Health check for ECS / NLB
// ------------------------------
app.get('/api/health', (req, res) => {
    res.status(200).send("Auth service is running");
});

// ------------------------------
// Configure Cognito
// ------------------------------
AWS.config.update({ region: 'us-east-1' });
const cognito = new AWS.CognitoIdentityServiceProvider();

const USER_POOL_ID = "us-east-1_gocWMYxA0";
const CLIENT_ID = "793sstv1doa5e826vbvqbnqvg2";

// ------------------------------
// SIGNUP
// ------------------------------
app.post('/api/signup', async (req, res) => {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
        return res.status(400).json({ error: "Missing required fields" });
    }

    try {
        const params = {
            ClientId: CLIENT_ID,
            Username: email,
            Password: password,
            UserAttributes: [
                { Name: 'email', Value: email },
                { Name: 'preferred_username', Value: username }
            ]
        };

        await cognito.signUp(params).promise();
        res.status(200).json({ message: "Signup successful. Check email for verification." });

    } catch (err) {
        console.error(err);
        res.status(400).json({ error: err.message });
    }
});

// ------------------------------
// LOGIN
// ------------------------------
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ error: "Missing email or password" });
    }

    const params = {
        AuthFlow: "USER_PASSWORD_AUTH",
        ClientId: CLIENT_ID,
        AuthParameters: {
            USERNAME: email,
            PASSWORD: password
        }
    };

    try {
        const result = await cognito.initiateAuth(params).promise();
        res.json({
            accessToken: result.AuthenticationResult.AccessToken,
            idToken: result.AuthenticationResult.IdToken,
            refreshToken: result.AuthenticationResult.RefreshToken
        });
    } catch (err) {
        console.error(err);
        res.status(400).json({ error: err.message });
    }
});

// ------------------------------
// Start server
// ------------------------------
const PORT = 3000;
app.listen(PORT, () => console.log(`Auth service running on port ${PORT}`));