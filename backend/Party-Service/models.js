const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

AWS.config.update({ region: process.env.AWS_REGION });
const dynamo = new AWS.DynamoDB.DocumentClient();

const EVENTS_TABLE = process.env.DYNAMODB_EVENTS_TABLE;
const RSVPS_TABLE = process.env.DYNAMODB_RSVPS_TABLE;

// Create event
async function createEvent({ title, date, location, privacy, poster_image, owner_id }) {
    const eventId = uuidv4();
    const item = { eventId, title, date, location, privacy, poster_image, owner_id };
    await dynamo.put({ TableName: EVENTS_TABLE, Item: item }).promise();
    return item;
}

// Get all events
async function getEvents() {
    const res = await dynamo.scan({ TableName: EVENTS_TABLE }).promise();
    return res.Items;
}

// Get single event
async function getEvent(eventId) {
    const res = await dynamo.get({ TableName: EVENTS_TABLE, Key: { eventId } }).promise();
    return res.Item;
}

// RSVP
async function createRsvp({ eventId, user_id, guests }) {
    const rsvpId = uuidv4();
    const item = { rsvpId, eventId, user_id, guests };
    await dynamo.put({ TableName: RSVPS_TABLE, Item: item }).promise();
    return item;
}

// Get RSVPs for event
async function getRsvps(eventId) {
    const res = await dynamo.query({
        TableName: RSVPS_TABLE,
        IndexName: 'EventIndex', // optional if you create a GSI on eventId
        KeyConditionExpression: 'eventId = :e',
        ExpressionAttributeValues: { ':e': eventId }
    }).promise();
    return res.Items;
}

module.exports = { createEvent, getEvents, getEvent, createRsvp, getRsvps };