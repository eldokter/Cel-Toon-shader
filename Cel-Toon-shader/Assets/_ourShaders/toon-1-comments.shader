Shader "ToonShader/toon-1" { //Shader command contains a string with the unique shader name and "/" character is used for simulating folder structure in Unity
//Shader is the root command of a shader file. Each file must define one (and only one) Shader. It specifies how any objects whose material uses this shader are rendered.
//	
	
	Properties {
	//The Properties block in the shader file defines a list of parameters to be set in Unity’s material inspector
	//Each property inside the shader is referenced by name (here it starts with underscore), and will show up in material inspector as display name
	//The default value is given after equals sign.
	//These are the values that are transferred from the application to the shader
	
	//Float range properties: a float property, represented as a slider from min to max in the inspector
	//Property type is Range
		
		_DiffuseThreshold("Lighting Threshold", Range(-1.1,1))=0.1 //controls the line between our shader
		_Diffusion("Diffusion", Range(0,0.99)) = 0.0
		_Shininess("Shininess", Range(0.5,1)) = 1
		_SpecDiffusion("Specular Diffusion", Range(0,0.99)) = 0.0
		_OutlineThickness("Outline Thickness", Range(0,1)) = 0.1
		_OutlineDiffusion("Outline Diffusion", Range(0,1)) = 0.0		
		
	//Color properties
	//Property type is Color
			
		_Color ("Lit Color", Color) = (1,1,1,1)
		_UnlitColor("Unlit Color", Color) = (0.5,0.5,0.5,1)
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		
	}
	SubShader { 
	//Each shader is comprised of a list of sub-shaders. When loading a shader, Unity will go through the list of subshaders, 
	//and pick the first one that is supported by the end user’s machine.
	//There should be at least one SubShader defined. If no subshaders are supported, Unity will try to use fallback shader.
	//As you can see, we have one SubShader here. If it fails, Fallback shader will be used.
		Pass{	
		//The Pass block causes the geometry of an object to be rendered once. 
		//Pass represents an execution of the Vertex and Fragment code for the same object rendered with the Material of the Shader
		Tags{"Lightmode"="ForwardBase"}
		//Tags are name/value strings that communicate Pass’ intent to the rendering engine.
		//Passes use tags to tell how and when they expect to be rendered to the rendering engine.
		//Here, LightMode tag defines Pass’ role in the lighting pipeline. And we need it, since it is not a surface shader, so
		//we need to take care of details manually (this is a vertex/fragment shader).
		
		//Here Lightmode is set to ForwardBase, because we use Forward rendering; Thus, ambient, main directional light and vertex/SH lights are applied.
		
		//The whole Cg snippet is written between CGPROGRAM and ENDCG keywords.These directives define in ShaderLab the language used for the shader.
		CGPROGRAM
		//These are the compilation directives for this Cg snippet given as #pragma statements;
		//Cg snippets are compiled into low-level shader assembly by the Unity editor, 
		//and the final shader that is included in the game’s data files only contains this low-level assembly.
		#pragma vertex vert
		//Tells that the code contains a vertex program in the given function (vert here)
		//In other words, this directive indicates that vert function should be compiled as the vertex shader
		#pragma fragment frag
		//Tells that the code contains a fragment program in the given function (frag here).
		//In other words, this directive indicates that frag function should be compiled as the fragment shader

//Following the compilation directives is just plain Cg code. So, the Cg code starts here
//Here we have user-defined variables
//Since we want to access the properties from the Properties block in a shader program, we declare Cg/HLSL variables with the same name and a matching type
//Thus, we declare the shader properties for access in Cg/HLSL code as follows:

	//Range properties in ShaderLab map to Cg/HLSL float, half or fixed variable types

		uniform fixed _DiffuseThreshold;
		uniform fixed _Diffusion;
		uniform fixed _Shininess;
		uniform fixed _OutlineThickness;
		uniform fixed _OutlineDiffusion;
		uniform half _SpecDiffusion;
		
	//Color properties in ShaderLab map to Cg/HLSL ffloat4, half4 or fixed4 variable types
	
		uniform fixed4 _Color;
		uniform fixed4 _UnlitColor;
		uniform fixed4 _SpecColor;
		uniform fixed4 _OutlineColor;

	//To use the properties values defined into the shader, we use uniform keyword when declaring the variables, so that
	//the compiler identifies the variables as external values which should be transferred to the shader in each execution
	//(although it is not necessary here)

//unity-defined vars
		uniform half4 _LightColor0;



//Semantics is a special clause of Cg to define the default input values of a fragment/vertex Shader
//

//Here's our vertex input structs
//For each vertex input parameter, we declare a semantic (this is a must) to specify how the parameter relates to data in the fixed-function pipeline
//Specifying semantics for input parameters makes it possible for our API to provide the appropriate data for these parameters
//SEMANTICS are, in a sense, the glue that binds a Cg program to the rest of the graphics pipeline.
		struct vertexInput {
			half4 vertex:POSITION;
			half3 normal:NORMAL;
		}; //Here we have the built-in vertex input parameters (in Unity they require, besides semantics, certain names and types)
 //POSITION refers to the application-specified position assigned by the application when it sends a vertex to the GPU		


//NEW These are the data types that are part of Cg's Standard Library

//HERE we define the struct for vertex shader output to be passed as input to fragment shader
//WE declare one system-value semantics of vertices position and three sets of texture coordinates, indexed accordingly
		struct vertexOutput{
			half4 pos:SV_POSITION;
			fixed3 normalDir: TEXCOORD0;
			fixed4 lightDir:TEXCOORD1;
			fixed3 viewDir:TEXCOORD2;
		};

//vertex function	

//THE PARAMETER here is vertexInput struct, this tells the vertex processor to initialize the 
//parameters with the application-specified position and normal of every vertex processed by the function
//(as defined in the vertexInput struct)

////POSITION semantics is the clip-space position for the transformed vertex
		
		vertexOutput vert(vertexInput v){
			vertexOutput o;
			
			//normal direction
			o.normalDir = normalize(mul(half4(v.normal,0.0),_World2Object).xyz);
			
			//unity transform position
			//multiplying the 3D position with a Model-View-Projection matrix; This is the core of the vertex function, 
			//where a coordinate in 3D is projected into a 2D window
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			//world position
			half4 posWorld = mul(_Object2World, v.vertex);
			
			//view direction
			o.viewDir = normalize(_WorldSpaceCameraPos.xyz * posWorld.xyz);
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
		
		//the rest of pass setup goes here
	} 

	//The Fallback command is optionally used. at the end of the shader; it tells which shader should be used 
	//if no SubShaders from the current shader can run on user’s graphics hardware
	//Same effect can be reached when including all SubShaders from the fallback shader
	}
		FallBack "Specular"
}






















