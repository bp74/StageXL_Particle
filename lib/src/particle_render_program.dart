part of stagexl_particle;

class _ParticleRenderProgram extends RenderProgram {

  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertextColor:     Float32(r), Float32(g), Float32(b), Float32(a)

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

  final Matrix3D _globalMatrix = new Matrix3D.fromIdentity();

  //---------------------------------------------------------------------------

  void set globalMatrix(Matrix globalMatrix) {
    _globalMatrix.copyFrom2D(globalMatrix);
    renderingContext.uniformMatrix4fv(uniforms["uGlobalMatrix"], false, _globalMatrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    renderingContext.uniform1i(uniforms["uSampler"], 0);

    renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 32, 0);
    renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 32, 8);
    renderBufferVertex.bindAttribute(attributes["aVertexColor"], 4, 32, 16);
  }

  //---------------------------------------------------------------------------

  void renderParticle(
      RenderTextureQuad renderTextureQuad,
      num x, num y, num size, num r, num g, num b, num a) {

    var left = x - size / 2;
    var top = y - size / 2;
    var right = x + size / 2;
    var bottom = y + size / 2;

    var vxList = renderTextureQuad.vxList;
    var ixListCount = 6;
    var vxListCount = 4;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData.length < ixPosition + ixListCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData.length < vxPosition + vxListCount * 8) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxOffset = renderBufferVertex.count;

    if (ixIndex > ixData.length - 6) return;
    ixData[ixIndex + 0] = vxOffset + 0;
    ixData[ixIndex + 1] = vxOffset + 1;
    ixData[ixIndex + 2] = vxOffset + 2;
    ixData[ixIndex + 3] = vxOffset + 0;
    ixData[ixIndex + 4] = vxOffset + 2;
    ixData[ixIndex + 5] = vxOffset + 3;

    renderBufferIndex.position += ixListCount;
    renderBufferIndex.count += ixListCount;

    // copy vertex list

    var vxIndex = renderBufferVertex.position;
    if (vxIndex > vxData.length - 32) return;

    vxData[vxIndex + 00] = left;
    vxData[vxIndex + 01] = top;
    vxData[vxIndex + 02] = vxList[02];
    vxData[vxIndex + 03] = vxList[03];
    vxData[vxIndex + 04] = r;
    vxData[vxIndex + 05] = g;
    vxData[vxIndex + 06] = b;
    vxData[vxIndex + 07] = a;
    vxData[vxIndex + 08] = right;
    vxData[vxIndex + 09] = top;
    vxData[vxIndex + 10] = vxList[06];
    vxData[vxIndex + 11] = vxList[07];
    vxData[vxIndex + 12] = r;
    vxData[vxIndex + 13] = g;
    vxData[vxIndex + 14] = b;
    vxData[vxIndex + 15] = a;
    vxData[vxIndex + 16] = right;
    vxData[vxIndex + 17] = bottom;
    vxData[vxIndex + 18] = vxList[10];
    vxData[vxIndex + 19] = vxList[11];
    vxData[vxIndex + 20] = r;
    vxData[vxIndex + 21] = g;
    vxData[vxIndex + 22] = b;
    vxData[vxIndex + 23] = a;
    vxData[vxIndex + 24] = left;
    vxData[vxIndex + 25] = bottom;
    vxData[vxIndex + 26] = vxList[14];
    vxData[vxIndex + 27] = vxList[15];
    vxData[vxIndex + 28] = r;
    vxData[vxIndex + 29] = g;
    vxData[vxIndex + 30] = b;
    vxData[vxIndex + 31] = a;

    renderBufferVertex.position += vxListCount * 8;
    renderBufferVertex.count += vxListCount;
  }
}
