const {User}=require('../models/usermodel');
const {Otp_schema} = require('../models/otpModel');
const {Room_schema} = require('../models/roomModel');  
const {Room_Booking_schema} = require('../models/bookRoomModel')
const mongoose = require('mongoose');
const schedule = require('node-schedule');
var jwt = require('jsonwebtoken');
const jwt_decode = require('jwt-decode');
const bcrypt = require('bcrypt');
const Nexmo = require('nexmo');
const moment = require('moment');
//paytm
const https = require("https");
const qs = require("querystring");
// const checksum_lib = require('../paytm/checksum');
// const config = require('../paytm/config');


// configuration for sms
const nexmo = new Nexmo({
    apiKey: '69f9d1fd',
    apiSecret: '9EVu7AcRoPKlH4i8',
  });

//signup
module.exports.signup_post = async (req, res) => {
    var {first_name, last_name, mobileno, email, password} = req.body;
    try{
        var salt = await bcrypt.genSalt();
        password = await bcrypt.hash(password, salt);
        let user = await User.findOne({email});
        if (user) {
            return res.status(409).json({msg: "User already registered"});
        }
        user = new User({first_name, last_name, mobileno, email, password});
        await user.save();
        var token = jwt.sign({id: user.id}, "password");
        return res.status(200).json({token: token, msg: 'User registered'})
    }catch(err){}
    
}

//login
module.exports.login_post = async (req, res) => {
    var {email, password} = req.body;
    
    try{
        let user = await User.findOne({email:email});
        if (!user) {
            return res.status(404).json({msg:"User not found"});
        }
        var auth = await bcrypt.compare(password, user.password);
        if (!auth) {
            return res.status(409).json({msg:" Invalid data"});
        } else {
            var token = jwt.sign({id: user.id}, "password");
            var id = user._id
            return res.status(201).json({token:token,msg: "User Login Successfully",name:user.first_name});
        }
    }catch(e){}
}



// send OTP
module.exports.send_otp = async (req, res) => {
    const {email,phoneNo} = req.body;
    try{
        let otpNo = generateOTP();
        var responseData = 200;
        let user = await User.findOne({email,mobileno: phoneNo});
        if(user) {
            var minute = moment().add(5,'minute');
            let otp = new Otp_schema({email: user.email,phoneNo:phoneNo,otp:otpNo,minute:minute.get('minute'),second:moment().get('second')});
            let otpSave = otp.save();
            if(otpSave){
                const from = 'Vonage APIs';
            const to = '91'+phoneNo;
            const text = 'Your One Time Password is '+otpNo;
            nexmo.message.sendSms(from, to, text,(err,responseData) => {
                if (err) {
                    return res.status(500).json({msg:'error occurred'});
                } else {
                    if(responseData.messages[0]['status'] === "0") {
                        return res.status(200).json({msg:'message successfully sent'});
                    } else {   
                        return res.status(500).json({msg:'message sent unsuccessfully'});
                    }
                }
            });
            }
        }else{
            return res.status(404).json({msg: "User Not Found"});
        }
    }catch(e){}
}

function generateOTP(){
    var otp = "";
    var digits = "0123456789"
    for(var i=0;i<4;i++){
        otp += digits[Math.floor(Math.random() * 10)];
    }
    return otp;
}

// update otp on resend otp
module.exports.resend_otp = async(req, res) => {
    const {email,phoneNo} = req.body;
    try{
        let otpNo = generateOTP();
        let user = await User.findOne({email,mobileno: phoneNo});
        if(user){
            let otp = await Otp_schema.findOne({email,phoneNo});
            var minute = moment().add(5,'minute');
            await Otp_schema.updateOne({email,phoneNo},{$set: {otp: otpNo,minute:minute.get('minute'),second:moment().get('second')}},function(err,result){
                if(err){}
                if(result){
                const from = 'Vonage APIs';
                const to = '91'+phoneNo;
                const text = 'Your One Time Password is '+otpNo;
                nexmo.message.sendSms(from, to, text,(err,responseData) => {
                    if (err) {
                        return res.status(500).json({msg:'error occurred'});
                    } else {
                        if(responseData.messages[0]['status'] === "0") {
                            return res.status(200).json({msg:'otp successfully sent'});
                        } else {   
                            return res.status(500).json({msg:'otp sent unsuccessfully'});
                        }
                    }
                }); 
                }  
            })
        }
    }catch(e){} 
}

// delete otp after 5 min
schedule.scheduleJob('*/1 * * * * *',async(timer) =>{
    await Otp_schema.deleteMany({minute:timer.getMinutes(),second:timer.getSeconds()},function(err,result){
        if(result){
            // console.log("Otp delete successfully");
        }
    })
});

// verify otp
module.exports.verify_otp = async(req,res) => {
    const {email,phoneNo,otp} = req.body;
    try{
        await Otp_schema.findOne({email,phoneNo,otp},function(err,result){
            if(err){
                return res.status(500).json({msg:"Error Occured"});
            }
            if(result){
                return res.status(200).json({msg:"Otp Validated Successfully"})
            }else{
                return res.status(404).json({msg:"Wrong otp entered"});
            }
        });
    }catch(e){}
}


// reset password
module.exports.reset_password = async(req, res) => {
    let {email,phoneNo,password} = req.body;
    try{
        var salt = await bcrypt.genSalt();
        password = await bcrypt.hash(password, salt);
        await User.updateOne({email: email, mobileno: phoneNo}, {$set:{password: password}},function(err,result){
            if(err){
                return res.status(500).json({msg:"Error Occured"});
            }
            if(result){
                return res.status(200).json({msg:'Password updated successfully'});
            }else{
                return res.status(400).json({msg:'Error Occured'});
            }
        });

    }catch(e){}
}

module.exports.getName = async(req, res) => {
    const {token} = req.body;
    var decoded = jwt_decode(token, true);
    var id = decoded.id;
    try{
        await User.findOne({_id: id}, function(err,result){
            if(result){
                // console.log(result);
                return res.status(200).json({name:result.first_name});
            }
        });
    }catch(e){}
}

module.exports.change_room_status_book = async(req, res) => {
    const {roomId} = req.body;
    try{
        await Room_schema.updateOne({_id: roomId},{$set:{isProcessingForBook:true}},function(err,result){
            if(result){
                return res.status(200).json(result);
            }
        })
    }catch(e){}
}

module.exports.change_room_status_available = async(req, res) => {
    const {roomId} = req.body;
    await Room_schema.updateOne({_id: roomId},{$set:{isProcessingForBook:false}},function(err,result){
        if(result){
            return res.status(200).json(result);
        }
    })
}

// add room
// module.exports.add_room = async(req,res) => {
//     const {roomNo,description,status,pricePerDay,numberofBed,typeAcOrNot} = req.body;   
//     let room_ = new Room_schema({roomNo, description, status, pricePerDay, numberofBed,typeAcOrNot});
//     let save_room = await room_.save();
//     // let Room_Status_schema = new RoomStatus_schema({roomId:room_.id,status:"0",dateOfBooking:null,dateOfEnding:null});
//     // Room_Status_schema.save();
// }

//update user profile
module.exports.update=async(req,res)=>{
    var {password,token} = req.body;
    var salt = await bcrypt.genSalt();
    password = await bcrypt.hash(password, salt);
    var decoded = jwt_decode(token, true);
    var id = decoded.id;
    let user = await User.findOne({_id: id});
    try{
        if(user){
            User.updateOne({_id:user._id},{$set:{password:password}},function(err,result){
                if(err){
                    print(err)
                }
                else{
                    res.json({msg:"Success"})
                }
            })
        }
    }catch(err){}
}


 // Luxury Available Room
 module.exports.luxury_room = async (req, res) => {
    try{
        await Room_schema.find({status:'Available',Type:'Luxory',isProcessingForBook:false},function(err,result){
            if(err){
                return res.status(500).json({err});
            }
            if(result.length != 0){
                return res.status(200).json({result:result,msg: "Room Found Successfully"});
            }else{
                return res.status(404).json({msg:"Rooms Not Available"});
            }
        });
    }catch(err){}
}




 // super delux Available Room
 module.exports.super_delux = async (req, res) => {
    try{
        await Room_schema.find({status:'Available',Type:'SuperDelux',isProcessingForBook:false},function(err,result){
            if(err){
                return res.status(500).json({err});
            }
            if(result.length != 0){
                return res.status(200).json({result:result,msg: "Room Found Successfully"});
            }else{
                return res.status(404).json({msg:"Rooms Not Available"});
            }
        });
    }catch(err){}
}


 // Delux Available Room
 module.exports.delux_room = async (req, res) => {
    try{
        await Room_schema.find({status:'Available',Type:'Delux',isProcessingForBook:false},function(err,result){
            if(err){
                return res.status(500).json({err});
            }
            if(result.length != 0){
                return res.status(200).json({result:result,msg: "Room Found Successfully"});
            }else{
                return res.status(404).json({msg:"Rooms Not Available"});
            }
            
        });
    }catch(err){}
}

// book Room
module.exports.book_room = async (req, res) => {
    const {token,roomId,startDate,endDate,Amount,documentName,documentType,roomType,roomNumber,roomIsStillChecking} = req.body;
    print(req.body.object); 
    try{
    var decoded = jwt_decode(token, true);
    var id = decoded.id;
    let userData = await User.findOne({_id:id});
    var date = new Date(startDate);
    var date1 = new Date(endDate);
    var now = new Date();
    
    await Room_schema.find({_id:roomId,isProcessingForBook:true},function(err,result){
        if(result['status']=='Available'){
            let book_room ;
            if(date.getHours()>=11 &&  now.getDate() == date.getDate()){
                book_room = new Room_Booking_schema({userId:id,roomId,startDate,Name:userData.first_name+" "+userData.last_name,Phone:userData.mobileno,endDate,Amount,documentName,documentType,roomNumber,roomType,status:'Booked',roomIsStillChecking:true}); 
            }else{
                book_room = new Room_Booking_schema({userId:id,roomId,startDate,Name:userData.first_name+" "+userData.last_name,Phone:userData.mobileno,endDate,Amount,documentName,documentType,roomNumber,roomType,status:'Booked',roomIsStillChecking:false}); 
            }
            book_room.save().then((success)=>{
                if(success) {
                    Room_schema.updateOne({_id:roomId},{$set:{status:"Booked"}},function(err,result1){
                        if(err){
                            return res.status(504).json({msg:"Error Occured"});
                        }else{
                            if(result1){
                                return res.status(200).json({msg:"Room Booked Successfully"});
                            }else{
                            return res.status(503).json({msg:"Error Occured"});
                            }
                        }
                    })
                    
                }else{
                    return res.status(503).json({msg:"Error Occured"});
                }
            })
        }else if(result['status']=='Booked'){
            return res.status(503).json({msg:"Error Occured"});
        }
    })}catch(err){
        console.log(err);
        return res.status(504).json({msg:"Error Occured"});
    }
}

// Booking History
module.exports.booking_history = async(req, res) => {
    const {token} = req.body;
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        await Room_Booking_schema.find({$and:[{userId:id},{roomIsStillChecking:true}]},function(err,result){
            if(err){
                return res.status(500).json({msg:"Error Occured"})
            }
            if(result){
                Room_schema.find({_id:result.roomId},function(err,result1){
                    // result.push(result1.description);
                    return res.status(200).json({result:result,msg:"History Found Successfully"});
                });
            }else{
                return res.status(404).json({msg:"History Not Found"});
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
        // var id = "6089740f01f3600a54c33934";
        let history = await Room_Booking_schema.find({$and:[{userId:id},{roomIsStillChecking:false}]},function(err,result){
            if(err){
                return res.status(500).json({msg:"Error Occured"})
            }
            if(result){
                return res.status(200).json({result:result,msg:"History Found Successfully"});
            }else{
                return res.status(404).json({msg:"History Not Found"});
            }
        });
    }catch(err){}
}

// book room cancel
module.exports.booking_room_can_be_cancel = async(req, res) => {
    const {token,roomId} = req.body;
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        await Room_Booking_schema.deleteOne({$and:[{userId:id},{roomId:roomId},{roomIsStillChecking:false}]},function (err,result){
            if(err){
                return res.status(500).json({msg:"Error Occured"})
            }
            if(result){
                Room_schema.updateOne({_id:roomId},{$set:{status:'Available'}},function(err,cancelRoom){
                    if(cancelRoom){
                        return res.status(200).json({msg:"Room Cancel Successfully"});
                    }else{
                        return res.status(500).json({msg:"Error Occured"})
                    }
                });
                
            }
        });
    }catch(err){}
}

// update check in status
schedule.scheduleJob('00 00 11 * * *', async function(){
    await Room_Booking_schema.find({},function(err,result){
        result.forEach(checkValueAndUpdate);
    })
});



async function checkValueAndUpdate (value, index, array) {
    var date = new Date(value['startDate']);
    var now = new Date();
    if(date.getDate() == now.getDate()){
        if(value['roomIsStillChecking'] == false){
            await Room_Booking_schema.updateOne({userId:value['userId'],roomId:value['roomId']},{$set:{roomIsStillChecking :true}});
        }
    }
}

// Fetch User History
module.exports.user_history = async(req, res) => {
    const {token} = req.body;
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        let history = await User.findOne({_id: id},function(err,result){
            if(err){
                return res.status(500).json({msg:"Error Occured"})
            }
            if(result){
                // console.log(result);
                return res.json({result:result});
            }else{
                return res.status(404).json({msg:"History Not Found"});
            }
        });
    }catch(err){}
}

// update data

module.exports.update = async(req, res) => {
    const {token,email,phoneNo} = req.body;
    try{
        var decoded = jwt_decode(token, true);
        var id = decoded.id;
        await User.updateOne({_id: id},{$set:{email:email, mobileno: phoneNo}},function(err,result){
            if(result){
                return res.status(200);
            }
        })
    }catch(err){
        return res.status(503);
    }
}

// get Room 
module.exports.getAllRoom = async(req, res) =>{
    // await Rośśśśom_schema.updateMany({status:"Booked"},{$set:{status:'Available'}});
    await Room_schema.find({}, function(err,result){
        if(result){
            return res.status(200).json(result);
        }
    })
}

module.exports.deleteAllDetail = async(req, res) =>{
    await Room_Booking_schema.deleteMany({},function(err,result){
        if(result){
            return res.json(result);
        }
        return res.json(1);
    })
}

module.exports.getAllDetail = async(req, res) =>{
    await User.find({},function(err,result){
        if(result){
            return res.json(result);
        }
        return res.json(1);
    })
}

module.exports.getOtp = async() => {
    // await Otp_schema.deleteMany({});
    await Otp_schema.find({},function(err,result){
        console.log(result);
    })
}

module.exports.getAllBookRoomDetail = async(req, res) =>{
    await Room_Booking_schema.find({},function(err,result){
        if(result){
            return res.json(result);
        }
        return res.json(1);
    })
}

//payment GateWay
// module.exports.paynow_post=(req, res) => {
//     // Route for making payment
//     console.log(req.body);
//     var paymentDetails = {
//         amount: req.body.amount,
//         customerId: req.body.name,
//         customerEmail: req.body.email,
//         customerPhone: req.body.phone
//     }
//     console.log(paymentDetails.customerId);

//     if (!paymentDetails.amount || !paymentDetails.customerId || !paymentDetails.customerEmail || !paymentDetails.customerPhone) {
//         res.status(400).send('Payment failed')
//     } else {
//         var params = {};
//         params['MID'] = config.PaytmConfig.mid;
//         params['WEBSITE'] = config.PaytmConfig.website;
//         params['CHANNEL_ID'] = 'WEB';
//         params['INDUSTRY_TYPE_ID'] = 'Retail';
//         params['ORDER_ID'] = 'TEST_' + new Date().getTime();
//         params['CUST_ID'] = paymentDetails.customerId;
//         params['TXN_AMOUNT'] = paymentDetails.amount;
//         params['CALLBACK_URL'] = 'http://10.0.2.2:3000/callback';
//         params['EMAIL'] = paymentDetails.customerEmail;
//         params['MOBILE_NO'] = paymentDetails.customerPhone;


//         checksum_lib.genchecksum(params, config.PaytmConfig.key, function (err, checksum) {
//             var txn_url = "https://securegw-stage.paytm.in/theia/processTransaction"; // for staging
//             // var txn_url = "https://securegw.paytm.in/theia/processTransaction"; // for production

//             var form_fields = "";
//             for (var x in params) {
//                 form_fields += "<input type='hidden' name='" + x + "' value='" + params[x] + "' >";
//             }
//             form_fields += "<input type='hidden' name='CHECKSUMHASH' value='" + checksum + "' >";

//             res.writeHead(200, {'Content-Type': 'text/html'});
//             res.write('<html><head><title>Merchant Checkout Page</title></head><body><center><h1>Please do not refresh this page...</h1></center><form method="post" action="' + txn_url + '" name="f1">' + form_fields + '</form><script type="text/javascript">document.f1.submit();</script></body></html>');
//             res.end();
//         });
//     }
// };


// module.exports.callback= (req, res) => {
//     // Route for verifiying payment

//     var body = '';

//     req.on('data', function (data) {
//         body += data;
//     });

//     req.on('end', function () {
//         var html = "";
//         var post_data = qs.parse(body);

//         // received params in callback
//         console.log('Callback Response: ', post_data, "\n");


//         // verify the checksum
//         var checksumhash = post_data.CHECKSUMHASH;
//         // delete post_data.CHECKSUMHASH;
//         var result = checksum_lib.verifychecksum(post_data, config.PaytmConfig.key, checksumhash);
//         console.log("Checksum Result => ", result, "\n");


//         // Send Server-to-Server request to verify Order Status
//         var params = {"MID": config.PaytmConfig.mid, "ORDERID": post_data.ORDERID};

//         checksum_lib.genchecksum(params, config.PaytmConfig.key, function (err, checksum) {

//             params.CHECKSUMHASH = checksum;
//             post_data = 'JsonData=' + JSON.stringify(params);

//             var options = {
//                 hostname: 'securegw-stage.paytm.in', // for staging
//                 // hostname: 'securegw.paytm.in', // for production
//                 port: 443,
//                 path: '/merchant-status/getTxnStatus',
//                 method: 'POST',
//                 headers: {
//                     'Content-Type': 'application/x-www-form-urlencoded',
//                     'Content-Length': post_data.length
//                 }
//             };


//             // Set up the request
//             var response = "";
//             var post_req = https.request(options, function (post_res) {
//                 post_res.on('data', function (chunk) {
//                     response += chunk;
//                 });

//                 post_res.on('end', function () {
//                     console.log('S2S Response: ', response, "\n");

//                     var _result = JSON.parse(response);
//                     if (_result.STATUS  == 'TXN_SUCCESS') {
//                         res.send({
//                             status: 0,
//                             data: _result
//                         })
//                     } else {
//                         res.send({
//                             status: 1,
//                             data: _result
//                         })
//                     }
//                 });
//             });

            
//             post_req.write(post_data);
//             post_req.end();
//         });
//     });
// };
