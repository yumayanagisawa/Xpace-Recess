//https://www.shadertoy.com/view/4dsGR8
Shader "Unlit/Normal Map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		iChannel0("iChannel0", 2D) = "white" {}
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
				i.uv.y = 1.0 - i.uv.y;
				float2 uv = i.uv;// fragCoord.xy / iResolution.xy;
				uv.y = 1.0 - uv.y;

				float x = 1.;
				float y = 1.;

				float M = abs(tex2D(iChannel0, uv + float2(0., 0.) / _ScreenParams.xy).r);
				float L = abs(tex2D(iChannel0, uv + float2(x, 0.) / _ScreenParams.xy).r);
				float R = abs(tex2D(iChannel0, uv + float2(-x, 0.) / _ScreenParams.xy).r);
				float U = abs(tex2D(iChannel0, uv + float2(0., y) / _ScreenParams.xy).r);
				float D = abs(tex2D(iChannel0, uv + float2(0., -y) / _ScreenParams.xy).r);
				float X = ((R - M) + (M - L))*.5;
				float Y = ((D - M) + (M - U))*.5;

				float strength = .01;
				float4 N = float4(normalize(float3(X, Y, strength)), 1.0);
				//	vec4 N = vec4(normalize(vec3(X, Y, .01))-.5, 1.0);

				//vec4 col = 
				return float4(N.xyz * 0.5 + 0.5,1.);

            }
            ENDCG
        }
    }
}
