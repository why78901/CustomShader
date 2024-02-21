Shader "Custom/GalaxyInstance"
{
    //GPU实例化
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Range("Range",Float) = 100
        [Enum(BillBoard,1,VerticalBillboard,0)]_BillBoardType("BillBoard Type",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"= "Transparent" }
        Blend One One
        Cull Back
        ZWrite False
        ZTest LEqual

        Pass
        {
            Name "PassUnlit"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing //是否开启GPUInstance勾选项
            #include "UnityCG.cginc"
            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
            UNITY_DEFINE_INSTANCED_PROP(float4,_TintColor)
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)
            float _BillBoardType;
            
           

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR ;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float4 colorVert : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            // CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Range;
            // CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o)
                // // o.vertex = UnityObjectToClipPos(v.vertex);
                // // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv;
                // //将相机从世界空间转换到模型的本地空间中,而这个转换后的相机坐标即是点也是模型中心点(0,0,0)到相机的方向向量，如果按照相机空间来定义的话，可以把这个向量定义为相机空间下的Z值
                // float3 cameraOS_Z = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                // //BillBoardType=0时,圆柱形BillBoard;BillBoard=1时,圆形BillBoard;
                // cameraOS_Z.y = cameraOS_Z.y * _BillBoardType;
                // //归一化，使其为长度不变模为1的向量
                // cameraOS_Z = normalize(cameraOS_Z);
                // //假设相机空间下的Y轴向量为(0,1,0)
                // float3 cameraOS_Y = float3(0, 1, 0);
                // //利用叉积求出相机空间下的X轴向量
                // float3 cameraOS_X = normalize(cross(cameraOS_Z, cameraOS_Y));
                // //再次利用叉积求出相机空间下的Y轴向量
                // cameraOS_Y = cross(cameraOS_X, cameraOS_Z);
                // //通过向量与常数相乘来把顶点的X轴与Y对应到cameraOS的X与Y轴向上
                // float3 billboardPositionOS = cameraOS_X * v.vertex.x + cameraOS_Y * v.vertex.y;
                // o.vertex = UnityObjectToClipPos(billboardPositionOS);
               
				float3 upCamVec = normalize ( UNITY_MATRIX_V._m10_m11_m12 );
				float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
				float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
				float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
				v.vertex = mul( v.vertex , unity_ObjectToWorld );
				v.vertex = mul( v.vertex , rotationCamMatrix );
				v.vertex = mul( v.vertex , unity_WorldToObject );

				

			  o.posWS = mul(UNITY_MATRIX_M,v.vertex);

				o.colorVert = v.color;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               
                UNITY_SETUP_INSTANCE_ID( i );
                //根据相机的远近计算亮度
                float Distance = length(_WorldSpaceCameraPos-i.posWS);
                float colorScale = saturate((_Range-Distance)/_Range);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TintColor)*i.colorVert*1.1;
                return col*colorScale;
            }
            ENDCG
        }
    }
}
