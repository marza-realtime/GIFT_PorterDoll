#ifndef MZ_FUR_STD_SHADER_HELPER
#define MZ_FUR_STD_SHADER_HELPER

#include "UnityCG.cginc"
#include "AutoLight.cginc"

#include "MarzaFurCore.cginc"

#if defined(DIRECTIONAL) || defined (SHADOWS_OFF) || defined (LIGHTMAP_OFF) || defined (DIRLIGHTMAP_OFF) || defined( DYNAMICLIGHTMAP_OFF) || defined (SHADOWS_CUBE) || defined (SHADOWS_SOFT) || defined (_DETAIL_MULX2)

#else
fixed4 _LightColor0;

// MainTexture
uniform sampler2D _MainTex;
uniform float4 _MainTex_ST;
uniform float4 _Color;
#endif

uniform float _UVBottom;
uniform sampler2D _BottomTex;
uniform float4 _BottomTex_ST;

uniform sampler2D _TopTex;
uniform float4 _TopTex_ST;

uniform float _UVBump;
uniform sampler2D _BumpTex;
uniform float4 _BumpTex_ST;

//Hight Map
uniform float _UVHight;
uniform sampler2D _HightTex;
uniform float4 _HightTex_ST;
uniform float _UVHightSub;
uniform sampler2D _HightSubTex;
uniform float4 _HightSubTex_ST;
uniform float _UVHightWeight;
uniform sampler2D _HightWeightTex;
uniform float4 _HightWeightTex_ST;

uniform float _UVGrow;
uniform sampler2D _GrowTex;
uniform float4 _GrowTex_ST;

uniform float _UVFlow;
uniform sampler2D _FlowTex;
uniform float4 _FlowTex_ST;
uniform float _UVFlowTension;
uniform sampler2D _FlowTensionTex;
uniform float4 _FlowTensionTex_ST;
uniform fixed _NormalTension;

uniform float4    _TopColor;
uniform float     _TopColorMul;
uniform float4    _BottomColor;
uniform float     _BottomColorMul;

uniform float4    _GrowColor;
uniform float     _FurLength;
uniform fixed     _Shininess;
uniform fixed     _DeepIlum;
uniform fixed     _DeepIlumAdd;

uniform float _BottomTexScale;
uniform float _BumpTexScale;
uniform float _HightTexScale;


//mask
uniform float4 _MaskColor;
uniform float _UseShadeingKind;
uniform float _RemapMin;
uniform float _RemapMax;


inline float2 getUV(vert2frag v ,int UVNo) {
    float2 coord;
    switch(UVNo){
    case 0:
         coord = v.tex;
      break;
    case 1:
         coord = v.uv2;
      break;
    default:
         coord = v.tex;
      break;
    }
    return coord;
}


vert2frag vert(appdata_full v) {

    vert2frag o;

    UNITY_INITIALIZE_OUTPUT(vert2frag,o);
    
    float4 position = v.vertex;

    o.tex  = v.texcoord.xyzw;
    o.uv2 = v.texcoord1.xy;
    
    // TANGENT_SPACE_ROTATION  ;
    // calc binormal by myself , v.tangent.w is zero with fbx
    float3 binormal = normalize( cross( normalize(v.normal), normalize(v.tangent.xyz) ) * 1); 
    float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );

    // Create a fur normal.
    float2 flowUVCoord = getUV(o,_UVFlow).xy;
    half2 flowUV = TRANSFORM_TEX( flowUVCoord, _FlowTex);
    fixed3 tmpFlow = saturate( tex2Dlod( _FlowTex, float4( flowUV.xy, 0,0)).rgb);
    
    tmpFlow.rgb = tmpFlow * 2.0 - 1.0;

    half2 flowTensionUV = TRANSFORM_TEX( getUV(o, _UVFlowTension).xy, _FlowTensionTex);
    fixed3 flowTension = tex2Dlod( _FlowTensionTex, float4( flowTensionUV.xy , 1, 1)).rgb;

    fixed4 flow;

    flow = float4( (tmpFlow.xyz * flowTension) , 1);

    //ScreenSpace flowMap
    if(any(flow.xyz)){
        flow.xyz = normalize(flow.xyz);
        flow.xyz = float3(-1*flow.x, -1*flow.y, flow.z);
    }else{
        flow.xyz = 0;
    }


    float4 aNormal = float4( normalize(v.normal), 1.0);
    //compute _NormalTension
    aNormal = float4(aNormal * _NormalTension + flow.xyz, 1.0);

    float  furLength = (_FurLength * FUR_OFFSET);

    aNormal = normalize(aNormal);
    float4 layer = aNormal * furLength;


    //wpos
    float4 wpos  = float4(v.vertex.xyz + layer.xyz, 1.0);

    o.lightDir = mul(rotation, ObjSpaceLightDir(wpos));
    o.viewDir  = mul(rotation, ObjSpaceViewDir(wpos));

    //position and uvs setting
    o.pos = mul(UNITY_MATRIX_MVP, wpos);

#if defined(MARZAFURBASEPASS)  
    TRANSFER_VERTEX_TO_FRAGMENT(o)
    o._ShadowCoord = ComputeScreenPos(mul(UNITY_MATRIX_MVP, wpos));
#endif
    
    v.vertex = wpos;
    vertForward(o,v);


#ifdef MARZAFURBASEPASS
    
    switch ( _UseShadeingKind ){
    case 2:
        //depth     
        // use transfer o.vData for depth
        // _ZBufferParams: x = (1-far)/near, y = far/near, z = x/far, w = y/far.
        float nearp = 1.0f / _ZBufferParams.w;
        float farp = nearp * _ZBufferParams.y;
        
        float4 Pcam = mul(UNITY_MATRIX_MV, wpos);
        float zcam = -Pcam.z;
        float znorm = (zcam - nearp) / (farp - nearp);
        float zremap = _RemapMin + znorm * (_RemapMax - _RemapMin);

        o.vData = float4(zcam, znorm, zremap, 1);

    break;
    case 3:
        //position
        //use transfer o.vData for pos

        o.vData.xyz = mul(_Object2World, wpos);
        o.vData.a = 1.0f;

    break;
    case 4:
        //normal
        // use transfer o.vData for normal

        o.vData.xyz = UnityObjectToWorldNormal( v.normal );
        o.vData.a = 1.0f;

    break;  
    case 5:
        //tangent
        // use transfer o.vData for tangent

    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
        o.vData.xyz = tangentWorld.xyz;
    #else 
        o.vData.xyz = 0;
    #endif
        o.vData.a = 1.0f;

    break;  
    default:
        o.vData = 1;
    break;

    }

#endif

    return o;
}



/////////////////////////////////////////////////////////////////
//frag
/////////////////////////////////////////////////////////////////

fixed4 frag(vert2frag i) : COLOR {

    //grow
    float4 growp = _GrowColor * saturate (tex2D(_GrowTex, getUV( i, _UVGrow) * _BottomTexScale * _GrowTex_ST.xy + _GrowTex_ST.zw));

    if( growp.r <= FUR_OFFSET) {
        discard;
    }

    //cut with hightmap Hight = HightTex * HightSub * HightWeight 
    float4 HightTex = tex2D(_HightTex, getUV( i, _UVHight) * _HightTexScale * _HightTex_ST.xy + _HightTex_ST.zw);
    float4 HightSubTex = tex2D(_HightSubTex, getUV( i, _UVHightSub) * _HightTexScale * _HightSubTex_ST.xy + _HightSubTex_ST.zw);
    //HightWeight with _BottomTexScale
    float4 HightWeightTex = tex2D(_HightWeightTex, getUV( i, _UVHightWeight) * _BottomTexScale * _HightWeightTex_ST.xy + _HightWeightTex_ST.zw);

    HightTex.xyz =  saturate(HightTex.xyz * HightWeightTex.xyz); 
    HightTex.xyz += saturate(HightSubTex.xyz * ( 1 - HightWeightTex.xyz)); 

    if(HightTex.r <= 0.0 || HightTex.r * growp.r <= FUR_OFFSET) {
        discard;
    }


    ///////////
    //color
    float4 color;
    fixed4 BaseTex;

    // mask
#ifdef MARZAFURBASEPASS
    switch ( _UseShadeingKind ){
    case 1:
        //mask
        color.a = 1.0 - FUR_OFFSET;
        color.rgb = _MaskColor.rgb;
        return color;
        break;
    case 2: //depth
    case 3: //positon
    case 4: //normal
    case 5: //tangent    
        return i.vData;
        break;    
    }
#else
    if (_UseShadeingKind != 0){
        return fixed4(0.0,0.0,0.0,1.0);
    }
#endif

    //get Tex
    fixed4 mainTex   = tex2D(_MainTex, getUV( i, _UVBottom) * _MainTex_ST.xy + _MainTex_ST.zw) * _Color; 
    fixed4 bottomTex = tex2D(_BottomTex, getUV( i, _UVBottom) * _BottomTexScale * _BottomTex_ST.xy + _BottomTex_ST.zw);
    fixed4 topTex    = tex2D(_TopTex, getUV( i, _UVBottom) * _BottomTexScale * _TopTex_ST.xy + _TopTex_ST.zw);

    //color scale
    bottomTex.rgb = bottomTex.rgb * _BottomColor.rgb * _BottomColorMul;
    topTex.rgb = topTex.rgb * _TopColor.rgb * _TopColorMul;

    if (_BumpTexScale){
        bottomTex.a = bottomTex.a * _BottomColor.a;
        topTex.a = topTex.a * _TopColor.a;    
    }

    //grow shading
    fixed4 mixColor;
    if (_BumpTexScale){
        mixColor = float4(lerp (mainTex.rgb, bottomTex.rgb , growp.r * _DeepIlum) ,1.0); 
    }else{
        mixColor = lerp (mainTex, bottomTex , growp.r * _DeepIlum) ; 
    }

    mixColor.rgb = lerp (mixColor.rgb, topTex.rgb, FUR_OFFSET * _DeepIlumAdd); 

    half4 hairColor = fragForward(mixColor, i);
   
    color.rgb = hairColor.rgb;
    color.a = 1.0 - FUR_OFFSET;

    return color;

}

#endif //MZ_FUR_SHADER_HELP