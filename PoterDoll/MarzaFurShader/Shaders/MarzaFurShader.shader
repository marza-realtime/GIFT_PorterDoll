Shader "MarzaFurShader" {
    Properties {
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

    CGINCLUDE
        //@TODO: should this be pulled into a shader_feature, to be able to turn it off?
        #define _GLOSSYENV 1
        #define UNITY_SETUP_BRDF_INPUT MetallicSetup
    ENDCG

    SubShader {


        Tags { "Queue"="AlphaTest" "RenderType"="MarzaFur"}
        
        // for base bottom pass.
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



        ZWrite On
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha // Alpha blending
        
        Alphatest Greater [_Cutoff]

        // for forward base passes.
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.000000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.020000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.040000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.060000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.080000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.100000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.120000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.140000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.160000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.180000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.200000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.220000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.240000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.260000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.280000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.300000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.320000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.340000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.360000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.380000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.400000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.420000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.440000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.460000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.480000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.500000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.520000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.540000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.560000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.580000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.600000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.620000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.640000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.660000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.680000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.700000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.720000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.740000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.760000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.780000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.800000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.820000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.840000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.860000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.880000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.900000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.920000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.940000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.960000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
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
            #define FUR_OFFSET 0.980000
            #include "MarzaFurHelper.cginc"
            ENDCG
        }
        //////////////////////////////////////////////////////////////////////////////////////////
        // for forward add passes.

        Blend One One


        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.000000
            #define LAYER 0
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.020000
            #define LAYER 1
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.040000
            #define LAYER 2
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.060000
            #define LAYER 3
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.080000
            #define LAYER 4
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.100000
            #define LAYER 5
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.120000
            #define LAYER 6
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.140000
            #define LAYER 7
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.160000
            #define LAYER 8
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.180000
            #define LAYER 9
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.200000
            #define LAYER 10
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.220000
            #define LAYER 11
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.240000
            #define LAYER 12
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.260000
            #define LAYER 13
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.280000
            #define LAYER 14
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.300000
            #define LAYER 15
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.320000
            #define LAYER 16
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.340000
            #define LAYER 17
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.360000
            #define LAYER 18
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.380000
            #define LAYER 19
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.400000
            #define LAYER 20
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.420000
            #define LAYER 21
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.440000
            #define LAYER 22
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.460000
            #define LAYER 23
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.480000
            #define LAYER 24
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.500000
            #define LAYER 25
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.520000
            #define LAYER 26
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.540000
            #define LAYER 27
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.560000
            #define LAYER 28
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.580000
            #define LAYER 29
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.600000
            #define LAYER 30
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.620000
            #define LAYER 31
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.640000
            #define LAYER 32
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.660000
            #define LAYER 33
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.680000
            #define LAYER 34
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.700000
            #define LAYER 35
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.720000
            #define LAYER 36
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.740000
            #define LAYER 37
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.760000
            #define LAYER 38
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.780000
            #define LAYER 39
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.800000
            #define LAYER 40
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.820000
            #define LAYER 41
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.840000
            #define LAYER 42
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.860000
            #define LAYER 43
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.880000
            #define LAYER 44
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.900000
            #define LAYER 45
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.920000
            #define LAYER 46
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.940000
            #define LAYER 47
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.960000
            #define LAYER 48
            #include "MarzaFurHelper.cginc"
            ENDCG
        }

        Pass {
            Tags {
                "LightMode"="ForwardAdd"
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
            #define FUR_OFFSET 0.980000
            #define LAYER 49
            #include "MarzaFurHelper.cginc"
            ENDCG
        }
     } // End of sub shader.
       // Fallback Off
    CustomEditor "MarzaFurEditorGUI"
}
