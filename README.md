The StageXL Particle library is an extension to the StageXL Library to show particle effects. You can use particle effects to simulate fire, smoke, explosions or similar things. Often those effects will make your game visually more appealing.

*NOTE:* as of version 1.0.0, `StageXL_Particle` requires a Dart 2.12 SDK and is null-safe.

## Particle Emitter

The particle emitter is a DisplayObject you can add to the display list. It is also the origin where all particles are emitted. Use the particle designer on the StageXL homepage to configure all the parameters necessary to get a great looking particle emitter.    

<http://www.stagexl.org/runtimes/particle_emitter.html>

## StageXL

The StageXL library is intended for Flash developers who want to migrate their projects as well as their skills to HTML5. Therefore the library provides the familiar Flash API built on open web standards. 

* StageXL homepage: <http://www.stagexl.org>
* StageXL on GitHub: <https://github.com/bp74/StageXL>

## How To

The StageXL Particle repository on GitHub contains an example how to use the Particle Emitter and how to add it to the Stage. Start with the Particle Designer to configure the particle effect as desired. Then copy the generated JSON string to your Dart project and simply create the ParticleEmitter as shown in the example. Don't forget to add the ParticleEmitter to the Juggler for the animation. 

<https://github.com/bp74/StageXL_Particle/blob/master/example/example.dart>
