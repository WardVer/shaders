

int steps = 1000;
int lightsteps = 50;
float smalllightstepsize = 2;
transparancy = 1;
float3 lightPos[] = {{0,0,5},{0,0,-5}};
float e = 2.71828;
float radius = distance(objPos, worldPos);
float3 rayPos = camPos-objPos;
float3 rayvector = -normalize(Parameters.CameraVector);

if(length(rayPos) > radius)
{

float searchMultiplier = length(rayPos);
for(int i = 0; i < 20; i++)
{
    rayPos += rayvector * searchMultiplier;
    if(searchMultiplier > 0)
    {
       
        if(length(rayPos) < radius)
        {
            if(radius - length(rayPos) < 1)
            {
                break;
            }
            searchMultiplier = searchMultiplier * -0.5;
        }
        else
        {
            continue;
        }
    }
    else
    {
        if(length(rayPos) > radius)
        {
            searchMultiplier = searchMultiplier * -0.5;
        }
        else
        {
            continue;;
        }

    }

}
}



float3 light = 0;

float g = 0.8;
float noisescale = 100;
float lightTransmission;
#define eventhorizon 5
float mass = 2;
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
        return 1/(4*3.14159265)*(1-g*g)/(denom*sqrt(denom));
    }

    float smoothstep(float lo, float hi, float x)
    {
        float t = clamp((x - lo) / (hi - lo), 0.f, 1.f);
        return t * t * (3.0 - (2.0 * t));
    }

    float densityFromTexture(float3 samplePos, Texture2D <float4> disk, SamplerState texSampler, float radius, float diskThickness)
    {
        float result = Texture2DSample(disk, texSampler, 0.5*(samplePos.xy/radius*0.99+1)).r;
        result = result * pow((1-smoothstep(0,result*diskThickness*pow(length(samplePos.xy)/80,2)+3 , abs(samplePos.z))),2);
        return result;
    }

};

functions f;

float3 rayDir = normalize(Dir)*stepsize;

for(int i = 0; i < steps; i++)
{
    float currentStep = 0;
    if(abs((rayPos).z) > 500)
    {
        currentStep = stepsize;
    }
    else
    {
        currentStep = smallstepsize;
    }
    float dist = length(rayPos);
    if(dist < eventhorizon) break;
    
    float density = f.densityFromTexture(rayPos, disk, diskSampler, radius, diskThickness);    
    float sample_transparancy = pow(e,-currentStep*(absorption+scatter)*density);
    

    //rayPos = rayPos + rayvector*stepsize*ditherer;
    rayDir = normalize(rayDir);
    rayDir += (-normalize(rayPos)*mass*eventhorizon/(pow(dist,2)))*abs(dot(normalize(rayPos), normalize(rayDir)))*fresnel;
    rayDir = normalize(rayDir)*currentStep;
    rayPos +=rayDir;
    Dir = rayDir;


    transparancy = transparancy * sample_transparancy;
    if(density > 0.000001)
    {
    for(int lightnr = 0; lightnr < 2; lightnr++)
    {
        float3 lightrayPos = rayPos;
        float3 lightrayVector = normalize(lightPos[lightnr]-rayPos);
        lightsteps = dist / lightstepsize;
        float lightdensity = 0;
        
            for(int j = 0; j < lightsteps; j++ )
            {
                lightrayPos += lightrayVector*lightstepsize;
                lightdensity += f.densityFromTexture(lightrayPos, disk, diskSampler, radius, diskThickness);
            }
    
            float cos_theta = dot(normalize(rayDir),normalize(lightrayVector));
            lightTransmission = pow(e,-lightstepsize*(scatter+absorption)*lightdensity);
            light = light + scatter * lightTransmission * stepsize * lightIntensity * color * max(0,f.phase(g, cos_theta))*transparancy*density/pow(dist, 2)+diskcolor*transparancy*density*0.05*scatter;
    }
    }

    
    
    
    

    
    if(transparancy < 0.001) break;
    if(length(rayPos) > radius)
    {
        holemask = 1;
        break;
    }
}


return light;
















