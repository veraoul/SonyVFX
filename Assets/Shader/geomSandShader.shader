﻿Shader "YanCheZuo/geomSandShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed", Float) = -3
        _AccelerationValue("AccelerationValue", Float) = 10
        _FloorY("Floor Y",Float) = -0.5
        _ExploSpeed("ExploSpeed",Float) = 0.4           // 风化速度
        _Color("Color",Color) = (1,1,1,1)
        _StartTime("Start Time",Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Tags { "RenderPipeline" = "HDRenderPipeline" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct g2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            float _Speed;
            float _AccelerationValue;
            float _StartTime;
            float _FloorY;
            float _ExploSpeed;

            v2g vert (appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = v.uv;
                return o;
            }

            [maxvertexcount(1)]
            void geom(triangle v2g IN[3], inout PointStream<g2f> pointStream)
            {
                g2f o;

                float3 v1 = IN[1].vertex - IN[0].vertex;
                float3 v2 = IN[2].vertex - IN[0].vertex;

                float3 norm = normalize(cross(v1, v2));

                float3 tempPos = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;

                float realTime = _Time.y - _StartTime;


                // 修改
                float3 worldPos = mul(unity_ObjectToWorld, tempPos).xyz;            // 获取顶点的世界坐标
                worldPos.y -= _Speed * realTime + .5 * _AccelerationValue * pow(realTime, 2);

                if(_FloorY<worldPos.y)
                {
                    tempPos -= norm * (_ExploSpeed * realTime);
                    worldPos = mul(unity_ObjectToWorld, tempPos).xyz;           // 再算一次顶点的世界坐标
                    worldPos.y -= _Speed * realTime + .5 * _AccelerationValue * pow(realTime, 2);
                }
                else
                {
                    worldPos.y = max(_FloorY, worldPos.y);
                }

                tempPos = mul(unity_WorldToObject, worldPos).xyz;

                o.vertex = UnityObjectToClipPos(tempPos);

                o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                pointStream.Append(o);
            }

            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}