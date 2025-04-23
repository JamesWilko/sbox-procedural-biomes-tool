HEADER
{
	DevShader = true;
	Description = "A";
}

MODES
{
	Default();
}

FEATURES
{
}

COMMON
{
	#include "system.fxc" // This should always be the first include in COMMON
}

CS
{
	#include "common.fxc"

	float2 HeightUV < Attribute( "HeightUV" ); >;
    int BrushSize < Attribute( "BrushSize" ); >;
    float BrushStrength < Attribute( "BrushStrength" ); >;
	Texture2D<float> Brush < Attribute( "Brush" ); >;
	
	RWTexture2D<float> BiomeMap < Attribute( "BiomeMap" ); >;
	float BiomeValue < Attribute( "BiomeValue" ); >;
	float DefaultBiome < Attribute( "DefaultBiome" ); >;
	
	RWTexture2D<float4> VisualizationMap < Attribute( "VisualizationTexture" ); >;
	float4 VisualizationColor < Attribute( "VisualizationColor" ); >;
	float4 DefaultColor < Attribute( "DefaultColor" ); >;

    SamplerState g_sBilinearBorder < Filter( BILINEAR ); AddressU( BORDER ); AddressV( BORDER ); >;

	[numthreads( 16, 16, 1 )]
	void MainCs(uint nGroupIndex : SV_GroupIndex, uint3 vThreadId : SV_DispatchThreadID)
	{
        float w, h;
        BiomeMap.GetDimensions( w, h );

        int2 texelCenter = int2( float2( w, h ) * HeightUV );
        int2 texelOffset = int2( vThreadId.xy ) - int( BrushSize / 2 );

        int2 texel = texelCenter + texelOffset;
        if ( texel.x < 0 || texel.y < 0 || texel.x >= w || texel.y >= h ) return;

        float2 brushUV = float2( vThreadId.xy ) / BrushSize;

        float brush = Brush.SampleLevel( g_sBilinearBorder, brushUV, 0 ) * BrushStrength;
        if ( brush > 0.1f )
        {
            BiomeMap[texel] = BiomeValue;
        	VisualizationMap[texel] = VisualizationColor;
        }
        else if ( brush < -0.1f )
        {
            BiomeMap[texel] = DefaultBiome;
        	VisualizationMap[texel] = DefaultColor;
        }
		
    }
}

