# -*- coding: shift-jis -*-
#
import os

parentPath = os.path.dirname( os.path.abspath( __file__ ) ) + u"/../Shaders/"

CategoryLabelPack = {
    ("MarzaFurShader","MarzaFurHelper")
}

dEditorName  = "MarzaFurEditorGUI"

#on/off addpass pass
onfAdd = True
#on/off shwdow pass
onfShadow = True

#enable Bottom Standard Shader
BStdShaderDefine = True
BStdShader = True


#max count is 128
passCount = 50


for (dCategoryLabel ,cgincHelper) in CategoryLabelPack:
    shaderName = parentPath + u"%s.shader"%dCategoryLabel

    #Shader Code Detail
    detail = ""

###################################################################
### file open

    f = open(shaderName,"w")

###################################################################
##properites    
    dProperties = """    Properties {
        //this is overwriteTex for MainTex
        _OverTex ("Albedo", 2D) = "white" { }
        _OverColor ("Color", Color) = (1,1,1,1)

        //standard Properties
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" { }
        [HideInInspector] _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        [Gamma]  _Metallic ("Metallic", Range(0,1)) = 0
        _MetallicGlossMap ("Metallic", 2D) = "white" { }
        [HideInInspector] _Parallax ("Height Scale", Range(0.005,0.08)) = 0.02
        [HideInInspector] _ParallaxMap ("Height Map", 2D) = "black" { }
        [HideInInspector] _OcclusionStrength ("Strength", Range(0,1)) = 1
        [HideInInspector] _OcclusionMap ("Occlusion", 2D) = "white" { }
        [HideInInspector] _EmissionColor ("Color", Color) = (0,0,0,1)
        [HideInInspector] _EmissionMap ("Emission", 2D) = "white" { }

        // UI-only data
        [HideInInspector] _EmissionScaleUI("Scale", Float) = 0.0
        [HideInInspector] _EmissionColorUI("Color", Color) = (1,1,1)

        [HideInInspector]  _Mode ("__mode", Float) = 0
        [HideInInspector]  _SrcBlend ("__src", Float) = 1
        [HideInInspector]  _DstBlend ("__dst", Float) = 0
        [HideInInspector]  _ZWrite ("__zw", Float) = 1

        //MarzaFur Properties
        _BottomTex ("Bottom (RGB)", 2D ) = "white" {}
        _BottomColor     ("Bottom Color", Color          ) = (1.0, 1.0, 1.0, 1.0)
        _BottomColorMul  ("Bottom Color Multi Factor", Float          ) = 1.0

        _TopTex ("Top (RGB)", 2D ) = "white" {}
        _TopColor     ("Top Color", Color          ) = (1.0, 1.0, 1.0, 1.0)
        _TopColorMul  ("Top Color  Multi Factor", Float          ) = 1.0

        [Enum(UV0,0,UV1,1)] _UVBottom ("UV Set for Bottom textures", Float) = 0
        [Enum(UV0,0,UV1,1)] _UVBump ("UV Set for Bump textures", Float) = 0

        //HightMap
        _HightTex ("HightMap", 2D )  = "black" {}
        [Enum(UV0,0,UV1,1)] _UVHight ("UV Set for Hight textures", Float) = 0
        _HightSubTex ("HightSubMap", 2D )  = "black" {}
        [Enum(UV0,0,UV1,1)] _UVHightSub ("UV Set for Hight Sub textures", Float) = 0
        _HightWeightTex ("HightWeightMap / HightMap:white HightSubMap:black", 2D )  = "white" {}
        [Enum(UV0,0,UV1,1)] _UVHightWeight ("UV Set for Hight Weight textures", Float) = 0

        _GrowTex ("GrowMap", 2D ) = "white" {}
        [Enum(UV0,0,UV1,1)] _UVGrow ("UV Set for Grow textures", Float) = 0
        _GrowColor ("GrowColor Color", Color     ) = (1.0, 1.0, 1.0, 1.0)        
        
        _FlowTex ("FlowMap", 2D ) = "white" {}
        [Enum(UV0,0,UV1,1)] _UVFlow ("UV Set for Flow textures", Float) = 0
        _FlowTensionTex ("FlowTensionMap", 2D ) = "white" {}
        [Enum(UV0,0,UV1,1)] _UVFlowTension ("UV Set for Flow Tension textures", Float) = 0
        _NormalTension ("NormalTension", Float) = 1

        [HideInInspector] _MetalicMul("MetalicMul", Range (-100.0, 100.0)) = 1.0
        [HideInInspector] _MetalicMulLayer("MetalicMulLayer", Range (0.0, 1.0)) = 1.0
        [HideInInspector] _GlossinessMul("GlossinessMul", Range (-100.0, 100.0)) = 1.0
        [HideInInspector] _GlossinessMulLayer("GlossinessMulLayer", Range (0.0, 1.0)) = 1.0
        
        _DeepIlum ("DeepMulti", Range(0.01,5.0)) = 1.0
        _DeepIlumAdd ("DeepAdd", Range(0.0,3.0)) = 0.4

        _FurLength ("Fur Length", Float          ) = 0.3

        _BottomTexScale  ("Bottom tex Scale UV map", Float)  = 1.0
        _BumpTexScale  ("Bump tex Scale UV map", Float)  = 1.0
        _HightTexScale ("Hight tex Scale UV map", Float) = 1.0


        ////////
        //mask
        _MaskColor ("MaskColor", Color) = (0,0,0,1)
        _RemapMin ("Remap Depth Min", Float) = 0.0
        _RemapMax ("Remap Depth Max", Float) = 1.0
        [Enum(Default,0,Mask,1,ZDepth,2,Position,3,Normal,4)] _UseShadeingKind ("Force Mask Shading", Float) = 0
    }
"""

    #createShader
    #Shader label
    detail += 'Shader "%s" {\n'%dCategoryLabel

    detail += (dProperties)




###################################################################
#PreDefine
    if BStdShaderDefine :
        detail += """
    CGINCLUDE
        //@TODO: should this be pulled into a shader_feature, to be able to turn it off?
        #define _GLOSSYENV 1
        #define UNITY_SETUP_BRDF_INPUT MetallicSetup
    ENDCG

"""



###################################################################
##subshader
    dSubShaderTop =  """    SubShader {


        Tags { "Queue"="AlphaTest" "RenderType"="MarzaFur"}
        
"""
    detail += dSubShaderTop

###################################################################
## base bottom pass
    if BStdShader:
        detail += "        // for base bottom pass."
        passDetail = """
        Cull Back
        ZWrite On  
        ZTest LEqual
        // ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            
            Blend [_SrcBlend] [_DstBlend]
            //ZWrite [_ZWrite]
            
            CGPROGRAM
            #pragma target 5.0
            // TEMPORARY: GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
            #pragma exclude_renderers gles
         
            // -------------------------------------
            
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            //ALWAYS ON shader_feature _GLOSSYENV
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _PARALLAXMAP
         
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            
            #define MARZAFURBASEPASS

            #pragma vertex vertShellForwardBase
            #pragma fragment fragShellForwardBase
            
            #include "MarzaFurStandardWrapHelper.cginc"
            
            ENDCG
        }
        // ------------------------------------------------------------------
        //  Additive forward pass (one light per pass)
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One
            Fog { Color (0,0,0,0) } // in additive pass fog should be black
            ZWrite Off
            ZTest LEqual
            
            CGPROGRAM
            #pragma target 5.0
            // GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
            #pragma exclude_renderers gles
            
            // -------------------------------------
         
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _PARALLAXMAP
         
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
         
            #pragma vertex vertShellForwardAdd
            #pragma fragment fragShellForwardAdd
            
            #include "MarzaFurStandardWrapHelper.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
         
            ZWrite On ZTest LEqual
             
            CGPROGRAM
            #pragma target 5.0
            // TEMPORARY: GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
            #pragma exclude_renderers gles
         
            // -------------------------------------

            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma multi_compile_shadowcaster
            
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster
            
            #include "UnityStandardShadow.cginc"
 
            ENDCG
        }


"""
        detail += passDetail


###################################################################
### shell Passes Shader Option

    shellPassShaderOption = """
        ZWrite On
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha // Alpha blending
        
        Alphatest Greater [_Cutoff]

"""
    detail += shellPassShaderOption

###################################################################
###base pass
    detail += "        // for forward base passes."
    passDetail = """
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="%s"
            }
 
            Blend [_SrcBlend] [_DstBlend]

             CGPROGRAM
            #pragma target 5.0
            // TEMPORARY: GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
            #pragma exclude_renderers gles
         
            // -------------------------------------
            
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            //ALWAYS ON shader_feature _GLOSSYENV
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _PARALLAXMAP
         
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #define MARZAFURBASEPASS
            #define FUR_OFFSET %s
            #include "%s"
            ENDCG
        }
"""
    for i in range(0,passCount):
        offset = str("{0:.6f}".format( round(1.0/passCount * i, 6)) )
        detail += passDetail%("ForwardBase", offset, "%s.cginc"%cgincHelper)


###################################################################
###add pass
    addPassHeder ="""        //////////////////////////////////////////////////////////////////////////////////////////
        // for forward add passes.

        Blend One One

"""
    passDetail = """
        Pass {
            Tags {
                "LightMode"="%s"
            }

            CGPROGRAM

            
            #pragma target 5.0
            // GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
            #pragma exclude_renderers gles
 
         
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _PARALLAXMAP
         
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #define MARZAFURADDPASS
            #define FUR_OFFSET %s
            #define LAYER %s
            #include "%s"
            ENDCG
        }
"""



    if onfAdd:
        detail += addPassHeder
        for i in range(0,passCount):
            offset = str("{0:.6f}".format( round(1.0/passCount * i, 6)) )
            detail += passDetail%("ForwardAdd", offset, i, "%s.cginc"%cgincHelper)

###################################################################
###End of Subshader
    dSubShaderTail = """     } // End of sub shader.
"""
    detail += dSubShaderTail



###################################################################
###Tail of Shader

    dTail = """       // Fallback Off
"""

    if (dEditorName!=""):
        dTail += ("""    CustomEditor "%s"
"""%dEditorName) 

    detail += dTail
    detail += '}\n'


###################################################################
### file write
    f.write(detail)
    f.close()
