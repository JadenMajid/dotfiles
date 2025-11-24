#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform float u_time;
uniform sampler2D tex;
out vec4 fragColor;


vec3 applyScanlines(vec2 uv, vec3 color) {
    float t = u_time;
    float f = sin(t*10.0+uv.y * 800.0 * 3.14159);  // density via 800
    float mask = 0.5 + 0.5 * f;             // subtle brightness mod
    return color * mask;
}

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    fragColor = vec4(applyScanlines(v_texcoord,pixColor.rgb), pixColor.a);
}
