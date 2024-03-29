# Getting Started
See the license agreement for the code.  My one additional rule is "no laughing."  You will see lots of remnants from where I was building my first "Hello World" iOS app, from which this evolved.  Heck, it's still called "MFBSample" because I didn't originally intend for it to become the actual codebase...it just kinda grew.

Anyhow...
## 1. Create an ApiKeys file and HostName file
You'll need to create an "ApiKeyS.h" file with the following structure:
~~~~
#ifndef ApiKeys_h
#define ApiKeys_h

#define _szKeyAppToken @"[api key for web service goes here]"

#endif /* ApiKeys_h */
~~~~
The actual value for the web service key is the token that you use to identify this app as being authorized to make web service calls.

You'll also need to create a file called "HostName.h", which specifies the domain name (see below for more information) of the server against which you will run.  It also defines the appID used in the iTunes store.

The structure of this file is this:
~~~~
#ifndef HostName_h
#define HostName_h

#ifdef DEBUG
#define MFBHOSTNAME @"[your debug server name - e.g., debug.myflightbook.com]"
#else
#define MFBHOSTNAME @"[the production server name - typically myflightbook.com]"
#endif

#define _appStoreID xyz

#endif /* HostName_h */
~~~~

## 2 Debugging
Most everything in the project includes MFBAppDelegate.h.  This defines "MFBHOSTNAME", which is the DNS name of the web service.  In retail, this is MyFlightbook.com, but for debugging you may wish to point to a private test server.  

There is a #ifdef DEBUG surrounding an alternative DNS name; set this to whatever test environment you are using.  Note that the structure must still be https://{MFBHOSTNAME}/logbook/{rest of URL}.

I *STRONGLY* recommend creating an additional scheme to test retail vs. debug mode.  There are a few differences in functionality between the two modes:
* The aforementioend MFBHOSTNAME determines which server you will hit.  PLEASE DO NOT USE THE LIVE SITE if you will be changing any data.  I can point you to a test server.  
* Most significant functional difference: if DEBUG is defined, starting the engine will simulate a series of GPS events.
* Some logging only occurs when DEBUG is allowed
* You can only use HTTP with a 192.* address (i.e., local); otherwise, must be HTTPS

Note that you can tell which server you are using by going to the Profile tab, tapping "About MyFlightbook", and then scrolling to the bottom; it will show you the following information:
[MFBHostname] [Takeoff Speed] [Landing Speed] [Version]
E.g., "MyFlightbook.com 70 55 3.0.1" means that it is hitting the live site, using 70kts as a takeoff speed and 55 as a landing speed, and it is version 3.0.1 of the app.

The main difference between DEBUG and retail (i.e., not DEBUG) is what happens when you tap "engine start" in the new flight screen.  In a DEBUG build, this will feed to the app simulated GPS data from the
file "GPSSamples.csv".  This is useful for testing autodetection and such in the debugger. 

## 3 Using SOAP
MyFlightbook uses SOAP (remember my rule - no laughing!) to make it's web service calls.  You can find the current WSDL [here](http://myflightbook.com/logbook/public/webservice.asmx?WSDL).  

All of the code to consume the webservice is autogenerated using a tool called WSDLToObjC.  It's a MacOS app that consumes a .wsdl file and spits out a bunch of objective-c files upon which the rest of the code depends.  WSDLToObjC was originally an open source project of its own but became orphaned.  I have resurrected it [here](https://github.com/ericberman/WSDLtoObjC).

I have preserved the original MIT license for it.

All of the output files from this - particularly MFBWebServiceSvc.h and MFBWebServiceSvc.m - should be placed into the WebServiceCode folder

