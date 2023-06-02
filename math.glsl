#include "./scene.glsl"

// The Fresnel Equation
vec3 fresnelschlick(Ray r, Intersection i) {
    vec3 view = normalize(r.origin - i.point); 
    float cosTheta = abs(min(dot(view, i.normal[0]), 1.0));
    vec3 F0 = mix(vec3(0.04), i.object.albedo, i.object.metalness);
	return F0 - (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
} 
// The Normal Distribution Function
float trowbridgereitz (Ray r, Intersection i) {
    vec3 toCamera = normalize(r.origin - i.point);
    vec3 halfVector = normalize(r.direction + toCamera);
    float nh = max(dot(i.normal[0], halfVector), 0.0);
    float a2 = pow(i.object.roughness, 2.0);
    float numerator = i.object.roughness * i.object.roughness / PI;
    float denominator = nh * nh * (a2 - 1.0) + 1.0;
    return numerator / pow(denominator, 2.0); 
}
// The Geometry Function
float schlickbeckmann(float cosTheta, Intersection i) {
    float coeff = pow(i.object.ior + 1.0, 2.0) / 8.0;
    float denom = cosTheta * (1.0 - coeff) + coeff;
    return cosTheta / denom;
}
// The Geometry Function
float smith(Ray r, Intersection i) {
    vec3 toCamera = normalize(r.origin - i.point);
    vec3 toLight = normalize(r.direction - i.point);
    float nw = max(dot(i.normal[0], toCamera), 0.0);
    float nl = max(dot(i.normal[0], toLight), 0.0);
    return schlickbeckmann(nw, i) * schlickbeckmann(nl, i);
}
// The diffuse part of the BRDF
vec3 lambert(Intersection i, float fresnel) {
    vec3 coeff = vec3(1.0) - fresnel;
    vec3 ambient = vec3(0.03) * i.object.albedo * 0.5;
    return coeff * ambient / PI;
}
// The specular part of the BRDF
vec3 cooktorrance (Intersection i, Ray r, float D, vec3 F, float G) {
    vec3 toCamera = normalize(r.origin - i.point);
    vec3 toLight = normalize(r.direction - i.point);
    float cosTheta = dot(toLight, i.normal[0]);
    float coeff = dot(toCamera, i.normal[0]) * dot(toLight, i.normal[0]);
    return coeff * D * F * G / 4.0 / cosTheta;
}

vec3 specularBRDF(Ray r, Intersection i) {
    float D = trowbridgereitz(r, i);
    vec3 F = fresnelschlick(r, i);
    float G = smith(r, i);
    float cosTheta = max(dot(r.direction, i.normal[0]), 0.0);
    float fresnelcoeff = schlickbeckmann(cosTheta, i);
    return cooktorrance(i, r, D, F, G);
}