Shader "Custom/SpaceSkybox"
{
    Properties
    {
        _StarColor ("Star Color", Color) = (1,1,1,1)
        _NebulaColor ("Nebula Color", Color) = (0.2,0.4,0.6,1)
        _StarDensity ("Star Density", Range(0,1)) = 0.5
        _NebulaIntensity ("Nebula Intensity", Range(0,1)) = 0.3
    }
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Opaque" }
        Cull Off
        Lighting Off
        ZWrite Off
        Fog { Mode Off }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 dir : TEXCOORD0;
            };

            float4 _StarColor;
            float4 _NebulaColor;
            float _StarDensity;
            float _NebulaIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.dir = normalize(v.vertex.xyz);
                return o;
            }

            float hash(float3 p)
            {
                return frac(sin(dot(p, float3(12.9898,78.233,45.164))) * 43758.5453);
            }

            float noise(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f*f*(3.0-2.0*f);
                float n = lerp(lerp(lerp(hash(i + float3(0,0,0)), hash(i + float3(1,0,0)), f.x),
                                   lerp(hash(i + float3(0,1,0)), hash(i + float3(1,1,0)), f.x), f.y),
                              lerp(lerp(hash(i + float3(0,0,1)), hash(i + float3(1,0,1)), f.x),
                                   lerp(hash(i + float3(0,1,1)), hash(i + float3(1,1,1)), f.x), f.y), f.z);
                return n;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float starField = step(1.0 - _StarDensity, hash(i.dir * 100.0));
                float nebula = noise(i.dir * 5.0) * _NebulaIntensity;
                float4 col = starField * _StarColor + nebula * _NebulaColor;
                return col;
            }
            ENDCG
        }
    }
    FallBack "RenderFX/Skybox"
}
