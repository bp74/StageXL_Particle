part of stagexl_particle;

class _ParticleRenderProgram extends RenderProgram {

  static final _ParticleRenderProgram instance = new _ParticleRenderProgram();

  var _vertexShaderSource = """
      precision mediump float;
      attribute vec2 aVertexPosition;
      attribute vec2 aVertexTextCoord;
      attribute vec4 aVertexColor;
      uniform mat4 uProjectionMatrix;
      uniform mat4 uGlobalMatrix;
      varying vec2 vTextCoord;
      varying vec4 vColor; 

      void main() {
        vTextCoord = aVertexTextCoord;
        vColor = aVertexColor;
        gl_Position = vec4(aVertexPosition, 1.0, 1.0) * uGlobalMatrix * uProjectionMatrix;
      }
      """;

  var _fragmentShaderSource = """
      precision mediump float;
      uniform sampler2D uSampler;
      varying vec2 vTextCoord;
      varying vec4 vColor;

      void main() {
        vec4 color = texture2D(uSampler, vTextCoord);
        gl_FragColor = vec4(color.rgb * vColor.rgb * vColor.a, color.a * vColor.a);
        //gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0); 
      }
      """;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertextColor:     Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  static const int _maxQuadCount = 1024;

  gl.RenderingContext _renderingContext;
  gl.Program _program;
  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;

  StreamSubscription _contextRestoredSubscription;
  Int16List _indexList = new Int16List(_maxQuadCount * 6);
  Float32List _vertexList = new Float32List(_maxQuadCount * 4 * 8);

  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uGlobalMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexColorLocation = 0;
  int _quadCount = 0;

  Matrix3D _globalMatrix = new Matrix3D.fromIdentity();

  _ParticleRenderProgram() {
    for(int i = 0, j = 0; i <= _indexList.length - 6; i += 6, j +=4 ) {
      _indexList[i + 0] = j + 0;
      _indexList[i + 1] = j + 1;
      _indexList[i + 2] = j + 2;
      _indexList[i + 3] = j + 0;
      _indexList[i + 4] = j + 2;
      _indexList[i + 5] = j + 3;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void set projectionMatrix(Matrix3D matrix) {
    _renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  void set globalMatrix(Matrix globalMatrix) {
    _globalMatrix.copyFromMatrix2D(globalMatrix);
    _renderingContext.uniformMatrix4fv(_uGlobalMatrixLocation, false, _globalMatrix.data);
  }

  void set renderTextureQuad(RenderTextureQuad renderTextureQuad) {

    List<num> uvList = renderTextureQuad.uvList;

    for(int index = 0; index <= _vertexList.length - 32; index += 32) {
      _vertexList[index + 02] = uvList[0];
      _vertexList[index + 03] = uvList[1];
      _vertexList[index + 10] = uvList[2];
      _vertexList[index + 11] = uvList[3];
      _vertexList[index + 18] = uvList[4];
      _vertexList[index + 19] = uvList[5];
      _vertexList[index + 26] = uvList[6];
      _vertexList[index + 27] = uvList[7];
    }
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (_program == null) {

      if (_renderingContext == null) {
        _renderingContext = renderContext.rawContext;
        _contextRestoredSubscription = renderContext.onContextRestored.listen(_onContextRestored);
      }

      _program = createProgram(_renderingContext, _vertexShaderSource, _fragmentShaderSource);

      _aVertexPositionLocation = _renderingContext.getAttribLocation(_program, "aVertexPosition");
      _aVertexTextCoordLocation = _renderingContext.getAttribLocation(_program, "aVertexTextCoord");
      _aVertexColorLocation = _renderingContext.getAttribLocation(_program, "aVertexColor");

      _uProjectionMatrixLocation = _renderingContext.getUniformLocation(_program, "uProjectionMatrix");
      _uGlobalMatrixLocation = _renderingContext.getUniformLocation(_program, "uGlobalMatrix");
      _uSamplerLocation = _renderingContext.getUniformLocation(_program, "uSampler");

      _renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      _renderingContext.enableVertexAttribArray(_aVertexTextCoordLocation);
      _renderingContext.enableVertexAttribArray(_aVertexColorLocation);

      _indexBuffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      _renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);

      _vertexBuffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    _renderingContext.useProgram(_program);
    _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 32, 0);
    _renderingContext.vertexAttribPointer(_aVertexTextCoordLocation, 2, gl.FLOAT, false, 32, 8);
    _renderingContext.vertexAttribPointer(_aVertexColorLocation, 4, gl.FLOAT, false, 32, 16);
    _renderingContext.uniform1i(_uSamplerLocation, 0);
  }

  //-----------------------------------------------------------------------------------------------

  void renderParticle(num x, num y, num size, num r, num g, num b, num a) {

    int index = _quadCount * 32;
    if (index > _vertexList.length - 32) return; // dart2js_hint

    var left = x - size / 2;
    var top = y - size / 2;
    var right = x + size / 2;
    var bottom = y + size / 2;

    // vertex 1
    _vertexList[index + 00] = left;
    _vertexList[index + 01] = top;
    _vertexList[index + 04] = r;
    _vertexList[index + 05] = g;
    _vertexList[index + 06] = b;
    _vertexList[index + 07] = a;

    // vertex 2
    _vertexList[index + 08] = right;
    _vertexList[index + 09] = top;
    _vertexList[index + 12] = r;
    _vertexList[index + 13] = g;
    _vertexList[index + 14] = b;
    _vertexList[index + 15] = a;

    // vertex 3
    _vertexList[index + 16] = right;
    _vertexList[index + 17] = bottom;
    _vertexList[index + 20] = r;
    _vertexList[index + 21] = g;
    _vertexList[index + 22] = b;
    _vertexList[index + 23] = a;

    // vertex 4
    _vertexList[index + 24] = left;
    _vertexList[index + 25] = bottom;
    _vertexList[index + 28] = r;
    _vertexList[index + 29] = g;
    _vertexList[index + 30] = b;
    _vertexList[index + 31] = a;

    _quadCount += 1;

    if (_quadCount == _maxQuadCount) flush();
  }

  //-----------------------------------------------------------------------------------------------

  void flush() {

    Float32List vertexUpdate = _vertexList;

    if (_quadCount == 0) {
      return;
    } else if (_quadCount < _maxQuadCount) {
      vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 8);
    }

    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    _renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
    _quadCount = 0;
  }

  //-----------------------------------------------------------------------------------------------

  _onContextRestored(RenderContextEvent e) {
    _program = null;
  }
}