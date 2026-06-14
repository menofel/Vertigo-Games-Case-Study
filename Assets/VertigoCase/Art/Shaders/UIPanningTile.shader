Shader "VertigoCase/UI/PanningTile"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        
        _Tiling ("Tiling (XY)", Vector) = (10, 6, 0, 0)
        _ScrollSpeed ("Scroll Speed (XY)", Vector) = (0.05, 0.02, 0, 0)
        _Rotation ("Rotation (Degrees)", Float) = 0
        _AspectRatio ("Aspect Ratio (W/H)", Float) = 1.777
        
        [Header(Blend Mode)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 10
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend [_SrcBlend] [_DstBlend]
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex        : SV_POSITION;
                fixed4 color         : COLOR;
                float2 texcoord      : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;

            float4 _Tiling;
            float4 _ScrollSpeed;
            float _Rotation;
            float _AspectRatio;

            // UV'yi merkez etrafinda aspect ratio kompanzasyonuyla dondurme
            float2 RotateUV(float2 uv, float angleDeg, float aspect)
            {
                float rad = angleDeg * 0.0174532925; // Derece -> Radyan
                float cosA = cos(rad);
                float sinA = sin(rad);

                // Pivot noktasi olarak merkezi (0.5, 0.5) al
                uv -= 0.5;

                // Dondurme oncesi aspect ratio'yu dengele (kare uzaya cevir)
                uv.x *= aspect;

                float2 rotated;
                rotated.x = uv.x * cosA - uv.y * sinA;
                rotated.y = uv.x * sinA + uv.y * cosA;

                // Dondurme sonrasi geri al
                rotated.x /= aspect;

                rotated += 0.5;
                return rotated;
            }

            v2f vert(appdata v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(v.vertex);
                
                // UV donme, tiling ve zamana bagli kaydirma islemlerini vertex shader'da yapiyoruz
                float2 uv = RotateUV(v.texcoord, _Rotation, _AspectRatio);
                uv *= _Tiling.xy;
                uv += _Time.y * _ScrollSpeed.xy;
                
                OUT.texcoord = uv;
                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                // Source Image'i sample et (UV interpolasyonu donmus ve kaymis sekilde gelir)
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                // UI Mask clipping
                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip(color.a - 0.001);
                #endif

                return color;
            }
            ENDCG
        }
    }
}
