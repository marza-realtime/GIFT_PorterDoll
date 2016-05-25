#ifndef MZ_FUR_CORE
#define MZ_FUR_CORE


uniform float _MetalicMul;
uniform float _MetalicMulLayer;
uniform float _GlossinessMul;
uniform float _GlossinessMulLayer;

//overwrite for _MainTex
#include "MarzaFurOverStandard.cginc"
#include "UnityStandardCore.cginc"


#ifdef MARZAFURBASEPASS

struct vert2frag {
    float4 pos                          : SV_POSITION;
    float4 tex                          : TEXCOORD0;
    half3 eyeVec                        : TEXCOORD1;
    half4 tangentToWorldAndParallax[3]  : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax]
    half4 ambientOrLightmapUV           : TEXCOORD5;    // SH or Lightmap UV
    //SHADOW_COORDS(6)
    UNITY_FOG_COORDS(7)

    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
    #if UNITY_SPECCUBE_BOX_PROJECTION
        float3 posWorld                 : TEXCOORD8;
    #endif

    #if UNITY_OPTIMIZE_TEXCUBELOD
        #if UNITY_SPECCUBE_BOX_PROJECTION
            half3 reflUVW               : TEXCOORD9;
        #else
            half3 reflUVW               : TEXCOORD8;
        #endif
    #endif

    float2 uv2  : TEXCOORD9;
    
    float3  viewDir                     : TEXCOORD10;
    float3  lightDir                    : TEXCOORD11;
    //float4 _LightCoord                : TEXCOORD12;
    float4 _ShadowCoord                 : TEXCOORD13;
    //LIGHTING_COORDS(12, 13)
    float3 vertexLighting               : TEXCOORD14;
    float4 vData                        : TEXCOORD15;

};

#elif defined(MARZAFURADDPASS)

struct vert2frag {
    float4 pos                          : SV_POSITION;
    float4 tex                          : TEXCOORD0;
    half3 eyeVec                        : TEXCOORD1;
    half4 tangentToWorldAndLightDir[3]  : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:lightDir]
    LIGHTING_COORDS(5,6)
    UNITY_FOG_COORDS(7)

    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
#if defined(_PARALLAXMAP)
    half3 viewDirForParallax            : TEXCOORD8;
#endif

    float2 uv2                          : TEXCOORD9;
    
    float3  viewDir                     : TEXCOORD10;
    float3  lightDir                    : TEXCOORD11;
    //LIGHTING_COORDS(12, 13)
    //float4 _LightCoord                : TEXCOORD12;

#if defined(POINT) && defined (SHADOWS_OFF) 
    float4 _ShadowCoord                 : TEXCOORD13;
#endif    

    float3 normal                       : TEXCOORD14;

};

#endif


//////////////////
//for vertexShader

#ifdef MARZAFURBASEPASS

void AttatchStdToMine(inout vert2frag v2f, VertexOutputForwardBase vofb){
    
    v2f.pos = vofb.pos;
    v2f.tex = vofb.tex;
    v2f.eyeVec = vofb.eyeVec;
    v2f.tangentToWorldAndParallax = vofb.tangentToWorldAndParallax;
    v2f.ambientOrLightmapUV = vofb.ambientOrLightmapUV;
    #if !defined (SHADOWS_SCREEN) && !defined (SHADOWS_DEPTH) && !defined (SHADOWS_CUBE)
    #else
        //turn off for disable ShadowCaster with StanfardShader
        v2f._ShadowCoord = vofb._ShadowCoord;
    #endif
    
    #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
        v2f.fogCoord = vofb.fogCoord;
    #endif

    #if UNITY_SPECCUBE_BOX_PROJECTION
        v2f.posWorld = vofb.posWorld;
    #endif
    #if UNITY_OPTIMIZE_TEXCUBELOD
        v2f.reflUVW = vofb.reflUVW;
    #endif     

}

#elif defined(MARZAFURADDPASS)

void AttatchStdToMine(inout vert2frag v2f, VertexOutputForwardAdd vofa){
    v2f.pos = vofa.pos;
    v2f.tex = vofa.tex;
    v2f.eyeVec = vofa.eyeVec;
    v2f.tangentToWorldAndLightDir = vofa.tangentToWorldAndLightDir;

    //LIGHTING_COORDS
    #if defined(POINT) || defined(SPOT) || defined(POINT_COOKIE) || defined(DIRECTIONAL_COOKIE)
        v2f._LightCoord = vofa._LightCoord;
    #endif

    #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    v2f.fogCoord = vofa.fogCoord;
    #endif

    #if defined(_PARALLAXMAP)
        v2f.viewDirForParallax = vofa.viewDirForParallax;
    #endif 

}

#endif



void vertForward(inout vert2frag v2f , appdata_full v){

    //standard calc
    VertexInput vv;
    vv.vertex = v.vertex;
    vv.normal = v.normal;
    vv.uv0    = v.texcoord;
    vv.uv1    = v.texcoord1;
#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
    vv.uv2    = v.texcoord2
#endif
#ifdef _TANGENT_TO_WORLD
    vv.tangent = v.tangent;
#endif    

#ifdef MARZAFURBASEPASS
    VertexOutputForwardBase vofb = vertForwardBase(vv);
#elif defined(MARZAFURADDPASS)
    VertexOutputForwardAdd vofb = vertForwardAdd(vv);
#endif
    
    AttatchStdToMine(v2f,vofb);

}


//////////////////
//for fragmentShader

#ifdef MARZAFURBASEPASS

VertexOutputForwardBase AttatchMineToSTD(VertexOutputForwardBase vofb, vert2frag v2f){
//    vofb = (VertexOutputForwardBase)v2f;

    vofb.pos = v2f.pos;
    vofb.tex = v2f.tex;
    vofb.eyeVec = v2f.eyeVec;
    vofb.tangentToWorldAndParallax = v2f.tangentToWorldAndParallax;
    vofb.ambientOrLightmapUV = v2f.ambientOrLightmapUV;
    #if !defined (SHADOWS_SCREEN) && !defined (SHADOWS_DEPTH) && !defined (SHADOWS_CUBE)
    #else
        vofb._ShadowCoord = v2f._ShadowCoord;
    #endif
    
    #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    vofb.fogCoord = v2f.fogCoord;
    #endif

    #if UNITY_SPECCUBE_BOX_PROJECTION
        vofb.posWorld = v2f.posWorld;
    #endif
    #if UNITY_OPTIMIZE_TEXCUBELOD
        vofb.reflUVW = v2f.reflUVW;
    #endif 

    return vofb;
}

#elif defined(MARZAFURADDPASS)


VertexOutputForwardAdd AttatchMineToSTD(VertexOutputForwardAdd vofa, vert2frag v2f){
//    vofa = (VertexOutputForwardAdd)v2f;

    vofa.pos = v2f.pos;
    vofa.tex = v2f.tex;
    vofa.eyeVec = v2f.eyeVec;
    vofa.tangentToWorldAndLightDir = v2f.tangentToWorldAndLightDir;
    //LIGHTING_COORDS
#if defined(POINT) || defined(SPOT) || defined(POINT_COOKIE) || defined(DIRECTIONAL_COOKIE) || defined(DIRECTIONAL)

#if !defined(DIRECTIONAL)
    vofa._LightCoord = v2f._LightCoord;
#endif

    #if defined (SHADOWS_SCREEN)
        vofa._ShadowCoord = v2f._ShadowCoord;
    #endif

    // ---- Spot light shadows
    #if defined (SHADOWS_DEPTH) && defined (SPOT)
        vofa._ShadowCoord = v2f._ShadowCoord;
    #endif
    // ---- Point light shadows
    #if defined (SHADOWS_CUBE)
        vofa._ShadowCoord = v2f._ShadowCoord;
    #endif

#endif

    #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    vofa.fogCoord = v2f.fogCoord;
    #endif

    #if defined(_PARALLAXMAP)
        vofa.viewDirForParallax = v2f.viewDirForParallax;
    #endif 


    return vofa;
}

#endif


half4 fragForward(fixed4 mixColor , vert2frag i){
    half4 color;

#ifdef MARZAFURBASEPASS

    VertexOutputForwardBase vof;
    vof = AttatchMineToSTD( vof,  i);
    BeginChangeMainTex( mixColor );
    color = fragForwardBase(vof);
    EndChangeMainTex( );

#elif defined(MARZAFURADDPASS)

    VertexOutputForwardAdd vof;
    vof = AttatchMineToSTD( vof,  i);
    BeginChangeMainTex( mixColor );
    color = fragForwardAdd(vof);
    EndChangeMainTex( );

#endif

    return color;
}


#endif