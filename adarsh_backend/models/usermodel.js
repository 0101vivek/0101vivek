const mongoose = require('mongoose');
var schema = new mongoose.Schema({
    first_name: "String",
    last_name: "String",
    email: "String",
    mobileno: "String",
    password: "String"
});
var User = mongoose.model("User", schema);
module.exports = {User};
