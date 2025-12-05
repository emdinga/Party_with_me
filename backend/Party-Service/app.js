const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const multer = require('multer');
const sharp = require('sharp');
const { createEvent, getEvents, getEvent, createRsvp, getRsvps } = require('./models');
const { uploadPoster } = require('./utils/s3');

const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({ secret: 'secret-key', resave: false, saveUninitialized: false }));

const storage = multer.memoryStorage();
const upload = multer({ storage });

// ---------------------------
// CREATE EVENT
// ---------------------------
app.post('/create_event', upload.single('poster'), async (req, res) => {
    try {
        const { title, date, location, privacy, owner_id } = req.body;
        if (!title || !date || !location || !privacy || !owner_id) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        let poster_key = null;
        if (req.file) {
            const resizedBuffer = await sharp(req.file.buffer)
                .resize(600, 800)
                .toBuffer();
            poster_key = await uploadPoster(resizedBuffer, Date.now() + '_' + req.file.originalname);
        }

        const event = await createEvent({ title, date, location, privacy, poster_image: poster_key, owner_id });
        res.status(201).json({ message: 'Event created', event });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ---------------------------
// GET ALL EVENTS
// ---------------------------
app.get('/event-created', async (req, res) => {
    const events = await getEvents();
    res.json({ events });
});

// ---------------------------
// RSVP
// ---------------------------
app.post('/rsvp/:eventId', async (req, res) => {
    const { eventId } = req.params;
    const { user_id, guests } = req.body;
    try {
        const rsvp = await createRsvp({ eventId, user_id, guests: guests || 1 });
        res.json({ message: 'RSVP successful', rsvp });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// ---------------------------
// GET EVENT DETAILS
// ---------------------------
app.get('/event/:eventId', async (req, res) => {
    const event = await getEvent(req.params.eventId);
    const rsvps = await getRsvps(req.params.eventId);
    res.json({ event, rsvps });
});

// ---------------------------
// Start server
// ---------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));