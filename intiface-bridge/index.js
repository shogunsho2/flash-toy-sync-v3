let express = require("express");
let W3CWebSocket = require("websocket").w3cwebsocket;
let performanceNow = require("performance-now");

let lastMessageId = 1;
let pendingResponseHandlers = [];
let isConnected = false;
let isPlayingScript = false;
let lastTimestamp = -1;

let preparedPositions = null;
let playStartTime = -1;
let playStartTimeInScript = -1;
let playScriptTimeout = -1;

let scaleV = 1.0;

// Websocket
let socket = new W3CWebSocket("ws://localhost:12345");

socket.onerror = (error) => {
    if (isConnected === false) {
        console.log("Unable to connect to intiface server");
        console.log("Make sure the server is running in intiface desktop and that no other clients have been connected to it, including the device list panel")
        anyKeyToExitPrompt();
    }
};

socket.onopen = () => {
    isConnected = true;
    init();
};

socket.onclose = () => {
    if (isConnected === true) {
        console.log("Disconnected from intiface server");
        anyKeyToExitPrompt();
    }
    isConnected = false;
};

socket.onmessage = (e) => {
    let dataObject = JSON.parse(e.data);
    let command = Object.keys(dataObject[0])[0];
    let id = dataObject[0][command].Id;

    if (dataObject[0].DeviceRemoved != undefined) {
        console.log("The device has been disconnected from intiface");
        anyKeyToExitPrompt();
        return;
    }

    let handlerIndex = pendingResponseHandlers.findIndex(handler => {
        return handler.id === id;
    });

    if (pendingResponseHandlers[handlerIndex].callback !== undefined) {
        pendingResponseHandlers[handlerIndex].callback(dataObject);
    }

    pendingResponseHandlers.splice(handlerIndex, 1);
};

// Methods
let anyKeyToExitPrompt = () => {
    console.log("");
    console.log("Press any key to exit");
    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.on("data", process.exit.bind(process, 0));
}

let getNextMessageId = () => {
    return lastMessageId++;
}

let sendSocketMessage = (data, id, callback) => {
    let promiseResolve = null;
    let promise = new Promise(resolve => {
        promiseResolve = resolve;
    });

    let dataString = JSON.stringify(data);
    pendingResponseHandlers.push({ id, callback: promiseResolve });
    socket.send(dataString);

    return promise;
}

let init = async (callback) => {
    if (isConnected === false) {
        if (callback != undefined) {
            callback({ error: "Unable to initialize intiface-bridge, the websocket is not connected" });
        }
        return;
    }

    let initMessageId = getNextMessageId();
    let initMessage = [
        {
            "RequestServerInfo": {
                "Id": initMessageId,
                "ClientName": "Flash-toy-sync",
                "MessageVersion": 1
            }
        }
    ];

    let deviceListMessageId = getNextMessageId();
    let deviceListMessage = [
        {
            "RequestDeviceList": {
                "Id": deviceListMessageId
            }
        }
    ];

    await sendSocketMessage(initMessage, initMessageId);

    let deviceListResponse = await sendSocketMessage(deviceListMessage, deviceListMessageId);

    let totalDevices = deviceListResponse[0].DeviceList.Devices.length;

    if (totalDevices === 0) {
        console.log("No devices connected to intiface, make sure you have connected at least one device");
        anyKeyToExitPrompt();
        return;
    }

    console.log("Connected to intiface server");
    if (callback != undefined) {
        callback();
    }
}

setInterval(() => {
    if (isPlayingScript === false) {
        lastTimestamp = performanceNow();
        return;
    }

    let currentTimestamp = Math.floor(performanceNow());
    let elapsedTime = currentTimestamp - playStartTime;
    let currentScriptTime = playStartTimeInScript + elapsedTime;
    let lastScriptTime = currentScriptTime - (currentTimestamp - lastTimestamp);

    let lastPosition = preparedPositions.find(pos => pos.time >= currentScriptTime);
    let currentPosition = preparedPositions.find(pos => pos.time >= lastScriptTime);
    let currentPositionIndex = preparedPositions.indexOf(currentPosition);
    let nextPosition = null;

    if (currentPosition !== lastPosition && currentPositionIndex >= 0 && currentPositionIndex < preparedPositions.length - 1) {
        nextPosition = preparedPositions[currentPositionIndex + 1];
    }

    if (nextPosition !== null) {
        let duration = nextPosition.time - currentScriptTime;

        //let messageId = getNextMessageId();
        // let linearCmdMessage = [
        //     {
        //         "LinearCmd": {
        //             "Id": messageId,
        //             "DeviceIndex": 0,
        //             "Vectors": [
        //                 {
        //                     "Index": 0,
        //                     "Duration": duration,
        //                     "Position": nextPosition.position
        //                 }
        //             ]
        //         }
        //     }
        // ]
        //sendSocketMessage(linearCmdMessage, messageId);
        speedV = (1-nextPosition.position )*scaleV;
        console.log(speedV)

        let messageIdV = getNextMessageId();
        let linearCmdMessageV = [
            {
                "VibrateCmd": {
                    "Id": messageIdV,
                    "DeviceIndex": 0,
                    "Speeds": [
                        {
                            "Index": 0,
                            "Speed": speedV
                        }
                    ]
                }
            }
        ]
        //console.log(linearCmdMessageV);
        sendSocketMessage(linearCmdMessageV, messageIdV);
        new Promise(resolve => setTimeout(resolve, duration));
        //sleep(duration);
    }

    lastTimestamp = currentTimestamp;
}, 1);

// Server
let app = express();
var bodyParser = require('body-parser');

 app.use(bodyParser.urlencoded({
  extended: true,
  limit: '50mb',
  parameterLimit: 100000
  }))

 app.use(bodyParser.json({
  limit: '50mb',
  parameterLimit: 100000
 }))
 app.use(bodyParser.raw({
    limit: '50mb',
    parameterLimit: 100000
   }))
   app.use(bodyParser.text({
    limit: '50mb',
    parameterLimit: 100000
   }))
app.listen(3000);

// We use text instead of JSON, as the AS2 version can't post JSON
app.post("/prepareScript", express.text(), (req, res) => {
    if (isConnected == false) {
        res.send({ error: "Unable to prepare script, it's not connected to intiface" });
        return;
    }

    try {
        preparedPositions = JSON.parse(req.body); 
    } catch (error) {
        // For supporting the AS2 version, which sends the data in the form of LoadVars
        let body = decodeURIComponent(req.body);
        let bodyIndex = body.indexOf("body=");
        let jsonString = body.substring(bodyIndex + "body=".length, body.indexOf("&"));
        preparedPositions = JSON.parse(jsonString);
        
    }
    //console.log(preparedPositions);
    res.send({});
});

app.get("/playScript", (req, res) => {
    if (isConnected == false) {
        res.send({ error: "Unable to play script, it's not connected to intiface" });
        return;
    }

    if (preparedPositions === null) {
        res.send({ error: "Unable to play script, there are no prepared positions" });
        return;
    }

    playStartTime = Math.floor(performanceNow());
    console.log("req.query.time" + req.query.time)
    playStartTimeInScript = parseInt(req.query.time);
    console.log("playStartTimeInScript " + playStartTimeInScript);
    isPlayingScript = true;

    clearTimeout(playScriptTimeout);

    res.send({});
});


app.get("/stop", (req, res) => {
    if (isConnected == false) {
        res.send("Unable to stop script, it's not connected to intiface");
        return;
    }

    if (preparedPositions === null) {
        res.send({ error: "Unable to stop script, there are no prepared positions" });
        return;
    }

    playStartTime = -1;
    playStartTimeInScript = -1;
    isPlayingScript = false;

    clearTimeout(playScriptTimeout);

    let messageId = getNextMessageId();
    let stopMessage = [
        {
            "StopAllDevices": {
                "Id": messageId
            }
        }
    ];

    sendSocketMessage(stopMessage, messageId).then(date => {
        res.send({});
    });
});