Shader "ToonShader/toon-2" { 

	
	Properties {
	
		_DiffuseThreshold("Lighting Threshold", Range(-1.1,1))=0.1
		_Diffusion("Diffusion", Range(0,0.99)) = 0.0
		_Shininess("Shininess", Range(0.5,1)) = 1
		_SpecDiffusion("Specular Diffusion", Range(0,0.99)) = 0.0
		_OutlineThickness("Outline Thickness", Range(0,1)) = 0.1
		_OutlineDiffusion("Outline Diffusion", Range(0,1)) = 0.0		
		
			
		_Color ("Lit Color", Color) = (1,1,1,1)
		_UnlitColor("Unlit Color", Color) = (0.5,0.5,0.5,1)
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		
	}
	SubShader { 
		Pass{	
		Tags{"Lightmode"="ForwardBase"}
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
	
		uniform fixed _DiffuseThreshold;
		uniform fixed _Diffusion;
		uniform fixed _Shininess;
		uniform fixed _OutlineThickness;
		uniform fixed _OutlineDiffusion;
		uniform half _SpecDiffusion;
		
	
		uniform fixed4 _Color;
		uniform fixed4 _UnlitColor;
		uniform fixed4 _SpecColor;
		uniform fixed4 _OutlineColor;



		uniform half4 _LightColor0;



		struct vertexInput {
			half4 vertex:POSITION;
			half3 normal:NORMAL;
		};

		struct vertexOutput{
			half4 pos:SV_POSITION;
			fixed3 normalDir: TEXCOORD0;
			fixed4 lightDir:TEXCOORD1;
			fixed3 viewDir:TEXCOORD2;
		};
		
		vertexOutput vert(vertexInput v){
			vertexOutput o;
			
			o.normalDir = normalize(mul(half4(v.normal,0.0),_World2Object).xyz);
			
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			half4 posWorld = mul(_Object2World, v.vertex);
			
			o.viewDir = normalize(_WorldSpaceCameraPos.xyz * posWorld.xyz);
			half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
			o.lightDir = fixed4(
				normalize (lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)),
				lerp(1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w)
				);
			return o;
		}
		
		fixed4 frag(vertexOutput i):COLOR
		{
			fixed nDotL = saturate(dot(i.normalDir, i.lightDir.xyz));
		
			fixed diffuseCutoff = saturate((max(_DiffuseThreshold, nDotL) - _DiffuseThreshold) * pow( (2-_Diffusion),10 ));
			fixed specularCutoff = saturate((max(_Shininess, dot(reflect(-i.lightDir.xyz, i.normalDir), i.viewDir))-_Shininess)*pow((2-_SpecDiffusion),10));
			fixed outLineStrength = saturate( (dot( i.normalDir, i.viewDir) - _OutlineThickness) * pow((2-_OutlineDiffusion), 10) + _OutlineThickness);
			fixed3 outLineOverlay = (_OutlineColor.xyz * (1-outLineStrength)) + outLineStrength;
			
			
			fixed3 ambientLight = (1-diffuseCutoff) * _UnlitColor.xyz;
			fixed3 diffuseReflection = (1-specularCutoff) * _Color.xyz * diffuseCutoff;
			fixed3 specularReflection = _SpecColor.xyz * specularCutoff;
			
			
		
			fixed3 lightFinal = (ambientLight + diffuseReflection) * outLineOverlay + specularReflection;
			
		return fixed4(lightFinal, 1);
		}
								
		
		ENDCG
		
	} 
	
	}
	FallBack "Specular"
}






















