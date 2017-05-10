// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Retro/Flat Color Additive" {
	Properties {
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	}
	SubShader {
 		Tags { "Queue"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" }
        
        Pass {
            Lighting Off
            Zwrite Off
            Blend SrcAlpha One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
 
            #include "UnityCG.cginc"
 
            fixed4 _TintColor;
           
            // Struct Input || VertOut
            struct appdata {
                half4 vertex : POSITION;
                fixed4 color : COLOR;
            };
           
            //VertIn
            struct v2f {
                half4 pos : POSITION;
                fixed4 color : COLOR;
            };
 
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.color = v.color * _TintColor;
 
                return o;
            }
 
            fixed4 frag (v2f i) : COLOR
            {
                return i.color;
            }
            
            ENDCG  
        }
		
	} 
	FallBack "Diffuse"
}