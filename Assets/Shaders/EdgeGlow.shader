//https://www.shadertoy.com/view/Mdf3zr
Shader "Unlit/EdgeGlow"
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
			float d;

			float lookup(float2 p, float dx, float dy)
			{
				float2 uv = (p.xy + float2(dx * d, dy * d)) / _ScreenParams.xy;
				float4 c = tex2D(iChannel0, uv.xy);

				return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				/*
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
				*/

				d = sin(_Time.y * 5.0)*0.5 + 1.5; // kernel offset
				float2 p = i.uv * _ScreenParams.xy;

				// simple sobel edge detection
				float gx = 0.0;
				gx += -1.0 * lookup(p, -1.0, -1.0);
				gx += -2.0 * lookup(p, -1.0, 0.0);
				gx += -1.0 * lookup(p, -1.0, 1.0);
				gx += 1.0 * lookup(p, 1.0, -1.0);
				gx += 2.0 * lookup(p, 1.0, 0.0);
				gx += 1.0 * lookup(p, 1.0, 1.0);

				float gy = 0.0;
				gy += -1.0 * lookup(p, -1.0, -1.0);
				gy += -2.0 * lookup(p, 0.0, -1.0);
				gy += -1.0 * lookup(p, 1.0, -1.0);
				gy += 1.0 * lookup(p, -1.0, 1.0);
				gy += 2.0 * lookup(p, 0.0, 1.0);
				gy += 1.0 * lookup(p, 1.0, 1.0);

				// hack: use g^2 to conceal noise in the video
				float g = gx * gx + gy * gy;
				float g2 = g * (sin(_Time.y) / 2.0 + 1.5);

				return float4(0.0, g, g2, 1.0);
            }
            ENDCG
        }
    }
}
