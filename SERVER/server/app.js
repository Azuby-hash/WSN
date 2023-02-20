const express = require('express');
const fs = require('fs');

const app = express();

const password = "9797964a-2f5c-41c6-91c1-44aa68308631"

module.exports = {
    app: app,
}

app.use(express.static('server'));

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

app.post(`/espPost`, (req, res) => {
    const value = req.body.value
    const number = req.body.number - 1
    const isSP = req.body.isSP
    const pass = req.body.password

    if (pass == password) {
        fs.readFile('server/data.json', 'utf8', (err, data) => {
            const json = JSON.parse(data);
            
            var key = `esp${number + 1}`
            var sup = `espSP${number + 1}`
            if (isSP) {
                key = `espSP${number + 1}`
                sup = `esp${number + 1}`
            }
            // espSP3
            // console.log(key);
            console.log(value);

            if (json[key] == undefined) {
                json[key] = [];
                json[sup] = [40];
            }

            json[key] = [...json[key], {value: value, date: Date.now() / 1000}]

            // console.log(json[key]);
            
            fs.writeFile('server/data.json', JSON.stringify(json), (err, data) => {
                res.header('Access-Control-Allow-Origin', '*');
                res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
                res.send(`ESP_${number + 1} is set to ` + value)
            });
        });
    } else {
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(`Key not authorized!`)
    }
});

app.post('/espGet', (req, res) => {
    const pass = req.body.password

    if (pass == password) {
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');

        if (req.body.number != undefined && req.body.isSP!= undefined) {

            const number = req.body.number - 1
            const isSP = req.body.isSP

            const json = JSON.parse(fs.readFileSync('server/data.json', 'utf8'));
            if (json[`esp${isSP ? "SP" : ""}${number + 1}`] != undefined) { 
                const values = json[`esp${isSP ? "SP" : ""}${number + 1}`].sort((a, b) => a.date < b.date)
                res.send(values[values.length - 1] == undefined ? "Unavailable" : `${values[values.length - 1].value}`)
                return
            } else {
                res.send("Unavailable")
                return
            }
        }

        res.send(fs.readFileSync('server/data.json', 'utf8'))
    } else {
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(`Key not authorized!`)
    }
})

app.post('/espConfig', (req, res) => {
    const pass = req.body.password
    
    if (pass == password) { 
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(`Authorized`)
    }
})