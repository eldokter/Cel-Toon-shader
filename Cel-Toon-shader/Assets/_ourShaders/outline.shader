Shader "custom/toonOutline"
{
    Properties 
    {
		_MainTex ("Detail", 2D) = "white" {}        								//2
		_ToonShade ("Shade", 2D) = "white" {}  										//3
		_OutlineColor ("Outline Color", Color) = (0.0,0.0,0.0,1.0)					//10
		_Outline ("Outline width", Float) = 0.5									//11
		[MaterialToggle(_ASYM_ON)] _Asym ("Enable Asymmetry", Float) = 0        	//12
		_Asymmetry ("OutlineAsymmetry", Vector) = (0.0,0.25,0.5,0.0)     			//13
		[MaterialToggle(_TRANSP_ON)] _Trans ("Enable Transparency", Float) = 0   	//14
		[Enum(TRANS_OPTIONS)] _TrOp ("Transparency mode", Float) = 0                //15
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5                                  //16
    }
 
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		LOD 250 
        Lighting Off
        Fog { Mode Off }
        
        UsePass "Custom/test-mat-2/TESTMAT"
        	
        Pass
        {
            Cull Front
            ZWrite On
            CGPROGRAM
			#include "UnityCG.cginc"
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma glsl_no_auto_normalization
            #pragma vertex vert
 			#pragma fragment frag
			
            struct appdata_t 
            {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
			};

            fixed _Outline;

            
            v2f vert (appdata_t v) 
            {
                v2f o;
			    o.pos = v.vertex;
			    o.pos.xyz += v.normal.xyz *_Outline*0.01;
			    o.pos = mul(UNITY_MATRIX_MVP, o.pos);
			    return o;
            }
            
            fixed4 _OutlineColor;
            
            fixed4 frag(v2f i) :COLOR 
			{
		    	return _OutlineColor;
			}
            
            ENDCG
        }
    }
    Fallback "Diffuse"
}