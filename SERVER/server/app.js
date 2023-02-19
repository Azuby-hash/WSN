const express = require('express');
const fs = require('fs');

const app = express();

// Password bảo mật
const password = "9797964a-2f5c-41c6-91c1-44aa68308631"


module.exports = {
    app: app,
}

app.use(express.static('client'));
app.use(express.static('server'));

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Nhận giá trị truyền
app.post(`/espPost`, (req, res) => {
    const value = req.body.value // Giá trị truyền
    const number = req.body.number - 1 // Node id
    const isSP = req.body.isSP // Giá trị truyền là `Setpoint` hay `Value`
    const pass = req.body.password // Mật khẩu xác minh

    if (pass == password) {
        fs.readFile('server/data.json', 'utf8', (err, data) => {
            // Chuyển đổi JSON thành Object
            const json = JSON.parse(data);
            
            // Lấy key của node
            var key = `esp${number + 1}`
            var sup = `espSP${number + 1}`
            if (isSP) {
                key = `espSP${number + 1}`
                sup = `esp${number + 1}`
            }
            
            // In ra giá trị
            console.log(`ESP${isSP ? "SP" : ""}${number + 1}: ${value}`);

            // Tạo trường mới nếu không tồn tại (node mới)
            if (json[key] == undefined) {
                json[key] = [];
                json[sup] = [{value: 40, date: Date.now() / 1000}];
            }

            // Thêm giá trị vào array để lưu trữ
            json[key] = [...json[key], {value: value, date: Date.now() / 1000}]

            // console.log(json[key]);
            
            // Lưu vào file
            fs.writeFile('server/data.json', JSON.stringify(json), (err, data) => {
                res.header('Access-Control-Allow-Origin', '*');
                res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
                res.send(`ESP_${number + 1} is set to ` + value)
            });
        });
    } else {
        // Sai mật khẩu

        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(`Key not authorized!`)
    }
});

// Trả giá trị
app.post('/espGet', (req, res) => {
    const pass = req.body.password // Mật khẩu xác minh

    if (pass == password) {
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');

        if (req.body.number != undefined && req.body.isSP!= undefined) {
            // Lấy giá trị node chỉ định

            const number = req.body.number - 1 // Node id
            const isSP = req.body.isSP // Giá trị trả là `Setpoint` hay `Value`

            // Lấy Object từ file
            const json = JSON.parse(fs.readFileSync('server/data.json', 'utf8'));

            if (json[`esp${isSP ? "SP" : ""}${number + 1}`] != undefined) { 
                // Trả giá trị tồn tại

                const values = json[`esp${isSP ? "SP" : ""}${number + 1}`].sort((a, b) => a.date < b.date)
                res.send(values[values.length - 1] == undefined ? "Unavailable" : `${values[values.length - 1].value}`)
                return
            } else {
                // Giá trị không tồn tại

                res.send("Unavailable")
                return
            }
        }

        // Lấy giá trị tất cả các node
        res.send(fs.readFileSync('server/data.json', 'utf8'))
    } else {
        // Sai mật khẩu

        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(`Key not authorized!`)
    }
})

app.post('/espConfig', (req, res) => {
    const pass = req.body.password // Mật khẩu xác minh
    
    if (pass == password) { 
        // Đúng mật khẩu

        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(`Authorized`)
    }
})