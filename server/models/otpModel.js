const mongoose = require('mongoose');
var Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;
var schema = new mongoose.Schema({
    email: "String",
    phoneNo: "String",
    otp: "String",
    minute: "String",
    second : "String"
});
var Otp_schema = mongoose.model("OtpModel", schema);
module.exports = { Otp_schema };
