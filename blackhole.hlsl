

float absorption = 1;
float scatter = 1;
int steps = 1000;
float bigstepsize = 10;
float smallstepsize = 1;
int lightsteps = 50;
float lightstepsize = 10;
float smalllightstepsize = 1;
transparancy = 1;
float3 lightOffset = {0,0,10};
float3 lightPos = objPos + lightOffset;
float lightIntensity = 20;
float e = 2.71828;
float3 rayPos = worldPos;
float radius = distance(objPos, worldPos);
float3 light = 0;
float3 color = {1.0,0.5,0.2};
float3 rayvector = -normalize(Parameters.CameraVector);
float g = 0.8;
float noisescale = 100;
float lightTransmission;

#define eventhorizon 15
#define force 10
Dir = -Parameters.CameraVector;
float fresnel = pow(dot(Parameters.WorldNormal, -Dir),2);
holemask = 0;


struct functions
{
    float random (float2 uv)
    {
        return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
    }

    float phase(float g, float cos_theta)
    {
        float denom = 1 + g * g - 2 * g * cos_theta;
        return 1/(4*3.1415)*(1-g*g)/(denom*sqrt(denom));
    }

    float smoothstep(float lo, float hi, float x)
    {
        float t = clamp((x - lo) / (hi - lo), 0.f, 1.f);
        return t * t * (3.0 - (2.0 * t));
    }

    float densityFromTexture(float3 samplePos, Texture2D <float4> disk, SamplerState texSampler, float radius)
    {
        //float result = Texture2DSample(disk, texSampler, 0.5*(samplePos.xy/radius+1)).r;
        //result = result * (1-smoothstep(0,5 , abs(samplePos.z)))*50;
        //return pow(result,2);
        float result = Texture2DSample(disk, texSampler, 0.5*(samplePos.xy/radius*0.99+1)).r;
        result = result * (1-smoothstep(0,result*200 , abs(samplePos.z)))*50;
        return result;
    }

};

functions f;

float3 rayDir = normalize(Dir)*stepsize;

for(int i = 0; i < steps; i++)
{
    float dist = distance(rayPos, objPos);
    float density = f.densityFromTexture(rayPos-objPos, disk, diskSampler, radius);
    float sample_transparancy = pow(e,-stepsize*(absorption+scatter)*density);
    
    transparancy = transparancy * sample_transparancy;

    
    float3 lightrayPos = rayPos;
    float3 lightrayVector = normalize(lightPos-rayPos);
    lightTransmission = 1;
    
        for(int j = 0; j < lightsteps; j++ )
        {
            lightrayPos += lightrayVector*lightstepsize;
            float lightdensity = f.densityFromTexture(lightrayPos-objPos, disk, diskSampler, radius);
            lightTransmission = lightTransmission*pow(e,-lightstepsize*(absorption+scatter)*lightdensity);
            if(distance(lightrayPos, objPos) < eventhorizon) break;
        }
        float cos_theta = dot(rayvector,lightrayVector);
        light = light + scatter * lightTransmission * stepsize * lightIntensity * color * f.phase(g, cos_theta) * (1-sample_transparancy);
    
    
    
    
    //rayPos = rayPos + rayvector*stepsize*ditherer;


    rayDir += (-normalize(rayPos-objPos)*force/(pow(dist,2)))*stepsize*stepsize;
    rayDir = normalize(rayDir)*stepsize;
    rayPos +=rayDir;
    Dir = rayDir;



    if(distance(rayPos, objPos) > radius+1)
    {
        holemask = 1;
        break;
    }
}


return light;










