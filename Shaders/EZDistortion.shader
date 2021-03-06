// Author:			ezhex1991@outlook.com
// CreateTime:		2019-09-23 11:38:38
// Organization:	#ORGANIZATION#
// Description:		

Shader "Hidden/EZUnity/PostProcessing/EZDistortion" {
	HLSLINCLUDE
		#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

		TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
		TEXTURE2D_SAMPLER2D(_DistortionTex, sampler_DistortionTex);
		TEXTURE2D_SAMPLER2D(_DistortionDepthTex, sampler_DistortionDepthTex);

		half2 _DistortionIntensity;
	ENDHLSL

	SubShader {
		Cull Off
		ZWrite Off
		ZTest Always

		Pass {
			HLSLPROGRAM

				#pragma vertex VertDefault
				#pragma fragment frag
				#pragma multi_compile _ _DEPTHTEST_ON

				half4 frag (VaryingsDefault i) : SV_Target {
					half4 distortionTex = SAMPLE_TEXTURE2D(_DistortionTex, sampler_DistortionTex, i.texcoord);
					float2 distortion = (distortionTex.r - 0.5) * _DistortionIntensity;

					#if _DEPTHTEST_ON
						float mainDepth = Linear01Depth(SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(i.texcoord), 0));
						float distortionDepth = Linear01Depth(SAMPLE_DEPTH_TEXTURE_LOD(_DistortionDepthTex, sampler_DistortionDepthTex, UnityStereoTransformScreenSpaceTex(i.texcoord), 0));
						distortion *= step(distortionDepth, mainDepth);
					#endif

					half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + distortion);
					return color;
				}

			ENDHLSL
		}
	}
}
