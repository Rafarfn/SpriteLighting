
Shader "Custom/Entities"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
	}


	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
	
		// This is based on the code from the Sprite/Default shader
		Pass
		{
			Name "BASE"

			Cull Off
			Lighting Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata_t
			{
				float4 vertex   : POSITION;
				half4 color		: COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
			};
			
			fixed4 _Color;
			float4 _MainTex_ST;
			sampler2D _MainTex;

			
			v2f vert (appdata_t v)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(v.vertex);
				OUT.texcoord = TRANSFORM_TEX (v.texcoord, _MainTex);

			#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
			#endif

				OUT.color = v.color * _Color;

				return OUT;
			}

			
			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, IN.texcoord) * IN.color;

				return c;
			}
		ENDCG
		}


		Pass
		{
			Name "FORWARDADD"

			Cull Off
			Lighting Off
			ZWrite Off
			Blend One One

			Tags { "LightMode" = "ForwardAdd" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				float2 texcoord  : TEXCOORD0;
				half3 lightColorAttenuated	: COLOR;	// Rim light color attenuated with distance
				half3 lightDir : TEXCOORD1;				// Light direction
				float3x3 rotation : TEXCOORD2;			// Rotation matrix
			};

			float4 _MainTex_ST;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			v2f vert(appdata_full v)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(v.vertex);
				OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

	#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap(OUT.vertex);
	#endif

				// Light direction in that vertex
				OUT.lightDir = ObjSpaceLightDir(v.vertex);

				// Calculate the rotation matrix per-vertex instead of per-pixel in fragment shader later on
				// Should not make a difference for small/mid-sized sprites
				TANGENT_SPACE_ROTATION;
				OUT.rotation = rotation;

				half distance = length(OUT.lightDir);
				OUT.lightDir = normalize(OUT.lightDir);

				// Light's linear attenuation
				half atten = distance;
				OUT.lightColorAttenuated = _LightColor0.rgb / atten;

				return OUT;
			}


			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, IN.texcoord);

				if (c.a == 0)
				{
					discard;
				}
				
				// We are adding in this pass, so defaults to black
				c = fixed4(0, 0, 0, 0);

				fixed2 rim = fixed2(0, 0);
				fixed addedAlpha = 0;

				float2 aux = _MainTex_TexelSize.xy;
				fixed value = 0;
				aux.y = 0;
				value = tex2D(_MainTex, IN.texcoord + aux).a;
				rim.x -= value;
				addedAlpha += value;
				value = tex2D(_MainTex, IN.texcoord - aux).a;
				rim.x += value;
				addedAlpha += value;

				aux = _MainTex_TexelSize.xy;
				aux.x = 0;
				value = tex2D(_MainTex, IN.texcoord + aux).a;
				rim.y -= value;
				addedAlpha += value;
				value = tex2D(_MainTex, IN.texcoord - aux).a;
				rim.y += value;
				addedAlpha += value;

				// Check if any of the neighbours is transparent
				if (addedAlpha < 4)
				{
					// Transform both light's direction and rim's direction to the same space (tangent space)
					fixed3 light = mul(IN.rotation, IN.lightDir);
					c.rgb = IN.lightColorAttenuated * saturate(dot(light.xy, rim.xy));
				}

				return c;
			}
			ENDCG
		}


	}

	Fallback "Transparent/VertexLit"
}

