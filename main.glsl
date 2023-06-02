#iChannel0 "file://shader.glsl"
#include "./common.glsl"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = fragCoord/iResolution.xy; 

    float frame = texelFetch(iChannel0, ivec2(0,0), 0)[0] + 1.0;

    vec3 color = texture(iChannel0, uv).rgb / frame; 

    color = tonemap(color); 
    
    color = pow(color, vec3(0.4545)); 

    fragColor = vec4(color, 1.0);
}
