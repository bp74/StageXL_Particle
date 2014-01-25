part of stagexl_particle;

class _Particle {

  final ParticleEmitter _particleEmitter;

  num _currentTime = 0.0;
  num _totalTime = 0.0;
  num _x = 0.0;
  num _y = 0.0;
  num _size = 0.0;
  num _sizeDelta = 0.0;
  num _rotation = 0.0;
  num _rotationDelta = 0.0;
  num _startX = 0.0;
  num _startY = 0.0;
  num _velocityX = 0.0;
  num _velocityY = 0.0;
  num _radialAcceleration = 0.0;
  num _tangentialAcceleration = 0.0;
  num _emitRadius = 0.0;
  num _emitRadiusDelta = 0.0;
  num _emitRotation = 0.0;
  num _emitRotationDelta = 0.0;

  _Particle _nextParticle;

  _Particle(ParticleEmitter particleEmitter) : _particleEmitter = particleEmitter;

  //-----------------------------------------------------------------------------------------------

  _initParticle() {

    var pe = _particleEmitter;
    var totalTime = pe._lifespan + pe._lifespanVariance * pe._randomVariance;
    if (totalTime < 0.01) totalTime = 0.01;

    _currentTime = 0.0;
    _totalTime = totalTime;

    _x = pe._locationX + pe._locationXVariance * pe._randomVariance;
    _y = pe._locationY + pe._locationYVariance * pe._randomVariance;
    _startX = pe._locationX;
    _startY = pe._locationY;

    num angle = pe._angle + pe._angleVariance * pe._randomVariance;
    num velocity = pe._speed + pe._speedVariance * pe._randomVariance;
    _velocityX = (velocity * cos(angle));
    _velocityY = (velocity * sin(angle));

    _emitRadius = pe._maxRadius + pe._maxRadiusVariance * pe._randomVariance;
    _emitRadiusDelta = pe._maxRadius / _totalTime;
    _emitRotation = pe._angle + pe._angleVariance * pe._randomVariance;
    _emitRotationDelta = pe._rotatePerSecond + pe._rotatePerSecondVariance * pe._randomVariance;
    _radialAcceleration = pe._radialAcceleration + pe._radialAccelerationVariance * pe._randomVariance;
    _tangentialAcceleration = pe._tangentialAcceleration + pe._tangentialAccelerationVariance * pe._randomVariance;

    num size1 = pe._startSize + pe._startSizeVariance * pe._randomVariance;
    num size2 = pe._endSize + pe._endSizeVariance * pe._randomVariance;
    if (size1 < 0.1) size1 = 0.1;
    if (size2 < 0.1) size2 = 0.1;
    _size = size1;
    _sizeDelta = (size2 - size1) / _totalTime;

    /*
    ParticleColor color = particle.color;
    ParticleColor colorDelta = particle.colorDelta;

    color.red   = startColor.red;
    color.green = startColor.green;
    color.blue  = startColor.blue;
    color.alpha = startColor.alpha;

    colorDelta.red   = (endColor.red   - startColor.red)   / particle.totalTime;
    colorDelta.green = (endColor.green - startColor.green) / particle.totalTime;
    colorDelta.blue  = (endColor.blue  - startColor.blue)  / particle.totalTime;
    colorDelta.alpha = (endColor.alpha - startColor.alpha) / particle.totalTime;
    */
  }

  //-----------------------------------------------------------------------------------------------

  bool _advanceParticle(num passedTime) {

    var pe = _particleEmitter;
    var restTime = _totalTime - _currentTime;
    if (restTime <= 0.0) return false;
    if (restTime <= passedTime) passedTime = restTime;

    _currentTime += passedTime;

    if (pe._emitterType == ParticleEmitter.EMITTER_TYPE_RADIAL) {

      _emitRotation += _emitRotationDelta * passedTime;
      _emitRadius   -= _emitRadiusDelta   * passedTime;
      _x = pe._locationX - cos(_emitRotation) * _emitRadius;
      _y = pe._locationY - sin(_emitRotation) * _emitRadius;

      if (_emitRadius < pe._minRadius) {
        _currentTime = _totalTime;
      }

    } else {

      num distanceX = _x - _startX;
      num distanceY = _y - _startY;
      num distanceScalar = sqrt(distanceX * distanceX + distanceY * distanceY);
      if (distanceScalar < 0.01) distanceScalar = 0.01;
      distanceX = distanceX / distanceScalar;
      distanceY = distanceY / distanceScalar;

      var gravityX = pe._gravityX;
      var gravityY = pe._gravityY;

      _velocityX += passedTime * (gravityX + distanceX * _radialAcceleration - distanceY * _tangentialAcceleration);
      _velocityY += passedTime * (gravityY + distanceY * _radialAcceleration + distanceX * _tangentialAcceleration);
      _x += _velocityX * passedTime;
      _y += _velocityY * passedTime;
    }

    _size += _sizeDelta * passedTime;

    /*
    ParticleColor color = particle.color;
    ParticleColor colorDelta = particle.colorDelta;
    color.red   += colorDelta.red   * passedTime;
    color.green += colorDelta.green * passedTime;
    color.blue  += colorDelta.blue  * passedTime;
    color.alpha += colorDelta.alpha * passedTime;
    */

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  static Matrix _tmpMatrix = new Matrix.fromIdentity();

  _renderParticle(RenderState renderState) {

    // TODO: We can optimize this with a custom WebGL render program.
    // This render program will also support tinted textures!!!

    var targetX = _x - _size / 2.0;
    var targetY = _y - _size / 2.0;

    var index = _currentTime * 32 ~/ _totalTime;
    if (index < 0) index = 0;
    if (index > 31) index = 31;

    var renderTextureQuad = _particleEmitter._renderTextureQuads[index];
    var matrix = renderState.globalMatrix;

    num a = matrix.a;
    num b = matrix.b;
    num c = matrix.c;
    num d = matrix.d;
    num tx = targetX * a + targetY * c + matrix.tx;
    num ty = targetX * b + targetY * d + matrix.ty;

    _tmpMatrix.setTo(a, b, c, d, tx, ty);
    renderState.renderContext.renderQuad(renderTextureQuad, _tmpMatrix, 1.0);
  }
}
