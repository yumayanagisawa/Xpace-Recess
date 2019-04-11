//https://www.shadertoy.com/view/MlXfz8
Shader "Unlit/Chromatic Aberration"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		iChannel0("Chromatic", 2D) = "white" {}
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

			static const float amount = .015;
			static const float speed = 1.1;

            fixed4 frag (v2f i) : SV_Target
            {

				float2 uv = i.uv;// fragCoord.xy / iResolution.xy;
				float2 uvRed = uv;
				float2 uvBlue = uv;
				float s = abs(sin(_Time.y * speed)) * amount;
				uvRed.x += s;
				uvBlue.x -= s;

				float4 col = tex2D(iChannel0, uv);

				col.r = tex2D(iChannel0, uvRed).r;
				col.b = tex2D(iChannel0, uvBlue).b;
				return col;
            }
            ENDCG
        }
    }
}
