﻿Shader "Custom/Planet" {
	Properties {
		_Color("Color", Color) = (1,1,1,1)
		_Color2("Color2", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Height("Height", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Shape("Shape", Vector) = (0,0,0,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _Color2;
		float4 _Shape;
		sampler2D _AudioTex;
		sampler2D _Height;

		void vert(inout appdata_full v) {
			float height = tex2Dlod(_Height, float4(v.texcoord.xy, 1., 1.)).r;
			float3 p = v.vertex.xyz;
			float f = sin(v.texcoord.x*5. + cos(v.texcoord.y*15.+v.texcoord.x*10.+_Time.y*1.5707)*3.)*.5 + .5;
			f = lerp(f, sin(v.texcoord.x*20.+sin(v.texcoord.y*5.)*2. + _Time.y*1.5707)*.5 + .5, .5);
			float g = tex2Dlod(_AudioTex, float4(height, 0., 1., 1.)).r;
			p *= 1.+ max(0,-v.normal.z)*_Shape.x*g;
			p *= (1.+height*_Shape.z);
			v.vertex.xyz = p;
			//v.texcoord.xy += float2(sin(_Time.y*1.5707), cos(_Time.y*1.5707))*g*_Shape.y;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			//IN.uv_MainTex.x += _Shape.y;
			//IN.uv_MainTex.x = modf(IN.uv_MainTex.x, 1.);
			// Albedo comes from a texture tinted by color
			float height = tex2D(_Height, IN.uv_MainTex).r;

			//float f = sin(IN.uv_MainTex.x*5. + cos(IN.uv_MainTex.y*15. + IN.uv_MainTex.x*10. + _Time.y*1.5707)*3.)*.5 + .5;
			//f = lerp(f, sin(IN.uv_MainTex.x*20. + sin(IN.uv_MainTex.y*5.)*2. + _Time.y*1.5707)*.5 + .5, .5);
			float f = tex2D(_AudioTex, float2(1.0-height, 0.)).r;
			f = pow(f, _Shape.w);
			fixed4 c = 1.0-(1.0-pow(tex2D(_MainTex, IN.uv_MainTex).r, 2.) )* lerp(_Color, _Color2, f);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
