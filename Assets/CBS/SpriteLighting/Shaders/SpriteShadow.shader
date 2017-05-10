Shader "Custom/Sprite Shadow" {
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_ShadowColor ("Shadow Color", Color) = (0.0, 0.0, 0.0, 0.5)
		_PerspectiveFactor ("Perspective effect", float) = 5
		_DistanceFactor ("Distance Factor", float) = 4
		_ShadowDepth ("Shadows Depth", float) = 0.15
		_DepthFactor ("Depth factor", float) = 2
		_DepthPower ("Depth exp factor", float) = 5
	}
	
	Subshader
	{
		// ForwardAdd needed to get the world space position from point lights with _WorldSpaceLightPos0
		Tags
		{ 
			"Queue"="Transparent-50" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent"
			"CanUseSpriteAtlas"="True"
			"LightMode"="ForwardAdd"
		}
		Pass
		{
			Name "BASE"
			
			ZWrite Off
			// Culling off, so it gets renderer even when it is facing away from the camera
			Cull Off
			Lighting Off
			Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				float2 texcoord  : TEXCOORD0;
				half4 color   : COLOR;
				float4 projPos : TEXCOORD1;
			};
			
			float4 lightDirection;
			half _PerspectiveFactor;
			half4 _ShadowColor;
			half _ShadowDepth;
			half _DistanceFactor;
			half _DepthFactor;
			half _DepthPower;
			uniform sampler2D _CameraDepthTexture;
			sampler2D _MainTex;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				
				float4 lightPos = _WorldSpaceLightPos0;
				// Convert to object space same as IN.vertex, so direction calculation gives valid result
				lightPos = mul(unity_WorldToObject, lightPos);

				lightDirection = (IN.vertex - lightPos) *_DistanceFactor;
				// As it is for 2D, it is placed at the same z as the vertex
				lightDirection.z = 0;
				
				// Recycle the lightPosition to calculate the vertex position
				lightPos = IN.vertex + lightDirection;
				lightPos.z += _ShadowDepth;

				half distance = clamp(length(lightDirection), 1, _PerspectiveFactor);
				
				OUT.vertex = UnityObjectToClipPos(lightPos * distance);
#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap(OUT.vertex);
#endif
				OUT.projPos = ComputeScreenPos(OUT.vertex);

				// Color is modified with distance to light
				OUT.color = _ShadowColor * (1 - smoothstep(1, _PerspectiveFactor, dot(distance, distance)));
				OUT.texcoord = IN.texcoord;

				return OUT;
			}


			fixed4 frag(v2f IN) : SV_Target
			{
				// Extract depth, and use it as factor to the alpha component
#ifdef PERSPECTIVE_ON
				// Converts the depth to linear range (perspective cameras)
				half depth = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos))).r * _DepthFactor;
#else
				half depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)).r * _DepthFactor;
#endif
				depth = saturate(pow(depth, _DepthPower));

				fixed4 c = tex2D(_MainTex, IN.texcoord) * IN.color;
				// Non-linear alpha factoring with depth
				c.a *= depth * depth;

				return c;
			}
		ENDCG
		}
	}
	
}
