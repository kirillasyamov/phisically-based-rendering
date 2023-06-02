#include "./scene.glsl"

// The Fresnel Equation
vec3 fresnelschlick(Ray r, Intersection i) {
    vec3 view = normalize(r.origin - i.point); 
    float cosTheta = abs(min(dot(view, i.normal[0]), 1.0));
    vec3 F0 = mix(vec3(0.04), i.object.albedo, i.object.metalness);
	return F0 - (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
} 