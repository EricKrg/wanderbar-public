
#  Wanderbar

Wanderbar is travel diary app. Which aims to provide an easy way to create a trip or travel diary, which could be shared with others. Wanderbar uses geotags for every log, because everything we do has a spatial context.

It utilizes the Flutter-Appframework to build native apps for IOS and Andriod.




## Authors

- [@mrezkys](https://github.com/mrezkys) I forked the mrezkys Hungry-App [hungry](https://github.com/mrezkys/hungry) as a starting Point for the Wanderbar-App


## Application overview

.      |  . |  . 
:-------------------------:|:-------------------------:|:-------------------------:
<img src="assets/wanderbar_screens/0.png " alt="drawing" width="200"/>  | <img src="assets/wanderbar_screens/1.png " alt="drawing" width="200"/> | <img src="assets/wanderbar_screens/2.png " alt="drawing" width="200"/>
<img src="assets/wanderbar_screens/3.png " alt="drawing" width="200"/>  | <img src="assets/wanderbar_screens/4.png " alt="drawing" width="200"/> | <img src="assets/wanderbar_screens/5.png " alt="drawing" width="200"/>
<center>
<img src="assets/wanderbar_screens/6.png " alt="drawing" width="200"/></center>
  
A Quicklog is the main Locking component of Wanderbar, here you can create Text-, Photo-, Audio-, Weather-, and Geologs. A Quicklog can be linked to multiple Trips, but can also exist without a trip.
Every Logentry is geotaged and can be displayed on the map.

## Features

- Creation of Trips and Quicklogs
- Adding Media as Log entry: Photo, Text, Audio, High precision Geologs, Weatherlog
- Near realtime Sync.
- Shared trips and shared editing of Trips and Logs
- Geovisualization of Trips and Logs
- Trip and Log search
- User Profile customization

- Crossplattform builds for Andriod and IOS
- Offline use and editing

### Planned Features
- Calendar overview
- Video Logs
- improved search
- background Geologs, i.e. in order to record a hike or bike trip
## Tech Stack

**App-Framework:** Flutter

**BaaS:** Firebase Firestore, Firebase Auth, Firebase Cloudstorage
