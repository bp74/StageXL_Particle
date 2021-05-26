part of stagexl_particle;

class _ParticleColor {
  num red = 0.0;
  num green = 0.0;
  num blue = 0.0;
  num alpha = 0.0;

  _ParticleColor.fromJSON(Map json) {
    red = min(1.0, max(0.0, _ensureNum(json['red'])));
    green = min(1.0, max(0.0, _ensureNum(json['green'])));
    blue = min(1.0, max(0.0, _ensureNum(json['blue'])));
    alpha = min(1.0, max(0.0, _ensureNum(json['alpha'])));
  }
}
