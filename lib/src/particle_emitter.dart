part of stagexl_particle;

class ParticleEmitter extends DisplayObject implements Animatable {

  final Random _random = new Random();

  _Particle _rootParticle;
  _Particle _lastParticle;

  RenderTexture _renderTexture = new RenderTexture(1024, 32, true, Color.Transparent, 1.0);
  List<RenderTextureQuad> _renderTextureQuads = new List<RenderTextureQuad>();
  int _particleCount = 0;
  num _frameTime = 0.0;
  num _emissionTime = 0.0;

  static const int EMITTER_TYPE_GRAVITY = 0;
  static const int EMITTER_TYPE_RADIAL = 1;

  // emitter configuration
  int _emitterType = 0;
  num _locationX = 0.0;
  num _locationY = 0.0;
  num _locationXVariance = 0.0;
  num _locationYVariance = 0.0;

  // particle configuration
  int _maxNumParticles = 0;
  num _duration = 0.0;
  num _lifespan = 0.0;
  num _lifespanVariance = 0.0;
  num _startSize = 0.0;
  num _startSizeVariance = 0.0;
  num _endSize = 0.0;
  num _endSizeVariance = 0.0;
  String _shape = "circle";

  // gravity configuration
  num _gravityX = 0.0;
  num _gravityY = 0.0;
  num _speed = 0.0;
  num _speedVariance = 0.0;
  num _angle = 0.0;
  num _angleVariance = 0.0;
  num _radialAcceleration = 0.0;
  num _radialAccelerationVariance = 0.0;
  num _tangentialAcceleration = 0.0;
  num _tangentialAccelerationVariance = 0.0;

  // radial configuration
  num _minRadius = 0.0;
  num _maxRadius = 0.0;
  num _maxRadiusVariance = 0.0;
  num _rotatePerSecond = 0.0;
  num _rotatePerSecondVariance = 0.0;

  // color configuration
  String _compositeOperation;
  _ParticleColor _startColor;
  _ParticleColor _endColor;

  //-------------------------------------------------------------------------------------------------

  ParticleEmitter(Map config) {

    _rootParticle = new _Particle(this);
    _lastParticle = _rootParticle;

    _emissionTime = 0.0;
    _frameTime = 0.0;
    _particleCount = 0;

    for(int i = 0; i < 32; i++) {
      _renderTextureQuads.add(_renderTexture.quad.cut(new Rectangle(i * 32, 0, 32, 32)));
    }

    updateConfig(config);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _drawParticleTexture() {

    CanvasRenderingContext2D context = _renderTexture.canvas.context2D;
    context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    context.globalAlpha = 1.0;
    context.globalCompositeOperation = CompositeOperation.SOURCE_OVER;
    context.clearRect(0, 0, 1024, 32);

    for(int i = 0; i < 32; i++) {

      int radius = 15;
      num targetX = i * 32 + 15.5;
      num targetY = 15.5;

      num colorR = _startColor.red   + i * (_endColor.red   - _startColor.red  ) / 31;
      num colorG = _startColor.green + i * (_endColor.green - _startColor.green) / 31;
      num colorB = _startColor.blue  + i * (_endColor.blue  - _startColor.blue ) / 31;
      num colorA = _startColor.alpha + i * (_endColor.alpha - _startColor.alpha) / 31;

      if (i == 0) colorR = colorG = colorB = colorA = 1.0;

      int colorIntR = (255.0 * colorR).toInt();
      int colorIntG = (255.0 * colorG).toInt();
      int colorIntB = (255.0 * colorB).toInt();

      var gradient = context.createRadialGradient(targetX, targetY, 0, targetX, targetY, radius);
      gradient.addColorStop(0.00, "rgba($colorIntR, $colorIntG, $colorIntB, $colorA)");
      gradient.addColorStop(1.00, "rgba($colorIntR, $colorIntG, $colorIntB, 0.0)");
      context.beginPath();
      context.moveTo(targetX + radius, targetY);
      context.arc(targetX, targetY, radius, 0, PI * 2.0, false);
      context.fillStyle = gradient;
      context.fill();
    }

    _renderTexture.update();
  }

  //-------------------------------------------------------------------------------------------------

  void start([num duration]) {
    _emissionTime = _duration;

    if (duration != null && duration is num)
      _emissionTime = duration;
  }

  void stop(bool clear) {
    _emissionTime = 0.0;
    if (clear) _particleCount = 0;
  }

  void setEmitterLocation(num x, num y) {
    _locationX = _ensureNum(x);
    _locationY = _ensureNum(y);
  }

  RenderTexture get renderTexture => _renderTexture;

  int get particleCount => _particleCount;

  num get _randomVariance => _random.nextDouble() * 2.0 - 1.0;

  //-------------------------------------------------------------------------------------------------

  void updateConfig(Map config) {

    _emitterType = _ensureInt(config["emitterType"]);
    _locationX = _ensureNum(config["location"]["x"]);
    _locationY = _ensureNum(config["location"]["y"]);

    _maxNumParticles = _ensureInt(config["maxParticles"]);
    _duration = _ensureNum(config["duration"]);
    _lifespan = _ensureNum(config["lifeSpan"]);
    _lifespanVariance = _ensureNum(config["lifespanVariance"]);
    _startSize = _ensureNum(config["startSize"]);
    _startSizeVariance = _ensureNum(config["startSizeVariance"]);
    _endSize = _ensureNum(config["finishSize"]);
    _endSizeVariance = _ensureNum(config["finishSizeVariance"]);
    _shape = config["shape"];

    _locationXVariance = _ensureNum(config["locationVariance"]["x"]);
    _locationYVariance = _ensureNum(config["locationVariance"]["y"]);
    _speed = _ensureNum(config["speed"]);
    _speedVariance = _ensureNum(config["speedVariance"]);
    _angle = _ensureNum(config["angle"]) * PI / 180.0;
    _angleVariance = _ensureNum(config["angleVariance"]) * PI / 180.0;
    _gravityX = _ensureNum(config["gravity"]["x"]);
    _gravityY = _ensureNum(config["gravity"]["y"]);
    _radialAcceleration = _ensureNum(config["radialAcceleration"]);
    _radialAccelerationVariance = _ensureNum(config["radialAccelerationVariance"]);
    _tangentialAcceleration = _ensureNum(config["tangentialAcceleration"]);
    _tangentialAccelerationVariance = _ensureNum(config["tangentialAccelerationVariance"]);

    _minRadius = _ensureNum(config["minRadius"]);
    _maxRadius = _ensureNum(config["maxRadius"]);
    _maxRadiusVariance = _ensureNum(config["maxRadiusVariance"]);
    _rotatePerSecond = _ensureNum(config["rotatePerSecond"]) * PI / 180.0;
    _rotatePerSecondVariance = _ensureNum(config["rotatePerSecondVariance"]) * PI / 180.0;

    _compositeOperation = config["compositeOperation"];
    _startColor = new _ParticleColor.fromJSON(config["startColor"]);
    _endColor = new _ParticleColor.fromJSON(config["finishColor"]);

    if (_duration <= 0) _duration = double.INFINITY;
    _emissionTime = _duration;

    _drawParticleTexture();
  }

  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num passedTime) {

    var particle = _rootParticle;
    var particleCount = _particleCount;

    // advance existing particles

    for (int i = 0; i < particleCount; i++) {

      var nextParticle = particle._nextParticle as _Particle;

      if (nextParticle._advanceParticle(passedTime)) {
        particle = nextParticle;
        continue;
      }

      if (nextParticle._nextParticle != null) {
        particle._nextParticle = nextParticle._nextParticle;
        _lastParticle._nextParticle = nextParticle;
        _lastParticle = nextParticle;
        _lastParticle._nextParticle = null;
      }

      _particleCount--;
    }

    // create and advance new particles

    if (_emissionTime > 0.0) {

      num timeBetweenParticles = _lifespan / _maxNumParticles;
      _frameTime += passedTime;

      while (_frameTime > 0.0) {

        if (_particleCount < _maxNumParticles) {

          var nextParticle = particle._nextParticle;

          if (nextParticle == null) {
            nextParticle = _lastParticle = particle._nextParticle = new _Particle(this);
          }

          particle = nextParticle;
          particle._initParticle();
          particle._advanceParticle(_frameTime);
          _particleCount++;
        }

        _frameTime -= timeBetweenParticles;
      }

      _emissionTime = max(0.0, _emissionTime - passedTime);
    }

    //--------------------------------------------------------

    //return (_particleCount > 0);
    return true;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    var renderContext = renderState.renderContext;
    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var particle = _rootParticle;

    // renderState.renderQuad(_renderTextureQuads[0].renderTexture.quad);

    if (renderContext is RenderContextCanvas) {

      var context = renderContext.rawContext;
      context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.globalAlpha = alpha;
      context.globalCompositeOperation = this.compositeOperation;

      for(int i = 0; i < _particleCount; i++) {
        particle = particle._nextParticle;
        particle._renderParticleCanvas(context);
      }

    } else if (renderContext is RenderContextWebGL) {

      var renderProgram = _ParticleRenderProgram.instance;
      renderProgram.configure(renderContext, _renderTextureQuads[0], matrix);

      for(int i = 0; i < _particleCount; i++) {
        particle = particle._nextParticle;
        particle._renderParticleWegGL(renderProgram);
      }
    }
  }

}
