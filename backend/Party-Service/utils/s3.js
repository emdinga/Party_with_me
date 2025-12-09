const AWS = require('aws-sdk');

const s3 = new AWS.S3({
    region: process.env.AWS_REGION
});

/**
 * Upload buffer to S3
 * @param {Buffer} buffer
 * @param {string} filename
 * @returns {Promise<string>} S3 key
 */
async function uploadPoster(buffer, filename) {
    const key = `assets/uploads/posters/${filename}`;
    await s3.putObject({
        Bucket: process.env.S3_BUCKET,
        Key: key,
        Body: buffer,
        ContentType: 'image/jpeg', // or dynamic based on file
        ACL: 'public-read'
    }).promise();
    return key;
}

module.exports = { uploadPoster };