part of stagexl_particle;

class _ParticleColor {

  num _red = 0.0;
  num _green = 0.0;
  num _blue = 0.0;
  num _alpha = 0.0;

  _ParticleColor.fromJSON(Map json) {
    _red = min(1.0, max(0.0, _ensureNum(json["red"])));
    _green = min(1.0, max(0.0, _ensureNum(json["green"])));
    _blue = min(1.0, max(0.0, _ensureNum(json["blue"])));
    _alpha = min(1.0, max(0.0, _ensureNum(json["alpha"])));
  }
}
