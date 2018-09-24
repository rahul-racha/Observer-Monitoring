# Observer - iOS application

<img src="./resources/initial.PNG" width=500/>  

## Introduction
Behavioral symptoms of dementia classification is based on the Cohen-Mansfield Agitation Inventory, a 29-item scale 
to systematically assess agitation.
- Physical Agitation
  - Biting, hitting, kicking, pushing and scratching 
- Physical Non-Agitation
  - disrobing, hording, hiding things and improper eaating
- Verbal Agitation
  - cursing, screaming and verbal sexual advances
- Verbal Non-Agitation
  - repeated sentences, noise and attention seeking
  
Nurses and other health care professionals are burdened by the manual document entry and preserving while assessing the 
patients. This application reduces their effort by a large extent as all the behavioral actions are recorded electronically on an iPad
and the data is sent to the server which processes the data and saves to the database.

All the behaviors can be recorded as two types:
- Single events: Occurs only for that moment in time.
- Continuous events: Occurs for a period of time.

## Features
* [Add new patients as well as switch between multiple patients to record their behaviors.](#add-or-select-patient)
* [Record single events by a single tap on any of the cells representing the behavior.](#record-behaviors)
* [Record continuous events by a double tap on any of the cells representing the behavior.](#record-behaviors)
* [Multiple behaviors can be recorded for continuous events.](#record-behaviors)
* [Either stop the continuous event for one behavior or stop for multiple behaviors.](#end-events)
* Patient's location is updatated automatically based on the beacons assigned to different rooms in the house. You can also manually enter the location from the picker.

## Screenshots
### Add or select patient
|  Add                                                       |                     Select                                 |
|------------------------------------------------------------|------------------------------------------------------------|
| <img src="./resources/add-patient.PNG" width="300"/>       | <img src="./resources/switch-patients.PNG" width="300"/>   |

### Record Behaviors

| After Cell Selection                               |  Single Continuous                                       | Multiple Continous                                              |
|----------------------------------------------------|----------------------------------------------------------|--------------------------------------------------------------------|
|<img src="./resources/after-click.PNG" width="300"/>|<img src="./resources/continous-single.PNG" width="300"/>|<img src="./resources/continuous-multiple.PNG" width="300"/>| 

### End Events
- One selected continous behavior can be ended by tapping on the cell. 
- All the continous behaviors can be ended by clicking on the red colored close button below the timestamp.

|  End One Behavior                                      |                     End All Behaviors                      |
|-----------------------------------------------------------|------------------------------------------------------------|
| <img src="./resources/end-single.PNG" width="300"/>       | <img src="./resources/ended-result.PNG" width="300"/>        |


## Requirements
* Swift 3
* Compatible with iPads only.
* iOS 9

The app is available in the App Store. 
Clink on the [itunes link](https://itunes.apple.com/us/app/observer-monitoring/id1271245223?mt=8)
