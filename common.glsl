#define INFINITY 100.0
#define EPSILON 0.001
#define PI 3.1415926
#define TAU 6.2831853
#define BOUNCES 20
#define SAMPLES 5

float hash11(float seed) {
    seed = fract(seed * .1031);
    seed *= seed + 33.33;
    seed *= seed + seed;
    return fract(seed);
}
float hash12(vec2 seed) {
	vec3 p3  = fract(vec3(seed.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}
vec2 hash21(float seed) {
	vec3 p3 = fract(vec3(seed) * vec3(.1031, .1030, .0973));
	p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}
vec2 hash22(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}
vec3 hash31(float p) {
   vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
   p3 += dot(p3, p3.yzx+33.33);
   return fract((p3.xxy+p3.yzz)*p3.zyx); 
}

vec3 randVector(float seed) {
    // returns random coordinates of a unit vector
    vec2 rand = hash21(seed);
    float a = rand.x*TAU;  
    float z = rand.y*2. - 1.; 
    float r = sqrt(1. - z*z);
    return vec3(r*cos(a), r*sin(a), z);
}
vec3 randInSphere (float seed) {
    // returns random coordinates of a point inscribed in a unit sphere
    vec3 hash = hash31(seed);
    float theta = hash.x * TAU;
    float v = hash.y;
    float r = pow(hash.z, 0.333333);    
    float phi = acos((2.*v)-1.);
    float sinphi = sin(phi);    
    vec3 p;
    p.x = r * sinphi * cos(theta);
    p.y = r * sinphi * sin(theta);
    p.z = r * cos(phi); 
    return p;
}
// vec3 randInHemisphere(float seed, vec3 normal) {
//     vec3 p = RandomInUnitSphere(seed);
//     return (dot(p, normal) > 0.0) ? p : -p;
// }
vec2 randInCircle(float seed) {
    // returns random coordinates of a point inscribed in a unit circle
    vec2 rand = hash21(seed);
    float angle = rand.x*TAU;
    float radius = sqrt(rand.y);
    return radius * vec2(cos(angle), sin(angle));
}

const mat3 ACESInputMat  = mat3 (
    0.59719, 0.07600, 0.02840,    
    0.35458, 0.90834, 0.13383,    
    0.04823,  0.01566, 0.83777
);
const mat3 ACESOutputMat = mat3 (
    1.60475,-0.10208,-0.00327,   
    -0.53108, 1.10813,-0.07276,   
    -0.07367, -0.00605, 1.07602
);
vec3 RRTAndODTFit(vec3 v) { 
    return (v * (v + 0.0245786) - 0.000090537) / (v * (0.983729 * v + 0.4329510) + 0.238081); 
}

vec3 tonemap(vec3 color) { 
    return clamp(ACESOutputMat * RRTAndODTFit(ACESInputMat * color), 0.0, 1.0); 
} 

mat4 rotationMat(vec3 angles) {
    vec3 c = vec3(cos(angles.x), cos(angles.y), cos(angles.z));
    vec3 s = vec3(sin(angles.x), sin(angles.y), sin(angles.z));
    return mat4(
        vec4(c.y * c.z, -c.y * s.z, s.y, 0.0),
        vec4(c.x*s.z + s.x*s.y*c.z, c.x*c.z - s.x*s.y*s.z, -s.x*c.y, 0.0),
        vec4(s.x*s.z - c.x*s.y*c.z, s.x*c.z + c.x*s.y*s.z, c.x*c.y, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}
mat4 transformationMat(vec3 point) {
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(point.x, point.y, point.z, 1.0)
    );
}