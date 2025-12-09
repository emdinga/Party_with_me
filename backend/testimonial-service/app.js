const express = require('express');
const AWS = require('aws-sdk');
const multer = require('multer');
const { v4: uuidv4 } = require("uuid");
const TestimonialModel = require('./models/testimonial');

const app = express();
app.use(express.json());

// CORS for CloudFront → ALB → ECS
const allowedOrigin = "https://d3bpj9bucrhmjl.cloudfront.net";
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", allowedOrigin);
    res.header("Access-Control-Allow-Credentials", "true");
    res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
    res.header("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS");

    if (req.method === "OPTIONS") return res.sendStatus(200);
    next();
});

// AWS Setup
AWS.config.update({ region: "us-east-1" });
const dynamo = new AWS.DynamoDB.DocumentClient();
const s3 = new AWS.S3();
const testimonials = new TestimonialModel(dynamo);

// file upload (buffer)
const upload = multer({ storage: multer.memoryStorage() });

// S3 bucket & folder
const BUCKET = "frontend-site";
const UPLOAD_PATH = "assets/uploads/testimonials/";

// ------------------------------
// Create testimonial
// ------------------------------
app.post("/api/testimonials", upload.single("image"), async (req, res) => {
    try {
        const { user_id, username, message, rating } = req.body;

        let image_url = null;

        if (req.file) {
            const fileKey = `${UPLOAD_PATH}${uuidv4()}_${req.file.originalname}`;

            await s3.putObject({
                Bucket: BUCKET,
                Key: fileKey,
                Body: req.file.buffer,
                ContentType: req.file.mimetype
            }).promise();

            image_url = `https://${BUCKET}.s3.amazonaws.com/${fileKey}`;
        }

        const data = await testimonials.create({
            user_id,
            username,
            message,
            rating,
            image_url
        });

        res.status(201).json({ message: "Testimonial created", testimonial: data });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to create testimonial" });
    }
});

// Get all
app.get("/api/testimonials", async (req, res) => {
    const items = await testimonials.getAll();
    res.json(items);
});

// Get one
app.get("/api/testimonials/:id", async (req, res) => {
    const item = await testimonials.get(req.params.id);
    if (!item) return res.status(404).json({ error: "Not found" });
    res.json(item);
});

// Delete
app.delete("/api/testimonials/:id", async (req, res) => {
    await testimonials.delete(req.params.id);
    res.json({ message: "Deleted" });
});

// Start server
const PORT = 3002;
app.listen(PORT, () => console.log(`Testimonial service running on ${PORT}`));
