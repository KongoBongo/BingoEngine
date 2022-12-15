# Bingo Engine
A Game Engine Framework used in all of my projects, including group/collaborative projects.

This repo exists for anyone interested in my framework/workflow of developing on Roblox Studio.

## Background
The Bingo Engine was originally a fork of the more sophisticated and well developed framework [Knit](https://github.com/Sleitnick/Knit). The framework was really rudimentary and immature. The most I added at the time was a standardised Network Module, *which removes the need of having remote instances floating around in your game but rather functioned with **Namespaces***.

I eventually grew it out more and more to support more of my needs, cutting down on what Knit had and really specified it to my needs. Now it's more of a Utils module and module/service loader.

After the development of the game **Project Starcraft** with my friend, AllesBoem aka [Toewi](https://www.roblox.com/users/159283026/profile) I developed the engine into more of a standardised place containing defaults and **engines** that all my games run off of, and that's what this repository aims to provide. A standardised default roblox codebase for the rest of my additions and features to derive off of.

## Usage
1) Download the zip file under ** Code > Download Zip**
2) Download the [Rojo](https://github.com/rojo-rbx/rojo/releases) binaries
3) Serve

## To Do
> - PlayerService/Controller (will contain Client and Server modules which will handle different things depending on the network running the object.)
> - Replication (allows for player states to be replicated across the server/client boundary. i.e delivery of new player state to the client when the server
changes it's state.)
> - Client Prediction with states (allow for the client to predict their own states and outcomes, whilst the server will swoop in and give the actual result).

> - Introduce a "Ping" method inside of src/ReplicatedStorage/BingoEngine/Network.
> - Introduce an automated system that filters packets and gets the standard deviation of each player's ping over a time frame.
> - Introduce a ``Workspace`` module which allows for Utilities within the workspace.
  >> - DrawLine()
  >> - ...
> - Custom Chat Module
> - SoundService and Controller Module. (SoundService will replicate sound data to the **SoundController** to process and execute on **command**.
> - Indoor vs Outdoor sounds using reverb.
> - Weather system.
> - Default Player Controller, which will consist of:
  >> - Running (with stamina)
  >> - Crouching
  >> - Proning
  >> - Fall Damage
  >> - Leaning
  
> - Damage affecting player walkspeed.
> - Custom Camera Controller which will wrap over the default camera system roblox has.  
> - VoiceChatService and Controller. (allows to set the context of the voice to allow for global voice chats without the proximity system).
> - Footstep sounds.
> - Introduce a Ragdoll engine.
> - Advanced Maths, CFrame, and Vector3 Library.
> - UserInputController Library, extra utilities for UserInputService.
> - More reliable controls for xbox and mobile.
> - Centralised Client and Server running system, updates handled in one script and debugging (allowing for predicted states and easier to find bugs).
> - Script Debug Context (a better debug console for the client, allowing for an easier time tracing back error messages, debug messages, etc).
> - Kinematics Library (support for IK, FK, and other procedural animations).
> - RejectClient (allows for a more responsive UX when the player does something, they get a response).
### License
[MIT](LICENSE) © KongoBongo
