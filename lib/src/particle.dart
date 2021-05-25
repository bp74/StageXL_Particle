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
  num _colorR = 0.0;
  num _colorG = 0.0;
  num _colorB = 0.0;
  num _colorA = 0.0;
  num _colorDeltaR = 0.0;
  num _colorDeltaG = 0.0;
  num _colorDeltaB = 0.0;
  num _colorDeltaA = 0.0;

  _Particle? _nextParticle;

  _Particle(ParticleEmitter particleEmitter)
      : _particleEmitter = particleEmitter;

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
    _emitRotationDelta =
        pe._rotatePerSecond + pe._rotatePerSecondVariance * pe._randomVariance;
    _radialAcceleration = pe._radialAcceleration +
        pe._radialAccelerationVariance * pe._randomVariance;
    _tangentialAcceleration = pe._tangentialAcceleration +
        pe._tangentialAccelerationVariance * pe._randomVariance;

    num size1 = pe._startSize + pe._startSizeVariance * pe._randomVariance;
    num size2 = pe._endSize + pe._endSizeVariance * pe._randomVariance;
    if (size1 < 0.1) size1 = 0.1;
    if (size2 < 0.1) size2 = 0.1;
    _size = size1;
    _sizeDelta = (size2 - size1) / _totalTime;

    _colorR = pe._startColor.red;
    _colorG = pe._startColor.green;
    _colorB = pe._startColor.blue;
    _colorA = pe._startColor.alpha;
    _colorDeltaR = (pe._endColor.red - _colorR) / _totalTime;
    _colorDeltaG = (pe._endColor.green - _colorG) / _totalTime;
    _colorDeltaB = (pe._endColor.blue - _colorB) / _totalTime;
    _colorDeltaA = (pe._endColor.alpha - _colorA) / _totalTime;
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
      _emitRadius -= _emitRadiusDelta * passedTime;
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

      _velocityX += passedTime *
          (gravityX +
              distanceX * _radialAcceleration -
              distanceY * _tangentialAcceleration);
      _velocityY += passedTime *
          (gravityY +
              distanceY * _radialAcceleration +
              distanceX * _tangentialAcceleration);
      _x += _velocityX * passedTime;
      _y += _velocityY * passedTime;
    }

    _size += _sizeDelta * passedTime;

    _colorR += _colorDeltaR * passedTime;
    _colorG += _colorDeltaG * passedTime;
    _colorB += _colorDeltaB * passedTime;
    _colorA += _colorDeltaA * passedTime;

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  _renderParticleCanvas(CanvasRenderingContext2D context) {
    var index = 1 + _currentTime * 31 ~/ _totalTime;
    if (index < 1) index = 1;
    if (index > 31) index = 31;

    RenderTextureQuad renderTextureQuad =
        _particleEmitter._renderTextureQuads[index];
    var source = renderTextureQuad.renderTexture.canvas;
    Rectangle<int> sourceRectangle = renderTextureQuad.sourceRectangle;
    num sourceX = sourceRectangle.left;
    num sourceY = sourceRectangle.top;
    num sourceWidth = sourceRectangle.width;
    num sourceHeight = sourceRectangle.height;
    num destinationX = _x - _size / 2.0;
    num destinationY = _y - _size / 2.0;
    num destinationWidth = _size;
    num destinationHeight = _size;

    context.drawImageScaledFromSource(
        source,
        sourceX,
        sourceY,
        sourceWidth,
        sourceHeight,
        destinationX,
        destinationY,
        destinationWidth,
        destinationHeight);
  }

  _renderParticleWegGL(_ParticleRenderProgram renderProgram) {
    renderProgram.renderParticle(_particleEmitter._renderTextureQuads[0], _x,
        _y, _size, _colorR, _colorG, _colorB, _colorA);
  }
}
