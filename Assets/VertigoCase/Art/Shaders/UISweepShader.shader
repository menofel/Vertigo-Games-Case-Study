Shader "UI/Custom/LightSweep"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        
        [Header(Sweep Texture Settings)]
        _SweepTex ("Sweep Texture (Set Wrap to Clamp)", 2D) = "white" {}
        [HDR] _SweepColor ("Sweep Color", Color) = (1,1,1,1)
        _SweepSpeed ("Sweep Speed", Float) = 2.0
        _SweepInterval ("Sweep Interval (Seconds)", Float) = 3.0
        _SweepAngle ("Sweep Angle (Degrees)", Range(-90.0, 90.0)) = 20.0
        _SweepIntensity ("Sweep Intensity", Float) = 1.5
        
        [HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil ("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]_ColorMask ("Color Mask", Float) = 15
        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Clip Alpha", Float) = 0
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
        Blend SrcAlpha OneMinusSrcAlpha
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

            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;     // Sprite Atlas UV
                float2 texcoord1 : TEXCOORD1;    // UILocalUVModifier (uv1)
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord : TEXCOORD0;     // Sprite Atlas UV
                float4 worldPosition : TEXCOORD1;
                float2 localUV  : TEXCOORD5;     // Local 0..1 UV (Atlas independent)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            
            sampler2D _SweepTex;
            float4 _SweepTex_ST;
            fixed4 _SweepColor;
            float _SweepSpeed;
            float _SweepInterval;
            float _SweepAngle;
            float _SweepIntensity;

            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.localUV = v.texcoord1;
                o.color = v.color * _Color;
                return o;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                // Ana Buton Doku Örneklemesi (Atlas koordinatları ile)
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                
                // Atlastan bağımsız localUV (C# tarafından enjekte edilen uv1) kullanıyoruz.
                // Eğer UILocalUVModifier atanmamışsa localUV (0,0) olacaktır.
                // Hem editörde hem build'de en güvenli çalışma için localUV kullanırız.
                float2 finalUV = IN.localUV;
                
                float rad = _SweepAngle * 0.0174532925;
                float sinAngle, cosAngle;
                sincos(rad, sinAngle, cosAngle);
                
                float2 uvCentered = finalUV - 0.5;
                float2 rotatedUV;
                rotatedUV.x = uvCentered.x * cosAngle - uvCentered.y * sinAngle;
                rotatedUV.y = uvCentered.x * sinAngle + uvCentered.y * cosAngle;
                rotatedUV += 0.5;
                
                float totalCycle = _SweepInterval + (1.0 / _SweepSpeed);
                float currentTime = _Time.y % totalCycle;
                float startPos = -2.0;
                float endPos = 2.0;
                float currentOffset = lerp(startPos, endPos, saturate(currentTime * _SweepSpeed));
                
                float2 sweepUV;
                sweepUV.x = rotatedUV.x - currentOffset;
                sweepUV.y = rotatedUV.y;
                
                half4 sweepSample = half4(0,0,0,0);
                if (sweepUV.x >= 0.0 && sweepUV.x <= 1.0)
                {
                    sweepSample = tex2D(_SweepTex, sweepUV);
                }
                
                fixed3 finalRGB = color.rgb + (sweepSample.rgb * sweepSample.a * _SweepColor.rgb * _SweepColor.a * _SweepIntensity * color.a);
                half4 finalColor = half4(finalRGB, color.a);
                
                #ifdef UNITY_UI_ALPHACLIP
                clip (finalColor.a - 0.001);
                #endif
                
                finalColor.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                return finalColor;
            }
        ENDCG
        }
    }
}
