const multer = require('multer');

const MIME_TYPE_MAP={
    'image/png':'png',
    'image/jpeg':'jpg',
    'image/jpg':'jpg'
}


module.exports.storage = multer.diskStorage ({
    destination : (req, file , cb)=>{
      
      const isValid = MIME_TYPE_MAP[file.mimetype]
      let error = new Error("Invalid MimeType");
      if(isValid)
      {
        error = null;
      }
      cb(error, "images/");
    },
    filename:(req,file,cb)=>{
      const name = file.originalname.toLowerCase().split(' ').join('-');//spliting blank spaces in name and joining them with -
      const ext = MIME_TYPE_MAP[file.mimetype];//this will give us the mime type of the file
      cb(null,name);
    }
});


