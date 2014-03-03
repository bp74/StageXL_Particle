library stagexl_particle;

import 'dart:async';
import 'dart:math' hide Point, Rectangle;
import 'dart:html' show CanvasElement, CanvasRenderingContext2D;
import 'dart:web_gl' as gl;
import 'dart:typed_data';

import 'package:stagexl/stagexl.dart';

//-------------------------------------------------------------------------------------------------
// Credits to www.gamua.com
// Particle System Extension for the Starling framework
// The original code was release under the Simplified BSD License
// http://wiki.starling-framework.org/extensions/particlesystem
//-------------------------------------------------------------------------------------------------

part 'src/particle_temp.dart';
part 'src/particle_color.dart';
part 'src/particle_emitter.dart';
part 'src/particle_render_program.dart';



bool _ensureBool(bool value) {
  if (value is bool) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a bool.");
  }
}

int _ensureInt(int value) {
  if (value is int) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not an int.");
  }
}

num _ensureNum(num value) {
  if (value is num) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a number.");
  }
}
