const express = require('express');
const app = express();
const authRoutes = require('./routes/authRoutes');
const port = 3000 || process.env.PORT;
const mongoose = require('mongoose');
const roomRoute = require('./routes/roomRoute')
const cors = require('cors');


app.use(express.json({ extended: false }));

app.use(cors())
app.get('/', (req, res) => {
    res.send('Hello World!')
})

app.use(authRoutes);

app.use('/images',express.static('images'));
app.use('/addRoom',roomRoute);


app.listen(port, async () => {
    await mongoose.connect("mongodb+srv://Pixel:Jerry@cluster0.pvepn.mongodb.net/ZEPRoomBooking?retryWrites=true&w=majority", {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        useCreateIndex: true,
        useFindAndModify: true
    });
    console.log("connectDB");
    console.log(`You are listening to port ${port}`);
});
