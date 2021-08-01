const mongoose = require('mongoose');
var Schema = mongoose.Schema,
ObjectId = Schema.ObjectId;  
var schema = new mongoose.Schema({
    userId: ObjectId,
    Name:"String",
    Phone:"Number",
    GuestCount:"Number",
    roomType: "String",
    // roomid: ObjectId1,
    roomid: String,
    startDate:"Date",
    // startDate:"String",
    endDate:"Date",
    // endDate:"String",
    documentName: "String",
    documentType:"String",
    Amount:"Number",
    roomNumber:Number,
    status:"String",
    BookingStatus:"String",
    paymentStatus:"String",
    paymentOrderId:"String",
    image:"String"
});
var Room_Booking_schema = mongoose.model("Booking", schema);
module.exports = {Room_Booking_schema};
