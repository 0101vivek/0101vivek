const express = require('express');
const multer = require('multer');
const router = express.Router();
const {store_image} = require("./multer");
const addRoom = require('../controllers/roomController');
router.post('/',multer({storage : store_image}).single("image"),addRoom.addRoom);

module.exports = router;