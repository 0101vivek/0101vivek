const express = require('express');
const router = express.Router();
const parseUrl = express.urlencoded({extended: false});
const parseJson = express.json({extended: false});
const authControllers = require('../controllers/authcontrollers');

router.post('/signup',authControllers.signup_post);
router.post('/login',authControllers.login_post );
router.post('/send_otp',authControllers.send_otp );
router.post('/resend_otp',authControllers.resend_otp);
router.post('/verify_otp',authControllers.verify_otp);
router.post('/reset_password',authControllers.reset_password);
router.post('/getName',authControllers.getName);
router.post('/change_room_status_book',authControllers.change_room_status_book);
router.post('/change_room_status_available',authControllers.change_room_status_available);
router.get('/luxury_room',authControllers.luxury_room);
router.get('/super_delux_room',authControllers.super_delux);    
router.get('/delux_room',authControllers.delux_room);
router.post('/book_room',authControllers.book_room);
router.post('/booking_history',authControllers.booking_history);
router.post('/booking_room_cancellation_history',authControllers.booking_history_for_cancellation);
router.post('/cancel_room',authControllers.booking_room_can_be_cancel);
router.post('/update',authControllers.update);
router.post('/user_history',authControllers.user_history);


router.get('/getAllRoom',authControllers.getAllRoom);
router.get('/getAllDetails',authControllers.getAllDetail);
router.get('/getAllBookRoomDetail',authControllers.getAllBookRoomDetail);
router.get('/delete',authControllers.deleteAllDetail);
router.get('/otp',authControllers.getOtp);
module.exports = router;
