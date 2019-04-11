Shader "Unlit/Canvas"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_MosaicTex("Mosaic", 2D) = "white" {}
		_EdgeGlowTex("Edge Glow", 2D) = "white" {}
		_GlitchTex("Glitch", 2D) = "white" {}
		_ChromaticTex("Chromatic", 2D) = "white" {}
		_NormalMapTex("Normal Map", 2D) = "white" {}
		_RaindropTex("Raindrop", 2D) = "white" {}
		_HalftoneTex("Halftone", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			sampler2D _MosaicTex;
			sampler2D _EdgeGlowTex;
			sampler2D _GlitchTex;
			sampler2D _ChromaticTex;
			sampler2D _NormalMapTex;
			sampler2D _RaindropTex;
			sampler2D _HalftoneTex;

			float4 circle(float2 p, float2 center, float radius, float3 insideCol, float3 outsideCol)
			{
				return lerp(float4(outsideCol, 0), float4(insideCol, 1), smoothstep(radius + 0.02, radius - 0.02, length(p - center)));
			}

			float4 rectangle(float2 p, float2 center, float radius, float3 insideCol, float3 outsideCol)
			{
				return lerp(float4(outsideCol, 0), float4(insideCol, 1), smoothstep(radius + 0.02, radius - 0.02, length(p - center)));
			}

            fixed4 frag (v2f i) : SV_Target
            {
				i.uv.x = 1 - i.uv.x;
                // sample the texture
                fixed4 col = float4(0,0,0,0);
				float2 uv2 = float2(i.uv.x - 0.1, i.uv.y);
				if (i.uv.x < 0.5) {
					if (i.uv.y < 0.5)
					{
						if (i.uv.x < 0.25)
						{
							col = tex2D(_RaindropTex, i.uv);
						}
						else {
							col = tex2D(_MosaicTex, i.uv);
						}
						
					}
					else if(i.uv.y < 0.75)
					{
						col = tex2D(_NormalMapTex, i.uv);
					}
					else {
						if (i.uv.x < 0.25)
						{
							col = tex2D(_HalftoneTex, i.uv);
						}
						else {
							col = tex2D(_EdgeGlowTex, i.uv);
						}
					}	
				}
				else if (i.uv.x < 0.6) 
				{
					float2 customuv = float2(0.50, i.uv.y);
					col = tex2D(_ChromaticTex, customuv);
				}
				else {
					
					if (i.uv.y < 0.5)
					{
						col = tex2D(_GlitchTex, uv2);
					}
					else {
						col = tex2D(_ChromaticTex, uv2);
					}
					//col = tex2D(_GlitchTex, i.uv);
				}
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
				float2 centerPos = float2(0.75, 0.27);
				//float3 insideCol = tex2D(_EdgeGlowTex, uv2).rgb;
				float3 insideCol = tex2D(_NormalMapTex, i.uv).rgb;
				float3 edgeCol = tex2D(_EdgeGlowTex, i.uv).rgb;
				//uv2.y *= _ScreenParams.y / _ScreenParams.x;
				//col = circle(uv2, centerPos, 0.07, insideCol, col.rgb);
				if (i.uv.x < 0.5)
				{
					float2 rectPos = float2(i.uv.x, 0.55);
					col = rectangle(i.uv, rectPos, 0.1, insideCol, col.rgb);
				}
				if (i.uv.y < 0.75 && 0.46 < i.uv.y)
				{
					float2 rectPos = float2(0.45, i.uv.y);
					col = rectangle(i.uv, rectPos, 0.05, insideCol, col.rgb);
				}
				
                return col;
            }
            ENDCG
        }
    }
}
