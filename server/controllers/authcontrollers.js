const {User}=require('../models/usermodel');
const {Otp_schema} = require('../models/otpModel');
const {Room_schema} = require('../models/roomModel');  
const {Room_Booking_schema} = require('../models/bookRoomModel')
const mongoose = require('mongoose');
const schedule = require('node-schedule');
var jwt = require('jsonwebtoken');
const jwt_decode = require('jwt-decode');
const bcrypt = require('bcrypt');
const moment = require('moment');
var nodemailer = require('nodemailer');
var cron = require('node-cron');
var uniqid = require('uniqid');

//paytm
const https = require("https");
const qs = require("querystring");
const PaytmChecksum = require("./PaytmChecksum");
const {v4:uuidv4} = require('uuid');

//signup
module.exports.signup_post = async (req, res) => {
    var {first_name, last_name, mobileno, email, password,otpVerified} = req.body;
    
    console.log(first_name)
    console.log(password)
    try{
        let user = await User.findOne({mobileno});
        if (user) {
              res.status(409).json({msg: "User already registered"});
        }
        if(otpVerified == true){
            var salt = await bcrypt.genSalt();
            password = await bcrypt.hash(password, salt);
            user = new User({first_name, last_name, mobileno, email, password});
            await user.save();
            var token = jwt.sign({id: user.id}, "password");
            res.status(200).json({token: token, msg: 'User registered'})
        }else{
            res.status(200).json({msg:"Hello"});
        }
    }catch(err){
        console.log(err.message)
          res.status(500).json({ msg: 'Server Error Occured'})
    }
}

//login
module.exports.login_post = async (req, res) => {
    var {mobileno, password} = req.body;
    
    try{
        let user = await User.findOne({mobileno:mobileno});
        if (!user) {
              res.status(404).json({msg:"User not found"});
        }
        var auth = await bcrypt.compare(password, user.password);
        console.log(auth)
        if (!auth) {
              res.status(409).json({msg:" Invalid data"});
        } else {
            var token = jwt.sign({id: user.id}, "password");
            console.log(user.first_name)
            var id = user._id
              res.status(200).json({token:token,msg: "User Login Successfully",name:user.first_name});
        }
    }catch(e){
          res.status(500).json({ msg: 'Server Error Occured'})
    }
}

// send OTP
module.exports.send_otp = async (req, res) => {
    var {mobile,name,status,otp}=req.body;
    console.log(mobile);

    if(status == 'Forget Password'){
        await User.findOne({mobileno:mobile}, function(err,result){
            if(err){
                res.status(500).json({msg:"Something went wrong"})
            }
            if(!result){
                res.status(404).json({msg:"User Not Registered"})
            }
            name = result.first_name+" "+result.last_name
        })
    }
    
    var options = {
        "method": "POST",
        "hostname": "api.msg91.com",
        "port": null,
        "path": "/api/v5/flow/",
        "headers": {
            "authkey": "363393AI3QWHYx5j60d9f225P1",
            "content-type": "application/JSON"
        }
    };
	
    var request = https.request(options, function (response) {
        var chunks = [];

        response.on("data", function (chunk) {
            chunks.push(chunk);
        });

        response.on("end", function () {
            var body = Buffer.concat(chunks);
            res.send(body);
        });
    });
    request.write(`{\n  \"flow_id\": \"60df5ff58269ea3c0663e467\",\n  \"sender\": \"YOURIN\",\n  \"mobiles\":
     \"91${mobile}\",\n  \"name\":\"${name}\",\n  \"status\":\"${status}\",\n  \"otp\":\"${otp}\"\n\n}`);
    request.end();

}



// reset password
module.exports.reset_password = async(req, res) => {
    let {phoneNo,password} = req.body;
    try{
        console.log(password)
        var salt = await bcrypt.genSalt();
        // await User.findOne({mobileno: phoneNo}, function(err,result){
        //     console.log(result)
        // })
        password = await bcrypt.hash(password, salt);
        await User.updateOne({mobileno: phoneNo}, {$set:{password: password}},function(err,result){
            if(err){
                  res.status(500).json({msg:"Error Occured"});
            }
            if(result){
                  res.status(200).json({msg:'Password updated successfully'});
            }else{
                  res.status(400).json({msg:'Error Occured'});
            }
        });

    }catch(e){
          res.status(500).json({msg:'Error Occured'});
    }
}

module.exports.getName = async(req, res) => {
    const {token} = req.body;
    var decoded = jwt_decode(token, true);
    var id = decoded.id;
    try{
        await User.findOne({_id: id}, function(err,result){
            if(result){
                // console.log(result);
                  res.status(200).json({name:result.first_name});
            }
        });
    }catch(e){}
}

 // Luxury Available Room
 module.exports.luxury_room = async (req, res) => {
    try{
        var date = new Date()
        date = ""+date.getDate()+"-"+(date.getMonth()+1)+"-"+date.getFullYear()
        await Room_schema.find({$or:[{status:'Available',Type:'Luxory'},{Type:'Luxory',status:'pre-booked',startDate:{$ne:date}}]},function(err,result){
            if(err){
                 res.status(500).json({err});
            }
            if(result.length != 0){
                 res.status(200).json({result:result,msg: "Room Found Successfully"});
            }else{
                  res.status(404).json({msg:"Rooms Not Available"});
            }
        });
    }catch(err){}
}

 // super delux Available Room
 module.exports.super_delux = async (req, res) => {
    try{
        var date = new Date()
        date = ""+date.getDate()+"-"+(date.getMonth()+1)+"-"+date.getFullYear()
        await Room_schema.find({$or:[{Type:'SuperDelux',status:'Available'},{Type:'SuperDelux',status:'pre-booked',startDate:{$ne:date}}]},function(err,result){
            if(err){
                  res.status(500).json({err});
            }
            if(result.length != 0){
                  res.status(200).json({result:result,msg: "Room Found Successfully"});
            }else{
                  res.status(404).json({msg:"Rooms Not Available"});
            }
        });
    }catch(err){}
}


 // Delux Available Room
 module.exports.delux_room = async (req, res) => {
    try{
        var date = new Date()
        date = ""+date.getDate()+"-"+(date.getMonth()+1)+"-"+date.getFullYear()
        await Room_schema.find({$or:[{status:'Available',Type:'Delux'},{Type:'Delux',status:'pre-booked',startDate:{$ne:date}}]},function(err,result){
            if(err){
                  res.status(500).json({err});
            }
            if(result.length != 0){
                  res.status(200).json({result:result,msg: "Room Found Successfully"});
            }else{
                  res.status(404).json({msg:"Rooms Not Available"});
            }
            
        });
    }catch(err){}
}


// job schedule for daily check in
cron.schedule('00 11 * * *', async() => {
    try{
        
        var result1 = await Room_Booking_schema.find({startDate:{$lt:new Date()},status:'pre-booked',BookingStatus:'RoomPreBooked'})
    result1.map(async result => {
            console.log(result['roomid'])
            var date = new Date(result['startDate'])
            var newDate = date.getDate()+"-"+(date.getMonth()+1)+"-"+date.getFullYear()
                // console.log(newDate)
            await Room_schema.updateMany({_id:result['roomid']},{$set:{status:'Booked',startDate:newDate}});
    })    

    await Room_Booking_schema.updateMany({startDate:{$lt:new Date()},status:'pre-booked',BookingStatus:'RoomPreBooked'},{$set:{status:'Booked',BookingStatus:'RoomBooked'}})

    }catch{}
});


cron.schedule('15 12 * * *', async() => {
    try{
    var result2 = await Room_Booking_schema.find({startDate:{$gte:new Date()},status:'pre-booked',BookingStatus:'RoomPreBooked'})
        result2.map(async result => {
            var date = new Date(result2['startDate'])
            date = date.getDate()+"-"+(date.getMonth()+1)+"-"+date.getFullYear()
            await Room_schema.updateMany({_id:result['roomid']},{$set:{status:'pre-booked',startDate:date}});
    })
    }catch{}
});



// check room is booked
module.exports.check_book_room = async(req,res) => {
    const {roomId} = req.body;
    // console.log(roomId);
    try{
        await Room_schema.find({_id:roomId},(err,result) => {
            if(err){    
                  res.status(500);
            }
            if(result[0].status == 'Available' || result[0].status == 'pre-booked'){
                console.log(result);
                  res.status(200).json({msg:'Room is available'});
            }else{
                  res.status(400).json({msg:'Room is not available'});
            }
        })
    }catch(e){
          res.status(500);
    }
}

    
function generateRandomString(){
    data = 'abcdefghijklmnopqrstuvwxyz1234567890'.toUpperCase();
    var str = "";
    for(var i=0;i<10;i++){
        str += data[Math.floor(Math.random()*36)];
    }
    return str;
}

// book Room
module.exports.book_room = async (req, res) => {
    let {token,roomId,startDate,endDate,Amount,documentName,documentType,roomType,roomNumber,paymentStatus,paymentOrderId,image} = req.body;
    var month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
    try{
    console.log(token);
    var decoded = jwt_decode(token, true);
    var id = decoded.id;
    // var orderId = generateRandomString();
    var orderId;
    let userData = await User.findOne({_id:id});

    var date = new Date(startDate);
    var enddate = new Date(endDate);
    
    var now = new Date();
    var salt = await bcrypt.genSalt();
    documentType = await bcrypt.hash(documentType, salt);
    // date.setHours(0)
    console.log(date)

    let book_room ;
    console.log(date.getDate())
    console.log(now.getDate()   )
    if(date.getHours()>=11 &&  now.getDate() == date.getDate()){
        book_room = new Room_Booking_schema({userId:id,roomid:roomId,startDate,Name:userData.first_name+" "+userData.last_name,Phone:userData.mobileno,endDate,Amount,documentName,documentType,roomNumber,roomType,status:'Booked',BookingStatus:"RoomBooked",paymentStatus,paymentOrderId,image}); 
        book_room.save().then((success)=>{
            if(success){
                Room_schema.updateOne({_id: roomId},{$set:{startDate:date.getDate()+"-"+(date.getMonth()+1)+"-"+date.getFullYear(),status:'Booked'}},function(err,result){
                    if(result){
                        orderId = success._id;
                        console.log(result)
                        res.status(200).json({result,orderId});
                        sendEmailForRoomBookedSuccessfully(id,orderId,date.getDate(),month[date.getMonth()-1],enddate.getDate(),month[enddate.getMonth()-1],roomType,Amount)
                    }
                })
            }
        })
    }else{
        book_room = new Room_Booking_schema({userId:id,roomid:roomId,startDate,Name:userData.first_name+" "+userData.last_name,Phone:userData.mobileno,endDate,Amount,documentName,documentType,roomNumber,roomType,status:'pre-booked',BookingStatus:"RoomPreBooked",paymentStatus,paymentOrderId,image}); 
        book_room.save().then((success)=>{
            if(success){
                console.log(date.getDate()+"-"+date.getMonth()+"-"+date.getFullYear())
                Room_schema.updateOne({_id: roomId},{$set:{startDate:date.getDate()+"-"+(date.getMonth()+1)+"-"+date.getFullYear(),status:'pre-booked'}},function(err,result){
                    if(result){
                        orderId = success._id
                        res.status(200).json({result,orderId});
                        sendEmailForRoomBookedSuccessfully(id,orderId,date.getDate(),month[date.getMonth()-1],enddate.getDate(),month[enddate.getMonth()-1],roomType,Amount)
                    }
                })
            }
        })
    }
    }catch(err){
          res.status(503).json({msg:"Error Occured"});
    }
}

async function sendEmailForRoomBookedSuccessfully(userId,orderId,checkInDate,checkInMonth,chekOutDate,checkOutMonth,roomType,amount){
    try{
        await User.findOne({_id:userId},(err,result)=>{
            if(result){
                var transporter = nodemailer.createTransport({
                    service: 'gmail',
                    auth: {
                        user: 'viveksonawane865@gmail.com',
                        pass: 'meenakshi@0101'
                    }
                }); 
    
                const message = {
                    from: 'viveksonawane865@gmail.com',
                    to: ''+result.email,
                    subject: 'Room Booked Successfully',
                    html: `Dear Customer, 
                        <br/>
                        your booking ID `+orderId+` has now been confirmed. We look forward to hosting you and hope you enjoy your stay.
                        <br/>
                        <br/>
                    <h3>Hotel name : MetalMan hotel<br/>
                    Check-in :`+checkInDate+' '+checkInMonth+`, 11:00 AM onwards<br/>
                    Check-out : `+chekOutDate+' '+checkOutMonth+`,till 12:00 PM<br/>
                    Room Type : `+roomType+`,<br/>
                    Amount : Rs.`+amount+`,<br/>
                    Address : MIDC, Aurangabad<br/>
                    Reception : +911234567890<br/>
                    Map Link : https://bit.ly/34GZJKj<br/></h3>
                     
                    You can check-in using any government issued ID and address proof of any local or outstation address. Do carry your original (Photocopy not accepted) ID with you, for cross verification.
                    <br/>
                    Thanks`
                }
    
                transporter.sendMail(message, function(error, info){
                    if (error) {
                        console.log( 'Failure')
                    } else {
                        console.log( 'Success')
                    }
                });
            }
        })
    }catch(e){}
}   



module.exports.booking_history_by_date = async(req,res) => {
    var {token,initialDate,lastDate} = req.body;
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        console.log(initialDate)
        console.log(lastDate)
        await Room_Booking_schema.find({userId:id,startDate:{$gte:initialDate,$lte:lastDate}},function(err,result){
            if(err){
                  res.status(500).json({msg:"Error Occured"})
            }
            if(result){
                 console.log(result);
                  res.status(200).json({result:result,msg:"History Found Successfully"});
            }else{
                  res.status(404).json({msg:"History Not Found"});
            }
        });
    }catch(err){}
}


// room history still not checking in
module.exports.booking_history_for_cancellation = async(req, res) => {
    const {token} = req.body;
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        
        await Room_Booking_schema.find({userId:id,BookingStatus:"RoomPreBooked"},function(err,result){
            if(err){
                  res.status(500).json({msg:"Error Occured"})
            }
            if(result){
                  res.status(200).json({result:result,msg:"History Found Successfully"})
            }else{
                  res.status(404).json({msg:"History Not Found"});
            }
        });
    }catch(err){}
}


// book room cancel
module.exports.booking_room_can_be_cancel = async(req, res) => {
    const {token,roomId} = req.body;
    try{
        var month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        var result = await Room_Booking_schema.findOne({userId:id,roomid:roomId,BookingStatus:"RoomPreBooked"})
        // console.log(result)
        var orderId = result._id
        var startDate = new Date(result.startDate)
        var endDate = new Date(result.endDate)

        await Room_schema.updateOne({_id:roomId},{$set: {startDate:'null',status:'Available'}},function(err,result){
            if(result){
                Room_Booking_schema.updateOne({userId:id,roomid:roomId,BookingStatus:"RoomPreBooked"},{$set:{BookingStatus:"RoomCancelled",payment:"Cancel"}},function(err,cancelRoom){
                    if(cancelRoom){ 
                          res.status(200).json({msg:"Room Cancel Successfully"});
                          sendEmailForRoomCancelSuccessfully(id,orderId,startDate.getDate(),month[startDate.getMonth()-1],startDate.getFullYear(),endDate.getDate(),month[endDate.getMonth()-1],endDate.getFullYear());
                    }else{
                          res.status(400).json({msg:"Error Occured"})
                    }
                })
            }else{
                  res.status(400).json({msg:"Error Occured"})
            }
        })
    }catch(err){}
}

async function sendEmailForRoomCancelSuccessfully(userId,orderId,startDay,startMonth,startYear,endDay,endMonth,endYear){
    try{
        await User.findOne({_id:userId},(err,result)=>{
            if(result){
                var transporter = nodemailer.createTransport({
                    service: 'gmail',
                    auth: {
                        user: 'viveksonawane865@gmail.com',
                        pass: 'meenakshi@0101'
                    }
                }); 
    
                const message = {
                    from: 'viveksonawane865@gmail.com',
                    to: ''+result.email,
                    subject: 'Room Cancelled Successfully',
                    html: `Dear Customer, 
                        <br/>
                        Your booking from `+startDay+' '+startMonth+' '+startYear+` to `+endDay+' '+endMonth+' '+endYear+` with booking id `+orderId+` has been cancelled.
                        <br/>
                        Please Visit again.
                        <br/>
                        Thanks & Regards
                        <br/>
                        Zep
                    Thanks`
                }
    
                transporter.sendMail(message, function(error, info){
                    if (error) {
                        console.log( 'Failure')
                    } else {
                        console.log( 'Success')
                    }
                });
            }
        })
    }catch(e){}
}   



// Fetch User History
module.exports.user_history = async(req, res) => {
    const {token} = req.body;
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        let history = await User.findOne({_id: id},function(err,result){
            if(err){
                  res.status(500).json({msg:"Error Occured"})
            }
            if(result){
                  res.json({result:result});
            }else{
                  res.status(404).json({msg:"History Not Found"});
            }
        });
    }catch(err){}
}

// update data
module.exports.update = async(req, res) => {
    var {token,password} = req.body;
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        var salt = await bcrypt.genSalt();
        password = await bcrypt.hash(password, salt);
        await User.updateOne({_id: id},{$set:{password: password}},function(err,result){
            if(result){
                console.log(result);
                  res.status(200).json();
            }else{
                  res.status(503).json();        
            }
        })
    }catch(err){
          res.status(503);
    }
}

module.exports.getDetails = async(req,res) => {
    const {token} = req.body; 
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;

        await User.findOne({_id:id},function(err,result){
            if(err){    
                  res.status(500).json({msg:err});
            }
              res.status(200).json({email:result.email,mobile:result.mobileno});
        });
    }catch(err){
          res.status(500).json({msg:err});
    }
}



module.exports.generateToken = (req,res) => {

    const {amount,email,mobile} = req.body;
    console.log(email)                                                                                      
    var paytmParams = {};
    var orderId = uniqid();
    orderId = "ORDER_ID"+orderId;

    var customId = uuidv4();
    customId = "custId_"+customId;

    paytmParams.body = {
        "requestType"   : "Payment",
        "mid"           : "ycnaiy48639994765108",
        "websiteName"   : "WEBSTAGING",
        "orderId"       : orderId,
        "callbackUrl"   : `https://securegw-stage.paytm.in/theia/paytmCallback?mid=ycnaiy48639994765108&ORDER_ID=` + orderId,
        "txnAmount"     : {
            "value"     : amount,
            "currency"  : "INR",
        },
        "userInfo"      : {
            "custId"    : customId,
            "email":email,
            "mobile": mobile
        },
    };

        
    paytmParams.body[
        "disablePaymentMode"] = [{
        "mode": "CREDIT_CARD",
    }]
    paytmParams.body[
        "disablePaymentMode"] = [{
        "mode": "DEBIT_CARD",
    }]
  

    PaytmChecksum.generateSignature(JSON.stringify(paytmParams.body), "&N%Nbwkmeqa9!ZS4").then(function(checksum){

        paytmParams.head = {
            "signature"    : checksum
        };

        var post_data = JSON.stringify(paytmParams);

        var options = {

            /* for Staging */
            hostname: 'securegw-stage.paytm.in',

            /* for Production */
            // hostname: 'securegw.paytm.in',

            port: 443,
            path: '/theia/api/v1/initiateTransaction?mid=ycnaiy48639994765108&orderId='+orderId,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': post_data.length
            }
        };

        var response = "";
        var post_req = https.request(options, function(post_res) {
            post_res.on('data', function (chunk) {
                response += chunk;
            });

            post_res.on('end', function(){
                console.log('Response: ', response);
                response = JSON.parse(response);
                res.status(200).json({txnToken:response.body.txnToken,orderId:orderId});
            });
        });

        post_req.write(post_data);
        post_req.end();
    });
}

