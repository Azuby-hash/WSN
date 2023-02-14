# WIRELESS SENSOR NETWORK (WSN)

## Author: Le Thanh Hai (Azuby)

## Table of Contents
- [Edge GPT](#edge-gpt)
- [](#)
  - [Table of Contents](#table-of-contents)
  - Introduction
  - [Setup](#setup)
    - [Requirements](#requirements)
    - [Install package](#install-package)
  - [Usage](#usage)
    - [Quick start](#quick-start)

## Introduction

  Design a WSN using local Wifi with 3 role: Node, Server, App. 
  All node have its own index and communicate with server. 
  App also communicate with server for getting data from server and control

## Setup
 
### Requirements 

- Visual Studio Code
- Platform IO (or Arduino IDE)
- NodeJS
- Xcode(Optional for run App)
- Esptouch (for SmartConfig)

### Install Package

Open terminal at folder SERVER
```
$ npm install
```
Open folder ESP, click on icon Platform on the left, open Miscellanerous, open PlatformIO Core CLI
```
$ pio run
```
Open terminal at folder APP
```
$ pod install
```

## Usage
- Step 1: Make sure your phone and PC connect same Wifi network
- Step 2: Open file `main.cpp` on folder `ESP`, upload to each ESP32 by change `NODE_ID` then upload. All node must not same `NODE_ID`.
- Step 3: Open terminal on folder `SERVER`, run `node index.js`. Server will run and listen to port 3000
- Step 4: Open `Esptouch` on your phone, select `EsptouchV2`, type `password` is your `WiFi password`,
`AES` key is `0000000000000000`, `Custom Data` is `Server URL` (example: `192.168.1.4:3000`) then confirm. 
All node will receive `WiFi name and password`, if any not receive correctly the D2 led will on forever(ERROR: Wrong WiFi information or WiFi cannot connect) 
or it will blink `1` time(ERROR: Wrong Server URL or Server Crash), success will blink `2` time.
- Step 5: Open `WSN.xcworkspace` on folder APP, click icon build on top left to run app. When app is ready, enter the `Server URL` to input place at top left.
Data will start fetch, success will draw graph



