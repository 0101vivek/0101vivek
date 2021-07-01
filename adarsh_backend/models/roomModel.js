const mongoose = require('mongoose');
var Schema = mongoose.Schema,
ObjectId = Schema.ObjectId; 
var schema = new mongoose.Schema({
    image:"String",
    roomNumber: "Number",
    description:"String",
    charges:Number,
    status:"String",
    Type:"String",
    startDate:"String",
    uploaded : {type:"Date",default:Date.now}
});
var Room_schema = mongoose.model("Room", schema);
module.exports = {Room_schema};
