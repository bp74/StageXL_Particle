part of stagexl_particle;

class _ParticleRenderProgram extends RenderProgram {

  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;

  int _quadCount = 0;
  final Matrix3D _globalMatrix = new Matrix3D.fromIdentity();

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertextColor:     Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  String get vertexShaderSource => """

    precision mediump float;
    uniform mat4 uProjectionMatrix;
    uniform mat4 uGlobalMatrix;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute vec4 aVertexColor;

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
    }
    """;

  //---------------------------------------------------------------------------

  void set globalMatrix(Matrix globalMatrix) {
    _globalMatrix.copyFrom2D(globalMatrix);
    renderingContext.uniformMatrix4fv(uniforms["uGlobalMatrix"], false, _globalMatrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);
    super.renderingContext.uniform1i(uniforms["uSampler"], 0);

    _renderBufferIndex = renderContext.renderBufferIndexQuads;
    _renderBufferIndex.activate(renderContext);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 32, 0);
    _renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 32, 8);
    _renderBufferVertex.bindAttribute(attributes["aVertexColor"], 4, 32, 16);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      _renderBufferVertex.update(0, _quadCount * 4 * 8);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //---------------------------------------------------------------------------

  void set renderTextureQuad(RenderTextureQuad renderTextureQuad) {

    List<num> uvList = renderTextureQuad.uvList;

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;

    for(int index = 0; index <= vxData.length - 32; index += 32) {
      vxData[index + 02] = uvList[0];
      vxData[index + 03] = uvList[1];
      vxData[index + 10] = uvList[2];
      vxData[index + 11] = uvList[3];
      vxData[index + 18] = uvList[4];
      vxData[index + 19] = uvList[5];
      vxData[index + 26] = uvList[6];
      vxData[index + 27] = uvList[7];
    }
  }

  //---------------------------------------------------------------------------

  void renderParticle(num x, num y, num size, num r, num g, num b, num a) {

    var left = x - size / 2;
    var top = y - size / 2;
    var right = x + size / 2;
    var bottom = y + size / 2;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = _renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < _quadCount * 6 + 6) flush();

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < _quadCount * 32 + 32) flush();

    int index = _quadCount * 32;
    if (index > vxData.length - 32) return; // dart2js_hint

    // vertex 1
    vxData[index + 00] = left;
    vxData[index + 01] = top;
    vxData[index + 04] = r;
    vxData[index + 05] = g;
    vxData[index + 06] = b;
    vxData[index + 07] = a;

    // vertex 2
    vxData[index + 08] = right;
    vxData[index + 09] = top;
    vxData[index + 12] = r;
    vxData[index + 13] = g;
    vxData[index + 14] = b;
    vxData[index + 15] = a;

    // vertex 3
    vxData[index + 16] = right;
    vxData[index + 17] = bottom;
    vxData[index + 20] = r;
    vxData[index + 21] = g;
    vxData[index + 22] = b;
    vxData[index + 23] = a;

    // vertex 4
    vxData[index + 24] = left;
    vxData[index + 25] = bottom;
    vxData[index + 28] = r;
    vxData[index + 29] = g;
    vxData[index + 30] = b;
    vxData[index + 31] = a;

    _quadCount += 1;
  }
}
