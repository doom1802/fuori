#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 uSize;
uniform vec2 uAtlasSize;
uniform vec4 uFrame;
uniform vec3 uTint;
uniform vec3 uReference;
uniform float uEnabled;
uniform sampler2D uAtlas;
out vec4 fragColor;
void main() {
  vec2 local = clamp(FlutterFragCoord().xy / uSize, 0.0, 0.9999);
  vec2 pixel = uFrame.xy + min(floor(local * uFrame.zw / 2.0) * 2.0 + 1.0, uFrame.zw - 0.5);
  vec4 sampled = texture(uAtlas, pixel / uAtlasSize);
  if (sampled.a < 0.96) { fragColor = vec4(0.0); return; }
  vec3 c = sampled.rgb / sampled.a;
  float brightness = dot(c, vec3(0.299, 0.587, 0.114));
  if (uEnabled > 0.5 && brightness > 0.10) {
    c = clamp(c * uTint / max(uReference, vec3(0.15)), 0.0, 1.0);
  }
  fragColor = vec4(c, 1.0);
}
