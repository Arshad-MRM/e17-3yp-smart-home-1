let devices = require('../models/devices')
const nodeSchedule = require('node-schedule')

require("events").EventEmitter.defaultMaxListners = 70;

let mqtt = require('mqtt');

process.env.TZ = "Asia/Calcutta";

const clientId = "digitalHut_plug"
                const options = {
                    clientId,
}

let functions ={
    plugTurnOn: async function(req, res){
        try {
            if(
            !req.body.port,
            !req.body.deviceid,
            !req.body.state
            )
        {
            return res.json({ success: false, msg: "Enter All feilds for Smart Plugd" });
            }
            console.log("Plug Turn On",req.body.state);
            let state = (req.body.state == 'true');
            let client = mqtt.connect("mqtt://127.0.0.1:1883", options);
            let plug = { port: req.body.port, state: state, d_t: 2 }; //d_t --> Device type plug-->
            devices.findByIdAndUpdate(req.body.deviceid, {status: state}, (err, doc)=>{
                if (err) return res.json({ success: false, msg: err.message });
                if (!doc) return res.json({ success: false, msg: "Device Not Found" });
            })
            client.on('connect', function () {
                    client.publish('esp32/sub', JSON.stringify(plug), (error) => {
                        if (!error) {
                            client.end()
                            return res.json({success:true, msg: "successfully state Changed!", device:plug })
                        }
                        else {
                            client.end()
                            return res.json({ success: false, msg: error.message });
                        }
                    });
                });
        }catch(err){
            return res.json({
				success: false,
				msg: 'Error on turnOn try catch',
				error: err.message,
			});
        }
    }, 
    deviceStatus: async function (req, res) {
        try {
            if (req.body.deviceid) {
                devices.findById(req.body.deviceid, (err, doc) => {
                    // If error happen
                    if (err) return res.status(404).json({ success: false, msg: err.message });
                    if (!doc) return res.status(404).json({ success: false, msg: "Device Not found!" });
                    // If the device found
                    return res.json({ success: true, device: doc});
                    
                })
            } else {
                return res.json({ success: false, msg: "Enter the device_id" });
            }
        } catch (e) {
            console.log('catch e');
            return res.status(404).json({
				success: false,
				error: e.message,
            });
        }
    },

    rgbTurnOn: async function(req, res) 
    {
        try {
            if (
                !req.body.r,
                !req.body.g,
                !req.body.b,
                !req.body.brightness,
                !req.body.port,
                !req.body.deviceid,
                !req.body.state
            ) {
                return res.json({ success: false, msg: "Enter All feilds for RGB" });
            }
            let state = (req.body.state == "true")
            devices.findByIdAndUpdate(req.body.deviceid, { status: state, StartTime: Date.now() , brightness:req.body.brightness, r:req.body.r, g:req.body.g, b:req.body.b }, (err, doc) => {
                // If error happen
                if (err) return res.status(404).json({ success: false, msg: err.message });
                if (!doc) return res.status(404).json({ success: false, msg: "Device Not found!" });
            })
            let client = mqtt.connect("mqtt://127.0.0.1:1883", options);
            let dev ={state:state, brtns: req.body.brightness, port: parseInt(req.body.port), d_t: 1, r:req.body.r, g:req.body.g, b:req.body.b }
            console.log("Device Found")
                client.once('connect', function () {
                    console.log('connect');
                    client.publish('esp32/sub', JSON.stringify(dev), (error) => {
                        if (error) {
                            console.log(error.message);
                            client.end();
                            return res.status(404).json({ success: false, msg: error.message });
                        }
                        else {
                            console.log('send');
                            client.end();
                            return res.json({ success: true, msg: "successfully Turned On!", device: dev });
                        }
                    });
                });
        } catch (e) {
            console.log('catch e');
            console.log(e.message)
            return res.status(404).json({
				success: false,
				error: e.message,
            });
    }   
    },
        // Schuduling the Devices in the applications
    scheduleDevice : async function (req, res) {
        try {
            if (!req.body.schedulestate,
                !req.body.deviceid,
                !req.body.port,
                !req.body.StartTime,
                !req.body.EndTime,
                !req.body.d_t
            ) {
                return res.json({ success: false, msg: "Enter All the  feilds for scheule" });
            }
            console.log(req.body.StartTime, req.body.EndTime);
            let state = (req.body.schedulestate == "true");
            let StartTime = new Date(req.body.StartTime);
            let EndTime = new Date(req.body.EndTime);

            devices.findByIdAndUpdate(req.body.deviceid, { schedule: req.body.state, StartTime: StartTime, EndTime: EndTime }, (err, doc) => {
                if (err) return res.status(404).json({ success: false, msg: err.message });
                if (!doc) return res.status(404).json({ success: false, msg: "Device Not found!" });
            })
                if (state) {
                    console.log(StartTime.getMinutes(), StartTime.getHours());
                    nodeSchedule.scheduleJob(req.body.deviceid + "start", `${StartTime.getMinutes()} ${StartTime.getHours()} * * *`, () => {
                        let client = mqtt.connect("mqtt://127.0.0.1:1883", options);
                        devices.findByIdAndUpdate(req.body.deviceid, { status: true });
                        client.once('connect', function () {
                            console.log('Start Schedule');
                            client.publish('esp32/sub', JSON.stringify({ state: true, port: parseInt(req.body.port), d_t: req.body.d_t }), (error) => {
                                if (error) {
                                    console.log(error.message);
                                    client.end();
                                }
                                else {
                                    client.end();
                                    let startS = nodeSchedule.scheduledJobs[req.body.deviceid + "start"];
                                    startS.cancel();
                                    console.log('send');
                                }
                            });
                        });
                    });
                    console.log(EndTime.getMinutes(), EndTime.getHours());
                    nodeSchedule.scheduleJob(req.body.deviceid + "end", `${EndTime.getMinutes()} ${EndTime.getHours()} * * *`, () => {
                        let client = mqtt.connect("mqtt://127.0.0.1:1883", options);
                        devices.findByIdAndUpdate(req.body.deviceid, { status: false });
                        client.once('connect', function () {
                            console.log('End Schedule');
                            client.publish('esp32/sub', JSON.stringify({state:false, port:req.body.port, d_t:req.body.d_t }), (error) => {
                                if (error) {
                                    console.log(error.message);
                                    client.end();
                                }
                                else {
                                    client.end();
                                    let endS = nodeSchedule.scheduledJobs[req.body.deviceid + "end"];
                                    endS.cancel();
                                    console.log('send');
                                }
                            });
                        });
                    })
                } else {
                    let startS = nodeSchedule.scheduledJobs[req.body.deviceid + "start"];
                    let endS = nodeSchedule.scheduledJobs[req.body.deviceid + "end"];
                    console.log( startS,endS)
                    if (startS != undefined) {
                        startS.cancel();
                        endS.cancel();
                        console.log('Cleared...');
                    }
                }
            return res.status(200).json({ success: true, msg: "Schedule Successfully!" });
        } catch (e) {
            console.log(e.message);
            return res.json({success:false, msg: e.message})
        }
    },
    
}

module.exports = functions