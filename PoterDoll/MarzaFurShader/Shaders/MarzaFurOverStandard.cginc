#ifndef MZ_FUR_OVER_STANDARD
#define MZ_FUR_OVER_STANDARD


/*
this is overwriteing with UnityStandardInput.cginc

control for _MainTex 

*/


#ifndef UNITY_STANDARD_INPUT_INCLUDED
#define UNITY_STANDARD_INPUT_INCLUDED

#include "UnityCG.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityPBSLighting.cginc" // TBD: remove
#include "UnityStandardUtils.cginc"

//---------------------------------------
// Directional lightmaps & Parallax require tangent space too
#if (!DIRLIGHTMAP_OFF || _PARALLAXMAP)
	#define _TANGENT_TO_WORLD 1 
#endif

#if (_DETAIL_MULX2 || _DETAIL_MUL || _DETAIL_ADD || _DETAIL_LERP)
	#define _DETAIL 1
#endif

//---------------------------------------
half4		_Color;
half		_Cutoff;

sampler2D	_MainTex;
float4		_MainTex_ST;


//for overwrite 
half4		_OverColor;
sampler2D	_OverTex;
float4		_OverTex_ST;
float       _OnlyOverColor;

sampler2D	_DetailAlbedoMap;
float4		_DetailAlbedoMap_ST;

sampler2D	_DetailMask;
sampler2D	_DetailNormalMap;
half		_DetailNormalMapScale;

sampler2D	_SpecGlossMap;
sampler2D	_MetallicGlossMap;
half		_Metallic;
half		_Glossiness;

sampler2D	_OcclusionMap;
float4		_OcclusionMap_ST;
half		_OcclusionStrength;

sampler2D	_ParallaxMap;
half		_Parallax;
half		_UVSec;

half4 		_EmissionColor;
sampler2D	_EmissionMap;

 

#if defined(DIRECTIONAL) || defined (SHADOWS_OFF) || defined (LIGHTMAP_OFF) || defined (DIRLIGHTMAP_OFF) || defined( DYNAMICLIGHTMAP_OFF) || defined (SHADOWS_CUBE) || defined (SHADOWS_SOFT) || defined (_DETAIL_MULX2)
#else

	_OverTex    = _MainTex;
	_OverTex_ST = _MainT_ST;
	_OverColor  = _Color;
	_OnlyOverColor = 0;
#endif


//overwrite Tex
void BeginChangeMainTex(sampler2D inTex, float4 inTex_ST, float4 inColor){
	_OverTex = inTex;
	_OverTex_ST = inTex_ST;
	_OverColor = inColor;
}

//overwrite as color
void BeginChangeMainTex(float4 inColor){
	_OverColor = inColor;
	_OnlyOverColor = 1;
}


void EndChangeMainTex(){
	_OverTex = _MainTex;
	_OverTex_ST = _MainTex_ST;
	_OverColor = _Color;
	_OnlyOverColor = 0;
}


//-------------------------------------------------------------------------------------
// Input functions

struct VertexInput
{
	float4 vertex	: POSITION;
	half3 normal	: NORMAL;
	float2 uv0		: TEXCOORD0;
	float2 uv1		: TEXCOORD1;
#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
	float2 uv2		: TEXCOORD2;
#endif
#ifdef _TANGENT_TO_WORLD
	half4 tangent	: TANGENT;
#endif
};

float4 TexCoords(VertexInput v)
{
	float4 texcoord;
	texcoord.xy = TRANSFORM_TEX(v.uv0, _OverTex); // Always source from uv0
	texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
	return texcoord;
}		

half DetailMask(float2 uv)
{
	return tex2D (_DetailMask, uv).a;
}

half3 Albedo(float4 texcoords)
{
	half3 albedo;
	if (_OnlyOverColor )
	{
		albedo = _OverColor.rgb;
	}else{
		albedo = _OverColor.rgb * tex2D (_OverTex, texcoords.xy).rgb;
	}

#if _DETAIL
	#if (SHADER_TARGET < 30)
		// SM20: instruction count limitation
		// SM20: no detail mask
		half mask = 1; 
	#else
		half mask = DetailMask(texcoords.xy);
	#endif
	half3 detailAlbedo = tex2D (_DetailAlbedoMap, texcoords.zw).rgb;
	#if _DETAIL_MULX2
		albedo *= LerpWhiteTo (detailAlbedo * unity_ColorSpaceDouble.rgb, mask);
	#elif _DETAIL_MUL
		albedo *= LerpWhiteTo (detailAlbedo, mask);
	#elif _DETAIL_ADD
		albedo += detailAlbedo * mask;
	#elif _DETAIL_LERP
		albedo = lerp (albedo, detailAlbedo, mask);
	#endif
#endif
	return albedo;
}

half Alpha(float2 uv)
{
	if (_OnlyOverColor )
	{
		return _OverColor.a;
	}else{
		return tex2D(_OverTex, uv).a * _OverColor.a;
	}
}		

half Occlusion(float2 uv)
{
#if (SHADER_TARGET < 30)
	// SM20: instruction count limitation
	// SM20: simpler occlusion
	return tex2D(_OcclusionMap, uv * _OcclusionMap_ST.xy+_OcclusionMap_ST.zw).g;
#else
	half occ = tex2D(_OcclusionMap, uv * _OcclusionMap_ST.xy+_OcclusionMap_ST.zw).g;
	return LerpOneTo (occ, _OcclusionStrength);
#endif
}

half4 SpecularGloss(float2 uv)
{
	half4 sg;
#ifdef _SPECGLOSSMAP
	sg = tex2D(_SpecGlossMap, uv.xy);
#else
	sg = half4(_SpecColor.rgb, _Glossiness);
#endif
	return sg;
}


// add FUR_OFFSET
half2 MetallicGloss(float2 uv)
{
	half2 mg;
#ifdef _METALLICGLOSSMAP
	mg = tex2D(_MetallicGlossMap, uv.xy).ra;
#else
	mg = half2(_Metallic, _Glossiness);
#endif
	mg *= ( half2( (pow(FUR_OFFSET,_MetalicMulLayer*2.0))*_MetalicMul ,
		           (pow(FUR_OFFSET,_GlossinessMulLayer*2.0))*_GlossinessMul ));
	return mg;
}

half3 Emission(float2 uv)
{
#ifndef _EMISSION
	return 0;
#else
	return tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb;
#endif
}


float4 Parallax (float4 texcoords, half3 viewDir)
{
#if !defined(_PARALLAXMAP) || (SHADER_TARGET < 30)
	// SM20: instruction count limitation
	// SM20: no parallax
	return texcoords;
#else
	half h = tex2D (_ParallaxMap, texcoords.xy).g;
	float2 offset = ParallaxOffset1Step (h, _Parallax, viewDir);
	return float4(texcoords.xy + offset, texcoords.zw + offset);
#endif
}
			
#endif // UNITY_STANDARD_INPUT_INCLUDED





#endif
