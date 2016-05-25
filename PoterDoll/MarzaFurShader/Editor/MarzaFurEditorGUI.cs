using System;
using UnityEngine;
using UnityEditor;

public class MarzaFurEditorGUI : ShaderGUI
{
    private enum WorkflowMode
    {
        Specular,
        Metallic,
        Dielectric
    }
 
    public enum BlendMode
    {
        Opaque,
        Cutout,
        Fade,        // Old school alpha-blending mode, fresnel does not affect amount of transparency
        Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
    }
    
    //For MarzaFur
    public enum FlowMode
    {
        Mode0,
        FlowMap,
        FlowMapScreen,
        FlowMapWorld,
        DebugFactor,
        Normal,
        Tangent,
        Binormal,
        UseWorld2Object,
        DebRotation
    }

    public enum ShellBlendType
    {
        Zero,
        One,
        DstColor,
        SrcColor,
        OneMinusDstColor,
        SrcAlpha,
        OneMinusSrcColor,
        DstAlpha,
        OneMinusDstAlpha,
        SrcAlphaSaturate,
        OneMinusSrcAlpha
    }



    private static class Styles
    {
        public static GUIStyle optionsButton = "PaneOptions";
        public static GUIContent uvSetLabel = new GUIContent("UV Set");
        public static GUIContent[] uvSetOptions = new GUIContent[] { new GUIContent("UV channel 0"), new GUIContent("UV channel 1") };
 
        public static string emptyTootip = "";
        public static GUIContent albedoText = new GUIContent("Albedo", "Albedo (RGB) and Transparency (A)");
        public static GUIContent alphaCutoffText = new GUIContent("Alpha Cutoff", "Threshold for alpha cutoff");
        public static GUIContent specularMapText = new GUIContent("Specular", "Specular (RGB) and Smoothness (A)");
        public static GUIContent metallicMapText = new GUIContent("Metallic", "Metallic (R) and Smoothness (A)");
        public static GUIContent smoothnessText = new GUIContent("Smoothness", "");
        public static GUIContent normalMapText = new GUIContent("Normal Map", "Normal Map");
        public static GUIContent heightMapText = new GUIContent("Height Map", "Height Map (G)");
        public static GUIContent occlusionText = new GUIContent("Occlusion", "Occlusion (G)");
        public static GUIContent emissionText = new GUIContent("Emission", "Emission (RGB)");
 
        public static string whiteSpaceString = " ";
        public static string primaryMapsText = "Main Maps";
        public static string maskPropertiesText = "MaskProperties";
        public static string renderingMode = "Rendering Mode";
        public static GUIContent emissiveWarning = new GUIContent ("Emissive value is animated but the material has not been configured to support emissive. Please make sure the material itself has some amount of emissive.");
        public static GUIContent emissiveColorWarning = new GUIContent ("Ensure emissive color is non-black for emission to have effect.");
        public static readonly string[] blendNames = Enum.GetNames (typeof (BlendMode));

        //for MarzaFur
        public static readonly string[] flowNames = Enum.GetNames (typeof (FlowMode));
        public static readonly string[] shellBlendNames = Enum.GetNames (typeof (ShellBlendType));
    }
 
    MaterialProperty blendMode = null;
    MaterialProperty albedoMap = null;
    MaterialProperty albedoColor = null;
    MaterialProperty alphaCutoff = null;
    MaterialProperty specularMap = null;
    MaterialProperty specularColor = null;
    MaterialProperty metallicMap = null;
    MaterialProperty metallic = null;
    MaterialProperty smoothness = null;
    MaterialProperty occlusionStrength = null;
    MaterialProperty occlusionMap = null;
    MaterialProperty heigtMapScale = null;
    MaterialProperty heightMap = null;
    MaterialProperty emissionScaleUI = null;
    MaterialProperty emissionColorUI = null;
    MaterialProperty emissionColorForRendering = null;
    MaterialProperty emissionMap = null;
 

    MaterialEditor m_MaterialEditor;
    WorkflowMode m_WorkflowMode = WorkflowMode.Specular;
 
    bool m_FirstTimeApply = true;
 
    public void FindProperties (MaterialProperty[] props)
    {
        blendMode = FindProperty ("_Mode", props);
        albedoMap = FindProperty ("_MainTex", props);
        albedoColor = FindProperty ("_Color", props);
        alphaCutoff = FindProperty ("_Cutoff", props);
        specularMap = FindProperty ("_SpecGlossMap", props, false);
        specularColor = FindProperty ("_SpecColor", props, false);
        metallicMap = FindProperty ("_MetallicGlossMap", props, false);
        metallic = FindProperty ("_Metallic", props, false);
        if (specularMap != null && specularColor != null)
            m_WorkflowMode = WorkflowMode.Specular;
        else if (metallicMap != null && metallic != null)
            m_WorkflowMode = WorkflowMode.Metallic;
        else
            m_WorkflowMode = WorkflowMode.Dielectric;
        smoothness = FindProperty ("_Glossiness", props);
        heigtMapScale = FindProperty ("_Parallax", props);
        heightMap = FindProperty("_ParallaxMap", props);
        occlusionStrength = FindProperty ("_OcclusionStrength", props);
        occlusionMap = FindProperty ("_OcclusionMap", props);
        emissionScaleUI = FindProperty ("_EmissionScaleUI", props);
        emissionColorUI = FindProperty ("_EmissionColorUI", props);
        emissionColorForRendering = FindProperty ("_EmissionColor", props);
        emissionMap = FindProperty ("_EmissionMap", props);

    }
 
    public override void OnGUI (MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties (props); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;
  
        //this Custom  / Original for StandardShader is ShaderPropertiesGUI (material);
        ShaderPropertiesGUI (material, props);
 
        // Make sure that needed keywords are set up if we're switching some existing
        // material to a standard shader.
        if (m_FirstTimeApply)
        {
            SetMaterialKeywords (material, m_WorkflowMode);
            m_FirstTimeApply = false;
        }


    }
 
    //draw property
    private void DrawProperty(MaterialProperty property)
    {
      switch (property.type)
      {
        case MaterialProperty.PropType.Range: // float ranges
          m_MaterialEditor.RangeProperty(property, property.displayName);
          break;

        case MaterialProperty.PropType.Float: // floats
          m_MaterialEditor.FloatProperty(property, property.displayName);
          break;

        case MaterialProperty.PropType.Color: // colors
          m_MaterialEditor.ColorProperty(property, property.displayName);
          break;

        case MaterialProperty.PropType.Texture: // textures
          m_MaterialEditor.TextureProperty(property, property.displayName);

          GUILayout.Space(6);
          break;

        case MaterialProperty.PropType.Vector: // vectors
          m_MaterialEditor.VectorProperty(property, property.displayName);
          break;

        default:
          GUILayout.Label("ARGH" + property.displayName + " : " + property.type);
          break;
      }
    }

    public void ShaderPropertiesGUI (Material material, MaterialProperty[] props)
    {
        // Use default labelWidth
        EditorGUIUtility.labelWidth = 0f;
 
        // Detect any changes to the material
        EditorGUI.BeginChangeCheck();
        {
            BlendModePopup();
 
            // Primary properties
            GUILayout.Label (Styles.primaryMapsText, EditorStyles.boldLabel);
            DoAlbedoArea(material);
            DoSpecularMetallicArea();
            m_MaterialEditor.TexturePropertySingleLine(Styles.heightMapText, heightMap, heightMap.textureValue != null ? heigtMapScale : null);
            m_MaterialEditor.TexturePropertySingleLine(Styles.occlusionText, occlusionMap, occlusionMap.textureValue != null ? occlusionStrength : null);
            DoEmissionArea(material);
            EditorGUI.BeginChangeCheck();
            m_MaterialEditor.TextureScaleOffsetProperty(albedoMap);
            if (EditorGUI.EndChangeCheck())
                emissionMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset; // Apply the main texture scale and offset to the emission texture as well, for Enlighten's sake
 
             EditorGUILayout.Space();
 
            //MarzaFur properties
            GUILayout.Label("MarzaFurProperties", EditorStyles.boldLabel);
            var drawFlag = false;
            var useDefaultShaderProp = false;


            foreach (var property in props)
            {
                //start is _BottomTex
                if (property.name == "_BottomTex")
                {
                  drawFlag = true;
                }

                if (drawFlag){
                    useDefaultShaderProp = false;

                    if (property.flags == MaterialProperty.PropFlags.HideInInspector)
                    {
                        continue;
                    }

                    // use default draw for UV
                    if (property.name.Contains("_UV"))
                    {
                        m_MaterialEditor.ShaderProperty(property, property.displayName);
                        GUILayout.Space(12);
                        continue;
                    }

                    //add maskColorLabel
                    if (property.name == "_MaskColor")
                    {
                     GUILayout.Label (Styles.maskPropertiesText, EditorStyles.boldLabel);
                    }

                    if (property.name == "_UseShadeingKind")
                    {
                        useDefaultShaderProp = true;
                    }


                    if (useDefaultShaderProp) {

                        m_MaterialEditor.ShaderProperty(property, property.displayName);

                    }else
                    {
                        DrawProperty(property);

                    }

                }
            }
            

            EditorGUILayout.Space();
 
        }
        if (EditorGUI.EndChangeCheck())
        {
            foreach (var obj in blendMode.targets)
                MaterialChanged((Material)obj, m_WorkflowMode);
        }
    }
 
    internal void DetermineWorkflow(MaterialProperty[] props)
    {
        if (FindProperty("_SpecGlossMap", props, false) != null && FindProperty("_SpecColor", props, false) != null)
            m_WorkflowMode = WorkflowMode.Specular;
        else if (FindProperty("_MetallicGlossMap", props, false) != null && FindProperty("_Metallic", props, false) != null)
            m_WorkflowMode = WorkflowMode.Metallic;
        else
            m_WorkflowMode = WorkflowMode.Dielectric;
    }
 
    public override void AssignNewShaderToMaterial (Material material, Shader oldShader, Shader newShader)
    {
        base.AssignNewShaderToMaterial(material, oldShader, newShader);
 
        if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
            return;
 
        BlendMode blendMode = BlendMode.Opaque;
        if (oldShader.name.Contains("/Transparent/Cutout/"))
        {
            blendMode = BlendMode.Cutout;
        }
        else if (oldShader.name.Contains("/Transparent/"))
        {
            // NOTE: legacy shaders did not provide physically based transparency
            // therefore Fade mode
            blendMode = BlendMode.Fade;
        }
        material.SetFloat("_Mode", (float)blendMode);
 
        //DetermineWorkflow( ShaderUtil.GetMaterialProperties(new Material[] { material }) );
        MaterialChanged(material, m_WorkflowMode);
    }
 
    void BlendModePopup()
    {
        EditorGUI.showMixedValue = blendMode.hasMixedValue;
        var mode = (BlendMode)blendMode.floatValue;
 
        EditorGUI.BeginChangeCheck();
        mode = (BlendMode)EditorGUILayout.Popup(Styles.renderingMode, (int)mode, Styles.blendNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
            blendMode.floatValue = (float)mode;
        }
 
        EditorGUI.showMixedValue = false;
    }


    void shellBlendModePopup( MaterialProperty inBlendTypeSrc, string label, string undoLabel)
    {
        EditorGUI.showMixedValue = inBlendTypeSrc.hasMixedValue;
        var mode = (ShellBlendType)inBlendTypeSrc.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (ShellBlendType)EditorGUILayout.Popup(label, (int)mode, Styles.shellBlendNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo(undoLabel);
            inBlendTypeSrc.floatValue = (int)mode;
        }

        EditorGUI.showMixedValue = false;
    }


    void DoAlbedoArea(Material material)
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap, albedoColor);
        if (((BlendMode)material.GetFloat("_Mode") == BlendMode.Cutout))
        {
            m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel+1);
        }
    }
 
    void DoEmissionArea(Material material)
    {
        bool showEmissionColorAndGIControls = emissionScaleUI.floatValue > 0f;
        bool hadEmissionTexture = emissionMap.textureValue != null;
 
        // Do controls
        m_MaterialEditor.TexturePropertySingleLine(Styles.emissionText, emissionMap, showEmissionColorAndGIControls ? emissionColorUI : null, emissionScaleUI);
 
        // Set default emissionScaleUI if texture was assigned
        if (emissionMap.textureValue != null && !hadEmissionTexture && emissionScaleUI.floatValue <= 0f)
            emissionScaleUI.floatValue = 1.0f;
 
        // Dynamic Lightmapping mode
        if (showEmissionColorAndGIControls)
        {
            bool shouldEmissionBeEnabled = ShouldEmissionBeEnabled(EvalFinalEmissionColor(material));
            EditorGUI.BeginDisabledGroup(!shouldEmissionBeEnabled);
 
            m_MaterialEditor.LightmapEmissionProperty (MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
 
            EditorGUI.EndDisabledGroup();
        }
 
        if (!HasValidEmissiveKeyword(material))
        {
            EditorGUILayout.HelpBox(Styles.emissiveWarning.text, MessageType.Warning);
        }
 
    }
 
    void DoSpecularMetallicArea()
    {
        if (m_WorkflowMode == WorkflowMode.Specular)
        {
            if (specularMap.textureValue == null)
                m_MaterialEditor.TexturePropertyTwoLines(Styles.specularMapText, specularMap, specularColor, Styles.smoothnessText, smoothness);
            else
                m_MaterialEditor.TexturePropertySingleLine(Styles.specularMapText, specularMap);
 
        }
        else if (m_WorkflowMode == WorkflowMode.Metallic)
        {
            if (metallicMap.textureValue == null)
                m_MaterialEditor.TexturePropertyTwoLines(Styles.metallicMapText, metallicMap, metallic, Styles.smoothnessText, smoothness);
            else
                m_MaterialEditor.TexturePropertySingleLine(Styles.metallicMapText, metallicMap);
        }
    }
 
    public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = -1;
                break;
            case BlendMode.Cutout:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.EnableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = 2450;
                break;
            case BlendMode.Fade:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.EnableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = 3000;
                break;
            case BlendMode.Transparent:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = 3000;
                break;
        }
    }
 
    // Calculate final HDR _EmissionColor (gamma space) from _EmissionColorUI (LDR, gamma) & _EmissionScaleUI (gamma)
    static Color EvalFinalEmissionColor(Material material)
    {
        return material.GetColor("_EmissionColorUI") * material.GetFloat("_EmissionScaleUI");
    }
 
    static bool ShouldEmissionBeEnabled (Color color)
    {
        return color.grayscale > (0.1f / 255.0f);
    }
 
    static void SetMaterialKeywords(Material material, WorkflowMode workflowMode)
    {
        // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
        // (MaterialProperty value might come from renderer material property block)
        if (workflowMode == WorkflowMode.Specular)
            SetKeyword (material, "_SPECGLOSSMAP", material.GetTexture ("_SpecGlossMap"));
        else if (workflowMode == WorkflowMode.Metallic)
            SetKeyword (material, "_METALLICGLOSSMAP", material.GetTexture ("_MetallicGlossMap"));
        SetKeyword (material, "_PARALLAXMAP", material.GetTexture ("_ParallaxMap"));
 
        bool shouldEmissionBeEnabled = ShouldEmissionBeEnabled (material.GetColor("_EmissionColor"));
        SetKeyword (material, "_EMISSION", shouldEmissionBeEnabled);
 
        // Setup lightmap emissive flags
        MaterialGlobalIlluminationFlags flags = material.globalIlluminationFlags;
        if ((flags & (MaterialGlobalIlluminationFlags.BakedEmissive | MaterialGlobalIlluminationFlags.RealtimeEmissive)) != 0)
        {
            flags &= ~MaterialGlobalIlluminationFlags.EmissiveIsBlack;
            if (!shouldEmissionBeEnabled)
                flags |= MaterialGlobalIlluminationFlags.EmissiveIsBlack;
 
            material.globalIlluminationFlags = flags;
        }
    }
 
    bool HasValidEmissiveKeyword (Material material)
    {
        // Material animation might be out of sync with the material keyword.
        // So if the emission support is disabled on the material, but the property blocks have a value that requires it, then we need to show a warning.
        // (note: (Renderer MaterialPropertyBlock applies its values to emissionColorForRendering))
        bool hasEmissionKeyword = material.IsKeywordEnabled ("_EMISSION");
        if (!hasEmissionKeyword && ShouldEmissionBeEnabled (emissionColorForRendering.colorValue))
            return false;
        else
            return true;
    }
 
    static void MaterialChanged(Material material, WorkflowMode workflowMode)
    {
        // Clamp EmissionScale to always positive
        if (material.GetFloat("_EmissionScaleUI") < 0.0f)
            material.SetFloat("_EmissionScaleUI", 0.0f);
 
        // Apply combined emission value
        Color emissionColorOut = EvalFinalEmissionColor (material);
        material.SetColor("_EmissionColor", emissionColorOut);
 
        // Handle Blending modes
        SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
 
        SetMaterialKeywords(material, workflowMode);
    }
 
    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword (keyword);
        else
            m.DisableKeyword (keyword);
    }
}
 