shader_type canvas_item;
uniform float clock = 0.0;
uniform float reveal : hint_range(0.0,1.0) = 0.0;
uniform vec2 drift = vec2(0.0);
void fragment() {
 vec2 uv=UV;
 float water=smoothstep(0.19,0.26,uv.y)*(1.0-smoothstep(0.31,0.35,uv.y));
 uv.x+=sin(uv.y*180.0+clock*0.65)*0.0009*water;
 uv+=drift*0.0012;
 vec4 tex=texture(TEXTURE,clamp(uv,vec2(0.003),vec2(0.997)));
 float lamp=exp(-length((UV-vec2(0.09,0.36))*vec2(2.0,1.0))*7.0);
 float flicker=0.028*sin(clock*3.1)+0.016*sin(clock*5.7);
 tex.rgb+=vec3(1.0,0.52,0.16)*lamp*flicker;
 float town=exp(-length((UV-vec2(0.60,0.22))*vec2(1.0,1.6))*5.0);
 tex.rgb+=vec3(0.28,0.19,0.07)*town*reveal;
 COLOR=tex;
}
