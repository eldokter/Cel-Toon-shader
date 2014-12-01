Shader "Custom/testShader" {

	SubShader {
		Pass{
			CGPROGRAM
	
		#pragma vertex vert
		#pragma fragment frag
		
		struct vertexOutput{
			float4 position: SV_POSITION;
			float4 color: TEXCOORD0;
		};
		
		vertexOutput vert(float4 vertexPos : POSITION)
		{
			vertexOutput output;
			output.position = mul(UNITY_MATRIX_MVP, vertexPos);
			output.color = vertexPos + float4 (0.5, 0.5, 0.5, 0.0);
			return output;
		}

		 float4 frag(vertexOutput input) : COLOR
         {
            return input.color;
         }
		
		
		
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
