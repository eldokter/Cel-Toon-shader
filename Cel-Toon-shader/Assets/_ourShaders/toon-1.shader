﻿Shader "ToonShader/toon-1" {
	Properties {
//		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Lit Color", Color) = (1,1,1,1)
		_UnlitColor("Unlit Color", Color) = (0.5,0.5,0.5,1)
		_DiffuseThreshold("Lighting Threshold", Range(-1.1,1))=0.1
		_Diffusion("Diffusion", Range(0,0.99)) = 0.0
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Range(0.5,1)) = 1
		_SpecDiffusion("Specular Diffusion", Range(0,0.99)) = 0.0
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_OutlineThickness("Outline Thickness", Range(0,1)) = 0.1
		_OutlineDiffusion("Outline Diffusion", Range(0,1)) = 0.0
	}
	SubShader {
	
		Pass{
		Tags{"Lightmode"="ForwardBase"}
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

//user-defined vars

		uniform fixed4 _Color;
		uniform fixed4 _UnlitColor;
		uniform fixed _DiffuseThreshold;
		uniform fixed _Diffusion;
		uniform fixed4 _SpecColor;
		uniform fixed _Shininess;
		uniform half _SpecDiffusion;
		uniform fixed4 _OutlineColor;
		uniform fixed _OutlineThickness;
		uniform fixed _OutlineDiffusion;
//		sampler2D _MainTex;

//unity-defined vars
		uniform half4 _LightColor0;

//base input structs
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

//vertex function	
		
		vertexOutput vert(vertexInput v){
			vertexOutput o;
			
			//normal direction
			o.normalDir = normalize(mul(half4(v.normal,0.0),_World2Object).xyz);
			
			//unity transform position
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			//world position
			half4 posWorld = mul(_Object2World, v.vertex);
			//view direction
			o.viewDir = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
			//Light direction
			half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
			o.lightDir = fixed4(
				normalize (lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)),
				lerp(1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w)
				);
			return o;
		}
		
		//fragment function
		fixed4 frag(vertexOutput i):COLOR
		{
			//Lighting
			//dot product
			fixed nDotL = saturate(dot(i.normalDir, i.lightDir.xyz));
		
		
		
		//calculate cut-offs (masking) and ambient light manually
			fixed diffuseCutoff = saturate((max(_DiffuseThreshold, nDotL) - _DiffuseThreshold) * pow( (2-_Diffusion),10 ));
			fixed specularCutoff = saturate((max(_Shininess, dot(reflect(-i.lightDir.xyz, i.normalDir), i.viewDir))-_Shininess)*pow((2-_SpecDiffusion),10));
			// Outlines Calculation
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
	//FallBack "Specular"
	}
}






















