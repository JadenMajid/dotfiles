#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

float bands = 20.0;

vec3 quant(vec3 c){
  return floor(c * bands)/bands;
}

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    fragColor = vec4(quant(pixColor.rgb), 1.0);
}

