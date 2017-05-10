Shader "Test/Depth_Test" {
	Properties
	{
		_DistanceFactor("Distance factor", float) = 4
		_DistanceExp ("Distance exponent", float) = 0.15
		[MaterialToggle] Perspective("Use perspective", Float) = 0
	}

	Subshader
	{
		// ForwardAdd needed to get the world space position from point lights
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"CanUseSpriteAtlas" = "True"
		}

		Pass
		{

			Name "BASE"

			ZWrite Off
			Cull Off
			Lighting Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#pragma multi_compile DUMMY PERSPECTIVE
	#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				float4 projPos : TEXCOORD1;
			};

			float _DistanceFactor;
			float _DistanceExp;
			uniform sampler2D _CameraDepthTexture;

			v2f vert(appdata_t IN)
			{
				v2f OUT;

				OUT.vertex = UnityObjectToClipPos(IN.vertex);
		#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap(OUT.vertex);
		#endif

				OUT.projPos = ComputeScreenPos(OUT.vertex);
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
#ifdef PERSPECTIVE_ON
				float depth = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos))).r * _DistanceFactor;
#else
				float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)).r * _DistanceFactor;
#endif
				depth = pow(depth, _DistanceExp);

				return float4(0, depth, 0, 1);
			}

			ENDCG
		}
	}

}
