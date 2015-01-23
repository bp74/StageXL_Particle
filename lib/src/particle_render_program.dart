part of stagexl_particle;

class _ParticleRenderProgram extends RenderProgram {

  static final _ParticleRenderProgram instance = new _ParticleRenderProgram();

  String get vertexShaderSource => """
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

  String get fragmentShaderSource => """
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

  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;
  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uGlobalMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexColorLocation = 0;
  int _quadCount = 0;

  final Matrix3D _globalMatrix = new Matrix3D.fromIdentity();
  final Int16List _indexList = new Int16List(_maxQuadCount * 6);
  final Float32List _vertexList = new Float32List(_maxQuadCount * 4 * 8);

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

  void set globalMatrix(Matrix globalMatrix) {
    _globalMatrix.copyFromMatrix2D(globalMatrix);
    renderingContext.uniformMatrix4fv(_uGlobalMatrixLocation, false, _globalMatrix.data);
  }

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _indexBuffer = renderingContext.createBuffer();
      _vertexBuffer = renderingContext.createBuffer();
      _aVertexPositionLocation = attributeLocations["aVertexPosition"];
      _aVertexTextCoordLocation = attributeLocations["aVertexTextCoord"];
      _aVertexColorLocation = attributeLocations["aVertexColor"];
      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uGlobalMatrixLocation = uniformLocations["uGlobalMatrix"];
      _uSamplerLocation = uniformLocations["uSampler"];

      renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      renderingContext.enableVertexAttribArray(_aVertexTextCoordLocation);
      renderingContext.enableVertexAttribArray(_aVertexColorLocation);
      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 32, 0);
    renderingContext.vertexAttribPointer(_aVertexTextCoordLocation, 2, gl.FLOAT, false, 32, 8);
    renderingContext.vertexAttribPointer(_aVertexColorLocation, 4, gl.FLOAT, false, 32, 16);
    renderingContext.uniform1i(_uSamplerLocation, 0);
  }

  @override
  void flush() {

    if (_quadCount == 0) return;
    var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 8);

    renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);

    _quadCount = 0;
  }

  //-----------------------------------------------------------------------------------------------

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

}