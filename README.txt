Arduino Distributed Sensors
===========================


Instructions:
-------------

### Setup can be broken down into a few steps:

1. Set up router
2. Connect the Computer to router
3. Start the ProcessingServer
4. Set up Arduinos
5. Connect Arduinos to router
6. (Troubleshooting) Resets

Detailed Instructions:
----------------------

### 1. Set up the router.
	Setting up the router is as simple as plugging it in. It should already be preconfigured to work. Even if it is reset, and all settings are lost (or, if you use a completely different router entirely) the steps will not change; the only thing that changes is the IP addresses.

	(For the NETGEAR router, do not attach the computer to the Yellow port.)

### 2. Connect the Computer to the router.
	Once the router is plugged in, and turned on, simply connect the computer to the router, either by plugging it in with an Ethernet cable, or by connecting to the router by connecting to the wireless port.

### 3. Start the ProcessingServer
	On the computer attached to the router, start the ProcessingServer processing code. It can be found inside the ProcessingServer folder, and can be run by double clicking on it (as long as Processing is installed in the host computer.)

	Run the ProcessingServer

	The important thing to do here is to take a note of the `IP Address`, written in the top right hand corner of the ProcessingServer. We will use this for our next step.
	The format of the `IP Address` will be `192.168.X.X`, where the `X`s are numbers up to 255.

### 4. Set up Arduinos.
	In order for the Arduinos to connect to the server, they must know the `IP Address` of the server. Open the ArduinoDistributedSensor, and modify the following files.

    // Enter the IP address of the server you're connecting to:
    // These two lines likely need to be changed.
    IPAddress server(192,168,X,X); 
    static int id = Y;

	The lines that need to be set are the `IPAddress server(X,X,X,X)` and `int id = Y;` lines. 
	Replace the `IPAddress server(X,X,X,X)` with the IP address copied in step 3.
	Replace the `Y` with a number that is unique to the Arduinos you want to connect. (The two Arduinos should NOT have the same number for Y).

	Once these two lines have been changed, upload the code to their respective Arduinos.

	The Arduinos will read data from the Analog Pin 0, and will send that information to the server. The server is the one that manipulates the analog data.

	Before Uploading to the Arduino, be sure to turn off the ProcessingServer, and turn it back on after the Upoading is completed. Leaving it on will cause problems with the ARduino compilation.

### 5. Connect Arduinos to router
	Once the Arduinos have each been reprogrammed with a unique id (the `Y` in step 4), they can be attached to the router using Ethernet cables.
	(For the NETGEAR router, do not attach the Arduinos to the Yellow port.)
	The light on the Ethernet Shield, next to the port (labeled 100M), should be lit.
		The TX light on the Ethernet Shield should be lighting as well.

	At this point, the ProcessingServer should have gotten the signal from the Arduinos, and should be already displaying their analog data.

### 6. (Troubleshooting) Resets
	If the ProcessingServer is NOT displaying data, then there may have been a bad connection. Check if the Ethernet Shield's TX light is on. If it is off, this usually indicates a bad connectiong.
	Simply press the reset button, on the Arduinos, until they have attached themselves properly to the ProcessingServer.

	If the ProcessingServer is displaying an attached Arduino, but none of the Arduino's TX lights is on, then the ProcessingServer has a ghost connection. Simply restart the Processing Server and reset the Arduinos to try again.


Serial Plotter
==============

To run the Serial Plotter program:

1. Load the Analog0toSerial sketch onto the Arduino
2. Connect any analog data you want to graph to the Analog 0 Pin of the Arduino
3. Start the ProcessingSerialAnalogGrapher.

The Grapher will automatically detect the most recently connect USB device, and will draw whatever signal it gets.

