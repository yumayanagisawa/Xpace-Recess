//https://www.shadertoy.com/view/MlBSzR
Shader "Unlit/Glitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		iChannel0("Texture", 2D) = "white" {}
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

            fixed4 frag (v2f i) : SV_Target
            {
				/*
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
				*/

				float2 uv = i.uv;// fragCoord.xy / iResolution.xy;
				//    uv.t = 1.0 - uv.t;

				float x = uv.x;// s;
				float y = uv.y;// t;

				//
				//float glitchStrength = (iMouse.y + 55.55) / iResolution.y * 5.0;
				float glitchStrength = (_ScreenParams.y * 0.4 + (sin(_Time.y) * 55.5)) / _ScreenParams.y * 5.0;



				// get snapped position
				float psize = 0.04 * glitchStrength;
				float psq = 1.0 / psize;

				float px = floor(x * psq + 0.5) * psize;
				float py = floor(y * psq + 0.5) * psize;

				float4 colSnap = tex2D(iChannel0, float2(px, py));

				float lum = pow(1.0 - (colSnap.r + colSnap.g + colSnap.b) / 3.0, glitchStrength); // remove the minus one if you want to invert luma



				// do move with lum as multiplying factor
				float qsize = psize * lum;

				float qsq = 1.0 / qsize;

				float qx = floor(x * qsq + 0.5) * qsize;
				float qy = floor(y * qsq + 0.5) * qsize;

				float rx = (px - qx) * lum + x;
				float ry = (py - qy) * lum + y;

				return tex2D(iChannel0, float2(rx, ry));
            }
            ENDCG
        }
    }
}
