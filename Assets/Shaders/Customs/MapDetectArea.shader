Shader "Custom/MapDetectArea"
{
    //地图上挖圆洞
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _Center[24];//圆的中心点和半径
            float rectCount;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            float InSideCircle(float2 uv, float4 maskRect, float ratio)
            {
                float R = maskRect.z * ratio;
                float2 newUV = uv * float2(ratio, 1);
                float2 center = maskRect.xy * float2(ratio, 1);
                float r = distance(newUV, center);
                return r < R;
            }

            // float InSideCircle(float2 uv, float4 maskRect, float ratio)
            // {
            //     float R = maskRect.z;
            //     float r = distance(uv, maskRect.xy);
            //     return r < R;
            // }

            

            fixed4 frag (v2f i) : SV_Target
            {
               
                fixed4 color = tex2D(_MainTex, i.uv) * i.color;
                
                float ratio = _ScreenParams.x / _ScreenParams.y;
                float inMask = 0;
                float2 uv = i.uv;
                for(int i = 0; i < rectCount; i++)
                {
                   inMask = InSideCircle(uv, _Center[i], ratio);
                    if(inMask == 1)
                        break;
                }
                
                if(inMask == 1)
                {
                    color.a = 0;
                }
                // else
                // {
                //     color.a = 0.1f;
                // }
                return color;
            }

            
            ENDCG
        }
    }
    Fallback Off
}

