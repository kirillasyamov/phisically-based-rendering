#include "./math.glsl"
#iChannel0 "file://shader.glsl"

Ray spawn (Camera c, vec2 uvNorm, float seed) {
    float aspect = iResolution.x / iResolution.y;
    float zoom = 0.8;
    c.position = updatecamera(setmouse()) / zoom;
    vec3 start = c.aperture * 0.5 * vec3(randInCircle(seed + 84.123), 0.0);

    vec2 offset = hash21(seed + 13.271) / iResolution.xy;
    vec2 sub = uvNorm + offset;
    
    float focalDist = length(c.target - c.position);
    float vertical = focalDist * 2.0 * tan(radians(c.fov/2.0));
    float horizontal = vertical * aspect;
    vec3 lowerLeftCorner = -vec3(horizontal/2., vertical/2., focalDist);

    vec3 end = lowerLeftCorner + vec3(sub.x*horizontal, sub.y*vertical, 0.);
    
    vec3 lense = normalize(end - start);
    
    mat3 viewmatrix = lookatmatrix(c.position, c.target, 0.0);
    vec3 origin = c.position + viewmatrix * start;
    vec3 direction = viewmatrix * lense;
    return Ray(origin, direction, primary);
}
Ray spawn (Ray prev, Intersection i, float seed) {
    bool isDiffuseRay = hash11(seed + 23.5123) < 0.5;
    vec3 direction, origin;
    int type;
    if (isDiffuseRay) {
        direction = i.normal[0] + randVector(seed);
        type = diffuse;
    } else {
        direction = reflect(prev.direction, i.normal[0]) + i.object.roughness*randInSphere(seed+17.1321);
        type = specular;
    }
    origin = i.point + i.normal[0] * EPSILON;
    return Ray(origin, normalize(direction), type);
}

bool intersect(Ray r, Cube c, out Intersection hit) {
    vec3 rad = vec3(c.size);
    mat4 rot = rotationMat ( c.rotation );
	mat4 tra = transformationMat ( c.center );
	mat4 txi = tra * rot; 
	mat4 txx = inverse( txi );
	vec3 rd = (txx*vec4(r.direction,0.0)).xyz;
	vec3 ro = (txx*vec4(r.origin,1.0)).xyz;
    vec3 m = 1.0/rd;
    vec3 s = vec3((rd.x<0.0) ? 1.0 : -1.0,
                  (rd.y<0.0) ? 1.0 : -1.0,
                  (rd.z<0.0) ? 1.0 : -1.0);
    vec3 t1 = m*(-ro + s*rad);
    vec3 t2 = m*(-ro - s*rad);

    float tN = max( max( t1.x, t1.y ), t1.z );
    float tF = min( min( t2.x, t2.y ), t2.z );
	
    if( tN>tF || tF<0.0) return false;
    
    vec3 normal;
    if( t1.x > t1.y && t1.x > t1.z ) { 
        normal=rot[0].xyz*s.x; 
    } else if ( t1.y > t1.z ) { 
        normal=rot[1].xyz*s.y;  
    } else { 
        normal=rot[2].xyz*s.z; 
    }
    vec3 point = r.origin + r.direction * tN - r.direction * 0.01;
    hit = Intersection(point, vec3[2](normal,vec3(0)), float[2](tN, tF), c.prop);
    return true;
}
bool intersect(Ray r, Sphere s, out Intersection hit) {
    float b = 2.0 * dot(r.direction, r.origin - s.center);

    float c = pow(length(r.origin - s.center), 2.0) - pow(s.radius, 2.0);
    float delta = pow(b, 2.0) - 4.0 * c;
    if (delta > 0.0) {
        float t1 = (-b + sqrt(delta)) / 2.0;
        float t2 = (-b - sqrt(delta)) / 2.0;
        float t = min(t1,t2);
        if (t > EPSILON && t < INFINITY) {
            // outPoint = r.direction * max(t1,t2) + r.origin;
            vec3 point = r.direction * t + r.origin;
            vec3 normal = (point - s.center) / s.radius; 
            hit = Intersection (point, vec3[2](normal,-normal), float[2](t, max(t1,t2)), s.prop);
            return true;
        }
    }
    return false;
}

void update(inout Intersection nearest, Intersection current) {
    if (current.distance[0] < nearest.distance[0]) nearest = current;
}
bool trace(Ray r, inout Intersection nearest) {
    Intersection current ;
    for (int i = 0; i < spheres.length(); i++) {
        if (intersect(r, spheres[i], current)) update(nearest, current);
    }
    for (int i = 0; i < cubes.length(); i++) {
        if (intersect(r, cubes[i], current)) update(nearest, current);
    }
    return nearest.distance[0] < INFINITY;
}

void radiance (inout Intersection updatingHit, inout vec3 updatingColor, inout Ray updatingRay, float seed, int bounce) {
    vec3 direction;
    texture(updatingHit, updatingRay);
    float rayseed = seed + 7.1*float(iFrame) + 5681.123 + float(bounce)*92.13;
    Ray r = spawn(updatingRay, updatingHit, rayseed);
    updatingRay = r;
    float x = hash11(rayseed * float(iFrame));
    vec3 kS = fresnelschlick(r, updatingHit);     
    vec3 kD = vec3(1.0) - kS; 
    if (r.type == diffuse) updatingColor *= mix(updatingHit.object.albedo, vec3(0.0), updatingHit.object.metalness); 
    else updatingColor *= kS;
}

vec3 render(Ray r, float seed) {
	vec3 mask = vec3(1.0);
    for (int n = 0; n < BOUNCES; n++) {
        Intersection hit = miss;

		if (trace(r, hit)) {
            if (hit.object.opaqueness < EPSILON && hash11(seed + 23.62165) > hit.object.opaqueness) {
                r.origin = hit.point - hit.normal[0] * EPSILON;
                r.direction = refract(r.direction, hit.normal[0], 1.0 / hit.object.ior);
                float mid = (hit.object.albedo.x + hit.object.albedo.y + hit.object.albedo.z) / 3.0;
                mask = mix(mask, hit.object.albedo, mid);
                continue;
            } if (hit.object.emissive > EPSILON) { 
                texture(hit, r);
                mask *= hit.object.emissive * hit.object.albedo;
                break; 
            } else {
                radiance(hit, mask, r, seed, n);
            }
        } else {
            hit.point = r.origin + r.direction * INFINITY;
            vec3 color = vec3(0.2,0.2,0.9) * hit.point.y / 20.0 + 0.25;
            color /= 3.0;
            if (r.type == primary) return color;
            mask *= color;
            break; 
        }
    }
    return mask;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    
    vec2 uvNorm = fragCoord / iResolution.xy;
    vec3 oldCol = vec3(0);
    
    float frame = texelFetch(iChannel0, ivec2(0,0), 0)[0];
    oldCol = texelFetch(iChannel0, ivec2(fragCoord), 0).xyz;       
    
    if (iFrame == 0 || frame == 0.) oldCol = vec3(0,0,0);
    if (ivec2(fragCoord) == ivec2(0, 0)) {
        frame++;
        bool mousePressed = iMouse.z > 0.0;
        if (mousePressed) frame = 0.0; 
        fragColor = vec4(frame, 0, 0, 0);
        return;
    }
    
    vec3 newCol = vec3(0);
    
    for (int n = 0; n < SAMPLES; n++) {
    	float seed = hash11( dot( fragCoord, vec2(12.9898, 78.233) ) + 1113.1*hash11(float(iFrame*n)) );
        Ray r = spawn (camera, uvNorm, seed);
    	newCol += render(r, seed);
    }
    newCol /= float(SAMPLES);
    fragColor = vec4(oldCol + newCol, 1.0);
}