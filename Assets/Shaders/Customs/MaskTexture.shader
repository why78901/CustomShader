Shader "Custom/MaskShader"
{
    //只显示固定区域
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskRect ("Mask Rect", Vector) = (0,0,20,20)//屏幕坐标，从xy开始宽高为zw
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
            float4 _MaskRect;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv) * i.color;
                float4 inMask = float4( 
                    step(float2(_MaskRect.x, _MaskRect.y), i.vertex.xy), 
                    step(i.vertex.xy, float2(_MaskRect.x + _MaskRect.z, _MaskRect.y + _MaskRect.w)) );

                if (all(inMask) == false ){
                    color.a *= 0;
                }
                return color;
            }
            ENDCG
        }
    }
}
