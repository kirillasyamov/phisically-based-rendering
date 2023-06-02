#iChannel0 "file://shader.glsl"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    
    fragCoord /= iResolution.xy;
    fragColor = vec4(fragCoord.x, fragCoord.y, fragCoord.x*fragCoord.y, 1.0);
}