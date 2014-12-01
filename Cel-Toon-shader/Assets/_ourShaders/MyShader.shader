Shader "Custom/MyShader" {
	//What i Need for the toon shader
	//We have a lighting equation for drawing each pixel
	//pixel_color = texture_map[(N dot L)]
	//Where N is the normal vector to the polygon and
	//L is the ray comming from the light source.
	//the dot product will give the cosine of the angle between the two vectors
	//Which is used to index the texture_map
	 
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert
		#include "UnityCG.glslinc"

		sampler2D _MainTex;
		

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
