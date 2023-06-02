#include "./common.glsl"

struct Material {
    vec3 albedo;
	float metalness; 
    float roughness;
    float emissive;
    float opaqueness; 
    float ior;
    float attenuation;
    int texture;
};
struct Sphere {
    vec3 center;
    float radius;
    Material prop;
};
struct Cube {
    vec3 center;
    float size;
    vec3 rotation;
    Material prop;
};
const int primary = 1, diffuse = 2, specular = 3;  
struct Ray {
    vec3 origin, direction;
    int type;
};
struct Intersection {
    vec3 point;
    vec3 normal[2];
    float distance[2];
    Material object;
};
struct Camera {
    float aperture; 
    float fov; 
    vec3 target, position;
};

const Camera camera = Camera(0.45, 35.0, vec3(0.0,1.0,0.0), vec3(0.0));
const Material area = Material(vec3(1.0), 1.0, 0.0, 1.1, 1.0, 0.0, 0.0, 0);
const Intersection miss = Intersection(vec3(0.0), vec3[2](vec3(0.0), vec3(0.0)), float[2](INFINITY, 0.0), area);

// FIRST SCENE 

const vec3 white = vec3(1.0);
const vec3 iron = vec3(0.988,0.98,0.96);
const vec3 red = vec3(1, 0, 0);
const vec3 green = vec3(0, 1, 0);
const vec3 blue = vec3(0, 0, 1);

const Material mirrorMetal = Material(iron, 1.0, 0.01, 0.0, 1.0, 4.0, 0.0, 0);
const Material redPlastic = Material(red, 0.0, 0.8, 0.0, 1.0, 4.0, 0.0, 0);
const Material greenPlastic = Material(green, 0.2, 0.25, 0.0, 1.0, 4.0, 0.0, 0);
const Material bluePlastic = Material(blue, 0.0, 0.4, 0.0, 1.0, 4.0, 0.0, 0);
const Material threecolorLines = Material(blue, 0.7, 0.2, 0.0, 1.0, 4.0, 0.0, 1);
const Material light = Material(white, 0.0, 0.0, 5.0, 1.0, 0.0, 0.0, 0);
const Sphere groundSphere = Sphere(vec3(0,-10000,0), 10000.0, threecolorLines);
const Sphere redSphere = Sphere(vec3(-1,0.6,-2.1), 0.6, redPlastic);
const Sphere greenSphere = Sphere(vec3(2,0.5,2.5), 0.5, greenPlastic);
const Sphere blueSphere = Sphere(vec3(-3,1.1,0.5), 0.7, bluePlastic);
const Sphere lightSphere = Sphere(vec3(0,30,30), 5.0, light);
const Cube firstMirror = Cube(vec3(-13,10.,-5), 10.0, vec3(0,-0.5,0.001), mirrorMetal);
const Cube secondMirror = Cube(vec3(13,10.0,-5), 10.0, vec3(0,0.1,0), mirrorMetal);

#define spheres Sphere[](groundSphere, redSphere, greenSphere, blueSphere, lightSphere)

#define cubes Cube[](firstMirror, secondMirror)
    
// SECOND SCRNE

const Material star = Material(white, 0.0, 0.0, 10.0, 1.0, 0.0, 0.0, 0);
const Material redStar = Material(red, 0.0, 0.0, 10.0, 1.0, 0.0, 0.0, 0);
const Material greenStar = Material(green, 0.0, 0.0, 10.0, 1.0, 0.0, 0.0, 0);
const Material blueStar = Material(blue, 0.0, 0.0, 10.0, 1.0, 0.0, 0.0, 0);
const Material rainb = Material(red, 0.0, 0.8, 4.5, 1.0, 4.0, 0.0, 6);
const Material roughPlastic = Material(vec3(0.5), 0.0, 0.0, 0.0, 1.0, 4.0, 0.0, 2);
const Material mglass_1 = Material(vec3(0.01,0.05,0.03), 0.9, 0.05, 0.0, 0.0, 1.1, 0.0, 0);
const Material mglass_2 = Material(vec3(0.4,0.3,0.1), 1.0, 0.05, 0.0, 0.0, 2.33, 0.0, 0);
const Material mglass_3 = Material(vec3(1.0), 1.0, 0.05, 0.0, 0.0, 1.5, 0.0, 0);
const Sphere ground_2 = Sphere(vec3(0,-10000,0), 10000.0, roughPlastic);
const Sphere sun_1 = Sphere(vec3(30*2,20,0), 2.0, star);
const Sphere sun_2 = Sphere(vec3(0,80,-30*2), 15.0, star);
const Sphere sun_3 = Sphere(vec3(-40*2,40,0), 25.0, greenStar);
const Sphere sun_4 = Sphere(vec3(0,60,-40*2), 15.0, blueStar);
const Sphere sun_5 = Sphere(vec3(40,70,20), 15.0,redStar);
const Sphere sglass_2 = Sphere(vec3(-1.5,0.65,2), 0.6, mglass_2); 
const Sphere sglass_3 = Sphere(vec3(2.5,1.4,0.5), 1.4, mglass_3);
const Sphere sglass_1 = Sphere(vec3(-3.0,1.0,0.5), 0.9, mglass_3);

// #define spheres Sphere[](ground_2, sglass_1, sglass_2, sglass_3, sun_1, sun_2, sun_3, sun_4, sun_5)

// THIRD SCENE

const Material whitePlastic = Material(white, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 3);
const Material redMetal = Material(red, 0.0, 0.1, 0.0, 1.0, 0.0, 0.0, 0);
const Sphere ground_3 = Sphere(vec3(0,-10000,0), 10000.0, redMetal);
const Cube whiteCubbe_1 = Cube(vec3(-5,2.0,0), 2.0, vec3(0,0.8,0), whitePlastic);
const Cube whiteCubbe_2 = Cube(vec3(3,6.0,5.5), 1.0, vec3(0.5,0.6,0.3), whitePlastic);

// #define spheres Sphere[](ground_3, sun_2)

// #define cubes Cube[](whiteCubbe_1, whiteCubbe_2)

// FOURTH SCENE

const Material roughMetal = Material(iron, 0.6, 0.9, 0.0, 1.0, 4.0, 0.0, 0);
const Cube roughCube = Cube(vec3(0.0,-4.9,0.0), 5.0, vec3(0.0,0.5,0.0), roughMetal);
const Material mground_4 = Material(vec3(0.9,0.2,0.7), 0.0, 0.0, 0.0, 1.0, 4.0, 0.0, 4);
const Sphere ground_4 = Sphere(vec3(0,-10000,0), 10000.0, mground_4);
const Material mlamp_1 = Material(red, 0.0, 0.8, 200.0, 1.0, 4.0, 0.0, 6);
const Material mlamp_2 = Material(blue, 0.0, 0.8, 200.0, 1.0, 4.0, 0.0, 6);
const Sphere slamp_1 = Sphere(vec3(-2.2 +1.5, 6.6 ,-6.8 - 2.8), 0.50, mlamp_1); 
const Sphere slamp_2 = Sphere(vec3(5.0 -0.5, 7 ,-5.0 - 2.0), 0.50, mlamp_2);
const Material mlamp_3 = Material(vec3(1.0), 0.0, 0.8, 50.0, 1.0, 4.0, 0.0, 6);
const Sphere slamp_3 = Sphere(vec3(0, 15 ,5), 0.4, mlamp_3);
const Material mbarrier_1 = Material(vec3(1), 0.0, 1.0, 0.0, 1.0, 4.0, 0.0, 6);
const Material mbarrier_2 = Material(vec3(1), 0.0, 1.0, 0.0, 1.0, 4.0, 0.0, 6);
const Sphere sbarrier_1 = Sphere(vec3(-2.2,3.6,-6.8), 2.5, mbarrier_2); 
const Sphere sbarrier_2 = Sphere(vec3(5,3.6,-5.0), 2.5, mbarrier_2);

// #define spheres Sphere[](sbarrier_1, sbarrier_2, ground_4, slamp_1, slamp_2, slamp_3)

// #define cubes Cube[](roughCube)

vec2 setmouse () {
    if (iMouse.xy == vec2(0)) return vec2(-.9,-0.2);
    else return (2.*iMouse.xy - iResolution.xy) / iResolution.yy;
}
vec3 updatecamera (vec2 mouse) {
    float x = sin(-mouse.x*PI);
    float y = mix(0.05, 2.0, smoothstep(-0.75, 0.75, mouse.y));
    float z = cos(mouse.x*PI);
    return 24.0 * vec3(x, y, z);
}
mat3 lookatmatrix(vec3 eye, vec3 target, float roll) {
	vec3 rollVec = vec3(sin(roll), cos(roll), 0.0);
	vec3 w = normalize(eye - target);
	vec3 u = normalize(cross(rollVec,w));
	vec3 v = normalize(cross(w,u));
    return mat3(u, v, w);
}
vec3 target = vec3(0.0, 1.0, 0.0);

void texture(inout Intersection hit, Ray r) {
    if (hit.object.texture == 10) {
        // Colorful strokes
        vec3 fragPos = 55.5 * hit.point; 
        vec2 q = floor(vec2(fragPos.x, fragPos.z));
        float f = mod(abs(hit.point.x + pow(10.0, 2.0))*abs(hash11(q.y)), 4.25);  
        hit.object.albedo = mix(hit.object.albedo, vec3(0.4), f);
        hit.object.roughness = mix(0.75, 0.2, f);
    } else if (hit.object.texture == 9) {
        // Metal strokes
        vec3 fragPos = 55.5 * hit.point; 
        vec2 q = floor(vec2(fragPos.x, fragPos.z));
        float f = mod(abs(hit.point.x + pow(10.0, 2.0))*abs(hash11(q.y)), 4.25);  
        hit.object.albedo = mix(vec3(1.0), vec3(0.4), f);
        hit.object.roughness = mix(0.75, 0.2, f);
    } else if (hit.object.texture == 4) {
        // Grid mozaic
        vec3 fragPos = hit.point; 
        fragPos *= 55.5;
        vec2 q = floor(vec2(fragPos.x, fragPos.z));
        float f = mod(q.x*q.y, 4.25); 
        hit.object.albedo = mix(hit.object.albedo, vec3(0.7), f);
        hit.object.roughness = mix(0.75, 0.2, f);
    } else if (hit.object.texture == 8) {
        // Grid 1
        vec3 fragPos = hit.point; 
        fragPos *= 10.;
        vec2 q = floor(vec2(fragPos.x, fragPos.z));
        float f = mod(hash11(q.x)*hash11(q.y), 1.355);
        hit.object.albedo = mix(vec3(0.1,0.2,0.4), vec3(0.4), f);
        hit.object.roughness = mix(0.75, 0.2, f);
    } else if (hit.object.texture == 7) {
        // Grid 2
        vec3 fragPos = hit.point; 
        fragPos *= 10.;
        vec2 q = floor(vec2(fragPos.x, fragPos.z));
        float f = mod(hash11(q.x)+hash11(q.y), 99.9); 
        hit.object.albedo = mix(vec3(0.8,0.7,0.5), vec3(0.4), f);
        hit.object.roughness = mix(0.75, 0.2, f);
        hit.object.metalness = mix(0.01, 0.04, f);
    } else if (hit.object.texture == 1) {
        // Parallels 
        vec3 fragPos = r.origin + r.direction*hit.distance[0]; 
        fragPos *= 5.0;
        vec2 q = floor(vec2(fragPos.x, fragPos.z));
        float f = mod(q.x, 3.0);  
        hit.object.albedo = mix(hit.object.albedo, vec3(0.4), f);
        hit.object.roughness = mix(0.75, 0.2, f); 
    } else if (hit.object.texture == 3) {
        // Rrainbow box
        vec3 p = hit.point; 
        float frequency = 0.1;
        float amplitude = 0.5;
        float constant = 3.3;
        float red = sin(frequency * constant + p.x) * amplitude + 0.5;
        float green = sin(frequency * constant + p.y) * amplitude + 0.5;
        float blue = sin(frequency * constant + p.z) * amplitude + 0.5;
        hit.object.albedo = vec3(red, green, blue);
    } else if (hit.object.texture == 6) {
        //  Rainbow sphere 
        vec3 position = hit.point; 
        vec3 normal = hit.normal[0];
        float t = dot(normal, vec3(0.7,1.0,0.0));
        float f = mod(t, hash11(t));
        hit.object.albedo = mix(normal, normalize(position), f);
    }
}
