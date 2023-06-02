#iChannel0 "file://shader.glsl"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = fragCoord/iResolution.xy; 

    vec3 color = texture(iChannel0, uv).rgb ; 
    
    color = pow(color, vec3(0.4545)); 

    fragColor = vec4(color, 1.0);
}