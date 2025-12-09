const { v4: uuidv4 } = require("uuid");

class TestimonialModel {
    constructor(dynamo) {
        this.dynamo = dynamo;
        this.tableName = "Testimonials";
    }

    async create(data) {
        const item = {
            id: uuidv4(),
            ...data,
            created_at: new Date().toISOString()
        };

        await this.dynamo.put({
            TableName: this.tableName,
            Item: item,
        }).promise();

        return item;
    }

    async getAll() {
        const result = await this.dynamo.scan({
            TableName: this.tableName
        }).promise();
        return result.Items;
    }

    async get(id) {
        const result = await this.dynamo.get({
            TableName: this.tableName,
            Key: { id },
        }).promise();

        return result.Item;
    }

    async delete(id) {
        await this.dynamo.delete({
            TableName: this.tableName,
            Key: { id },
        }).promise();

        return true;
    }
}

module.exports = TestimonialModel;
