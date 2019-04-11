Shader "Unlit/Halftone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		iChannel0("Webcam", 2D) = "white" {}
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

			static const float PI = 3.1415926535897932384626433832795;
			static const float PI180 = float(PI / 180.0);

			float sind(float a)
			{
				return sin(a * PI180);
			}

			float cosd(float a)
			{
				return cos(a * PI180);
			}

			float added(float2 sh, float sa, float ca, float2 c, float d)
			{
				return 0.5 + 0.25 * cos((sh.x * sa + sh.y * ca + c.x) * d) + 0.25 * cos((sh.x * ca - sh.y * sa + c.y) * d);
			}

			sampler2D iChannel0;

            fixed4 frag (v2f i) : SV_Target
            {

				// Ported from my old PixelBender experiment
				// https://github.com/og2t/HiSlope/blob/master/src/hislope/pbk/fx/halftone/Halftone.pbk

				// Hold and drag horizontally to adjust the threshold

				float threshold = clamp(0.6, 0.0, 1.0);

				float ratio = _ScreenParams.y / _ScreenParams.x;
				float2 fragCoord = i.uv * _ScreenParams.xy;
				float coordX = fragCoord.x / _ScreenParams.x;
				float coordY = fragCoord.y / _ScreenParams.x;
				float2 dstCoord = float2(coordX, coordY);
				float2 srcCoord = float2(coordX, coordY / ratio);
				float2 rotationCenter = float2(0.5, 0.5);
				float2 shift = dstCoord - rotationCenter;

				static const float dotSize = 3.0;
				static const float angle = 45.0;

				float rasterPattern = added(shift, sind(angle), cosd(angle), rotationCenter, PI / dotSize * 680.0);
				float4 srcPixel = tex2D(iChannel0, srcCoord);

				float avg = 0.2125 * srcPixel.r + 0.7154 * srcPixel.g + 0.0721 * srcPixel.b;
				float gray = (rasterPattern * threshold + avg - threshold) / (1.0 - threshold);

				// uncomment to see how the raster pattern looks 
				// gray = rasterPattern;

				return float4(gray, gray, gray, 1.0);
            }
            ENDCG
        }
    }
}
