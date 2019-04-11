//https://www.shadertoy.com/view/MtfXRN
Shader "Unlit/Mosaic"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		iChannel0("iChannel", 2D) = "white" {}
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

			sampler2D iChannel0;
			#define USE_TILE_BORDER
            fixed4 frag (v2f i) : SV_Target
            {
				/*
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
				*/
				i.uv.y = 1 - i.uv.y;

				const float minTileSize = 12.0;
				const float maxTileSize = 64.0;// 32.0;
				const float textureSamplesCount = 3.0;
				const float textureEdgeOffset = 0.005;
				const float borderSize = 1.0;
				const float speed = 1.0;

				float time = pow(sin(_Time.y * speed), 2.0);
				float tileSize = minTileSize + floor(time * (maxTileSize - minTileSize));
				tileSize += fmod(tileSize, 2.0);
				float2 tileNumber = floor(i.uv * _ScreenParams.xy / tileSize);

				float4 accumulator = float4(0.0, 0.0, 0.0, 0.0);

				for (float y = 0.0; y < textureSamplesCount; ++y)
				{
					for (float x = 0.0; x < textureSamplesCount; ++x)
					{
						float2 textureCoordinates = (tileNumber + float2((x + 0.5) / textureSamplesCount, (y + 0.5) / textureSamplesCount)) * tileSize / _ScreenParams.xy;
						textureCoordinates.y = 1.0 - textureCoordinates.y;
						textureCoordinates = clamp(textureCoordinates, 0.0 + textureEdgeOffset, 1.0 - textureEdgeOffset);
						accumulator += tex2D(iChannel0, textureCoordinates);
					}
				}

				//fragColor
				float tsp = textureSamplesCount * textureSamplesCount;
				float4 col = accumulator / float4(tsp, tsp, tsp, tsp);

#if defined(USE_TILE_BORDER) || defined(USE_ROUNDED_CORNERS)
				float2 pixelNumber = floor(i.uv * _ScreenParams.xy - (tileNumber * tileSize));
				pixelNumber = fmod(pixelNumber + borderSize, tileSize);

#if defined(USE_TILE_BORDER)
				float pixelBorder = step(min(pixelNumber.x, pixelNumber.y), borderSize) * step(borderSize * 2.0 + 1.0, tileSize);
#else
				float pixelBorder = step(pixelNumber.x, borderSize) * step(pixelNumber.y, borderSize) * step(borderSize * 2.0 + 1.0, tileSize);
#endif
				col *= pow(col, float4(pixelBorder, pixelBorder, pixelBorder, pixelBorder));
#endif
				return col;
            }
            ENDCG
        }
    }
}
