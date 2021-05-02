const mongoose = require('mongoose');
var Schema = mongoose.Schema,
ObjectId = Schema.ObjectId; 
ObjectId1 = Schema.ObjectId; 
var schema = new mongoose.Schema({
    userId: ObjectId,
    Name:"String",
    Phone:"Number",
    roomType: "String",
    roomId: ObjectId1,
    startDate:"Date",
    // startDate:"String",
    endDate:"Date",
    // endDate:"String",
    documentName: "String",
    documentType:"String",
    Amount:"Number",
    roomNumber:Number,
    status:"String",
    roomIsStillChecking:"boolean",
});
var Room_Booking_schema = mongoose.model("Booking", schema);
module.exports = {Room_Booking_schema};
