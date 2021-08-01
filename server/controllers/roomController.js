const room = require('../models/roomModel');

module.exports.addRoom =  (req,res)=>{
    try{
      let message = "Room added successfully."
      const url = req.protocol+'://'+req.get("host"); 
      console.log(url);
      const {
        roomNumber : roomNumber,
        Type : Type,
        description : description,
        charges : charges
      }= req.body
    
    
      let Room = new room({
        roomNumber,
        Type,
        description,
        charges,
        image : url + "/images/"+req.file.filename,
        status : "Available"
      });
      Room.save((error,Room)=>{
        if(error)
        {
          console.log(error);
        }else{
          res.json(Room);
        }
      })
    }catch(err){
      console.log("Error while adding Room",err)
    }  
  }