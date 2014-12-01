Shader "Custom/test-mat-2" {
   Properties {
//      _Color ("Diffuse Color", Color) = (1,1,1,1) 
//      _UnlitColor ("Unlit Diffuse Color", Color) = (0.5,0.5,0.5,1) 
//      _DiffuseThreshold ("Threshold for Diffuse Colors", Range(0,1)) 
//         = 0.1 
      _OutlineColor ("Outline Color", Color) = (0,0,0,1)
      _LitOutlineThickness ("Lit Outline Thickness", Range(0,1)) = 0.1
      _UnlitOutlineThickness ("Unlit Outline Thickness", Range(0,1))  = 0.4
//      _SpecColor ("Specular Color", Color) = (1,1,1,1) 
//      _Shininess ("Shininess", Float) = 10
      
//      _Outline ("Outline width", Float) = 0.01
//      		_Diffusion("Diffusion", Range(0,0.99)) = 0.0
//      		_SpecDiffusion("Specular Diffusion", Range(0,0.99)) = 0.0
//      		_OutlineThickness("Outline Thickness", Range(0,1)) = 0.1
//      		_OutlineDiffusion("Outline Diffusion", Range(0,1)) = 0.0
   }
SubShader {
    Tags{"LightMode" = "ForwardBase"}
    Pass {
    
    	Name "TESTMAT"
    
        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"
        
        
		uniform fixed4 _Color;
		uniform fixed4 _UnlitColor;
		uniform fixed _DiffuseThreshold;
		uniform fixed4 _OutlineColor;
		uniform fixed4 _SpecColor;
		uniform fixed _Shininess;
		uniform fixed _LitOutlineThickness;
		uniform fixed _UnlitOutlineThickness;
		
		uniform float4 _LightColor0; 

//		uniform fixed _Diffusion;
//		uniform half _SpecDiffusion;
//		uniform fixed _OutlineThickness;
//		uniform fixed _OutlineDiffusion;

		fixed _Outline;


        struct vertexOutput {
            float4 pos : SV_POSITION;
            float3 color : COLOR0;
            fixed3 normalDir: TEXCOORD1;
			float3 viewDir:TEXCOORD2;
			float3 lightDir:TEXCOORD0;
        };
        
        vertexOutput vert (appdata_base input) {
            vertexOutput o;

            o.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            //o.normalDir = normalize(mul(half4(input.normal,0.0),_World2Object).xyz);
            //o.color = float3(1.0,0.5,0.1);
            //input.normal * 0.5 + 0.5;
            //float4(input.vertex.xyz,1.0) + float4(0.5,0.5,0.5,0.0);
//            half4 posWorld = mul(_Object2World, input.vertex);
//			o.viewDir = normalize(_WorldSpaceCameraPos.xyz * posWorld.xyz);
			//half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
			
//			o.lightDir = fixed4(
//				normalize (lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)),
//				lerp(1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w)
//				);
			
			o.lightDir = ObjSpaceLightDir(input.vertex);
			o.normalDir = input.normal;

            return o;
        }
        
        float4 frag (vertexOutput i) : COLOR { 
            
            float3 N = normalize(i.normalDir);
            float3 L = normalize(i.lightDir);
           
            if(dot(N,L) < .5 && dot(N,L) > .0)
                return float4(.6,.6,.6,1);
            else if(dot(N,L) > .5) //60 degrees
                return float4(1,1,1,1);
        	else if(dot(N,L) < .0) //90-270 degrees
        		return float4(.0,.0,.0,1);
            else
                return float4(L.x,L.y,L.z,1);

            if (dot(i.viewDir, i.normalDir) < lerp(_UnlitOutlineThickness, _LitOutlineThickness, max(0.0, dot(i.normalDir, i.lightDir))))
            {
               return float4(_LightColor0.rgb * _OutlineColor.rgb,1.0); 
            }


        }
        
        ENDCG
        
    }
    
}

}
