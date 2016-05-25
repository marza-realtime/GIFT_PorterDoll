#ifndef MZ_FUR_STANDARD_WRAP_HELPER
#define MZ_FUR_STANDARD_WRAP_HELPER

#include "UnityStandardCore.cginc"


uniform float4 _MaskColor;
uniform float _UseShadeingKind;

//depth
uniform float _RemapMin;
uniform float _RemapMax;



VertexOutputForwardBase vertShellForwardBase (VertexInput v)
{
	VertexOutputForwardBase o;
	UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase, o);

    switch ( _UseShadeingKind ){
    case 1:
		o.tex = TexCoords(v);

		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		return o;
	break;
    case 2:
    	//depth 	
    	// use transfer o.tex for depth

        // _ZBufferParams: x = (1-far)/near, y = far/near, z = x/far, w = y/far.
        float nearp = 1.0f / _ZBufferParams.w;
        float farp = nearp * _ZBufferParams.y;
        
        float4 Pcam = mul(UNITY_MATRIX_MV, v.vertex);
        float zcam = -Pcam.z;
        float znorm = (zcam - nearp) / (farp - nearp);
        float zremap = _RemapMin + znorm * (_RemapMax - _RemapMin);

        //o.depths = float4(zcam, znorm, zremap, 1);
   		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

		//o.tex = TexCoords(v);
		o.tex = float4(zcam, znorm, zremap, 1);

    break;
    case 3:
    	//position 	
    	// use transfer o.tex for pos

   		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
        o.tex.xyz = mul(_Object2World, v.vertex);
        o.tex.a = 1.0f;

   	break;
   	case 4:
   		//normal
    	// use transfer o.tex for normal

   		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
        o.tex.xyz = UnityObjectToWorldNormal(v.normal);
        o.tex.a = 1.0f;

   	break;	
   	case 5:
   		//tangent
    	// use transfer o.tex for tangent

   		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	#ifdef _TANGENT_TO_WORLD
		float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
        o.tex.xyz = tangentWorld.xyz;
    #else 
        o.tex.xyz = 0;
	#endif
        o.tex.a = 1.0f;

   	break;	
	default:
		o = vertForwardBase(v);
	break;
	}

	return o;

}

half4 fragShellForwardBase (VertexOutputForwardBase i) : SV_Target
{
	

#ifdef MZSHELLBASEPASS
    switch ( _UseShadeingKind ){
    case 1:
        //mask
        float4 color;
        color.rgba = _MaskColor.rgba;
        return color;
        break;
    case 2: //depth
    case 3: //positon
    case 4:	//normal
    case 5:	//tangent
        //depth and position and normal and tangent
       	// if depth-mode using tex with depth

        return i.tex; 
    break;

    }
#else
    if (_UseShadeingKind != 0){
        return fixed4(0.0,0.0,0.0,1.0);
    }
#endif
	return fragForwardBase(i);

}



VertexOutputForwardAdd vertShellForwardAdd (VertexInput v)
{
	return vertForwardAdd(v);
}

half4 fragShellForwardAdd (VertexOutputForwardAdd i) : SV_Target
{

    if (_UseShadeingKind != 0){
        return fixed4(0.0,0.0,0.0,1.0);
    }

	return fragForwardAdd(i);
}




#endif



