

int steps = 1000;
int lightsteps = 50;
float smalllightstepsize = 2;
transparancy = 1;
float3 lightPos[] = {{0,0,diskThickness+1},{0,0,-diskThickness-1}};
float e = 2.71828;
float3 rayPos = worldPos - objPos;
float radius = distance(objPos, worldPos);
float3 light = 0;
float3 rayvector = -normalize(Parameters.CameraVector);
float g = 0.8;
float noisescale = 100;
float lightTransmission;
#define eventhorizon 15
#define force 15
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

    float densityFromTexture(float3 samplePos, Texture2D <float4> disk, SamplerState texSampler, float radius, float diskThickness)
    {
        float result = Texture2DSample(disk, texSampler, 0.5*(samplePos.xy/radius*0.99+1)).r;
        result = result * (1-smoothstep(0,result*diskThickness+1 , abs(samplePos.z)));
        return result;
    }

};

functions f;

float3 rayDir = normalize(Dir)*stepsize;

for(int i = 0; i < steps; i++)
{
    float currentStep = 0;
    if(abs((rayPos).z) > 6)
    {
        currentStep = stepsize;
    }
    else
    {
        currentStep = smallstepsize;
    }
    float dist = length(rayPos);
    if(dist < eventhorizon) break;
    
    float density = f.densityFromTexture(rayPos, disk, diskSampler, radius, diskThickness);    float sample_transparancy = pow(e,-currentStep*(absorption+scatter)*density);
    
    transparancy = transparancy * sample_transparancy;
    if(density > 0.01)
    {
    for(int lightnr = 0; lightnr < 1; lightnr++)
    {
        float3 lightrayPos = rayPos;
        float3 lightrayVector = normalize(lightPos[lightnr]-rayPos);
        float lightdensity = 0;
        
            for(int j = 0; j < lightsteps; j++ )
            {
                lightrayPos += lightrayVector*lightstepsize;
                lightdensity += f.densityFromTexture(lightrayPos, disk, diskSampler, radius, diskThickness);
                if(length(lightrayPos) < eventhorizon) 
                {                    break;
                }
            }
    
            float cos_theta = dot(rayvector,lightrayVector);
            lightTransmission = pow(e,-lightstepsize*(absorption+scatter)*lightdensity);
            light = light + scatter * lightTransmission * stepsize * lightIntensity * color * f.phase(g, cos_theta)*transparancy*density+diskcolor*transparancy*density*0.05*scatter;
    }
    }

    
    
    
    //rayPos = rayPos + rayvector*stepsize*ditherer;

    rayDir = normalize(rayDir)*currentStep;
    rayDir += (-normalize(rayPos)*force/(pow(dist,2)))*currentStep*currentStep*fresnel;
    rayDir = normalize(rayDir)*currentStep;
    rayPos +=rayDir;
    Dir = rayDir;

    
    if(transparancy < 0.01) break;
    if(length(rayPos) > radius)
    {
        holemask = 1;
        break;
    }
}


return light;















