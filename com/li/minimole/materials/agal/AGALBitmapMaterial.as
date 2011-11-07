package com.li.minimole.materials.agal
{

	import com.li.minimole.materials.agal.vo.mappings.RegisterMapping;
	import com.li.minimole.materials.agal.vo.registers.FragmentSampler;
	import com.li.minimole.materials.agal.vo.registers.MatrixRegisterConstant;
	import com.li.minimole.materials.agal.vo.registers.RegisterConstant;
	import com.li.minimole.materials.agal.vo.registers.Varying;
	import com.li.minimole.materials.agal.vo.registers.VertexAttribute;

	import flash.display.BitmapData;

	public class AGALBitmapMaterial extends AGALMaterial
	{
		public function AGALBitmapMaterial( bitmap:BitmapData ) {
			super();
			
			var vertexPositions:VertexAttribute = addVertexAttribute( new VertexAttribute( "vertexPositions", VertexAttribute.POSITIONS ) ); // va0
			var vertexUvs:VertexAttribute = addVertexAttribute( new VertexAttribute( "vertexUvs", VertexAttribute.UVS ) ); // va1
			var mvc:RegisterConstant = addVertexConstant( new MatrixRegisterConstant( "modelViewProjection", null, new RegisterMapping( RegisterMapping.MVC_MAPPING ) ) ); // vc0
			var texture:FragmentSampler = addFragmentSampler( new FragmentSampler( "texture", bitmap ) );
			var interpolatedUvs:Varying = addVarying( new Varying( "interpolatedUvs" ) );

			// vertex
			_currentAGAL = "";
			mov( interpolatedUvs, vertexUvs );
			m44( op, vertexPositions, mvc );
			vertexAGAL = _currentAGAL;

			// fragment
			_currentAGAL = "";
			tex( oc, interpolatedUvs, texture );
			fragmentAGAL = _currentAGAL;
		}
	}
}
