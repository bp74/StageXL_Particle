library stagexl_particle;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show CanvasRenderingContext2D;

import 'package:stagexl/stagexl.dart';

//-------------------------------------------------------------------------------------------------
// Credits to www.gamua.com
// Particle System Extension for the Starling framework
// The original code was release under the Simplified BSD License
// http://wiki.starling-framework.org/extensions/particlesystem
//-------------------------------------------------------------------------------------------------

part 'src/particle.dart';
part 'src/particle_color.dart';
part 'src/particle_emitter.dart';
part 'src/particle_render_program.dart';

bool _ensureBool(bool value) {
  if (value is bool) {
    return value;
  } else {
    throw ArgumentError('The supplied value ($value) is not a bool.');
  }
}

int _ensureInt(int? value) {
  if (value is int) {
    return value;
  } else {
    throw ArgumentError('The supplied value ($value) is not an int.');
  }
}

num _ensureNum(num? value) {
  if (value is num) {
    return value;
  } else {
    throw ArgumentError('The supplied value ($value) is not a number.');
  }
}
