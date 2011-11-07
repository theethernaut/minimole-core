package com.li.minimole.materials.agal
{

	import com.li.minimole.materials.agal.vo.mappings.RegisterMapping;
	import com.li.minimole.materials.agal.vo.registers.VertexAttribute;
	import com.li.minimole.materials.agal.vo.registers.MatrixRegisterConstant;
	import com.li.minimole.materials.agal.vo.registers.VectorRegisterConstant;
	import com.li.minimole.materials.agal.vo.registers.FragmentSampler;

	import flash.display.BitmapData;
	import flash.geom.Point;

	public class AGALPhongBitmapMaterial extends AGALMaterial
	{
		public function AGALPhongBitmapMaterial( bitmap:BitmapData ) {
			
			super();

			// TODO: translate to AGAL-ish

			addVertexAttribute( new VertexAttribute( "vertexPositions", VertexAttribute.POSITIONS ) ); // va0
			addVertexAttribute( new VertexAttribute( "vertexNormals", VertexAttribute.NORMALS ) ); // va1
			addVertexAttribute( new VertexAttribute( "vertexUvs", VertexAttribute.UVS ) ); // va1

			addFragmentSampler( new FragmentSampler( "texture", bitmap ) ); // fs0

			addVertexConstant( new MatrixRegisterConstant( "modelViewProjection", null, new RegisterMapping( RegisterMapping.MVC_MAPPING ) ) ); // vc0 to vc3
			addVertexConstant( new MatrixRegisterConstant( "transform", null, new RegisterMapping( RegisterMapping.TRANSFORM_MAPPING ) ) ); // vc4 to vc7
			addVertexConstant( new MatrixRegisterConstant( "reducedTransform", null, new RegisterMapping( RegisterMapping.REDUCED_TRANSFORM_MAPPING ) ) ); // vc8 to vc11
			var vc12:VectorRegisterConstant = addVertexConstant( new VectorRegisterConstant( "lightPosition", 0, 0, 0, 0, new RegisterMapping( RegisterMapping.CAMERA_MAPPING ) ) ) as VectorRegisterConstant; // vc12
			var vc13:VectorRegisterConstant = addVertexConstant( new VectorRegisterConstant( "cameraPosition", 0, 0, 0, 0, new RegisterMapping( RegisterMapping.CAMERA_MAPPING ) ) ) as VectorRegisterConstant; // vc13
			vc12.setComponentRanges( new Point( -5, 5 ), new Point( -5, 5 ), new Point( -5, 5 ), new Point( -5, 5 ) );
			vc13.setComponentRanges( new Point( -5, 5 ), new Point( -5, 5 ), new Point( -5, 5 ), new Point( -5, 5 ) );

			var fc0:VectorRegisterConstant = addFragmentConstant( new VectorRegisterConstant( "diffuseColor", 1, 1, 1, 1 ) ) as VectorRegisterConstant;
			var fc1:VectorRegisterConstant = addFragmentConstant( new VectorRegisterConstant( "specularColor", 1, 1, 1, 1 ) ) as VectorRegisterConstant;
			var fc2:VectorRegisterConstant = addFragmentConstant( new VectorRegisterConstant( "lightProperties", 0, 1, 0.5, 50 ) ) as VectorRegisterConstant;
			fc0.setComponentNames( "red", "green", "blue", "alpha" );
			fc1.setComponentNames( "red", "green", "blue", "alpha" );
			fc2.setComponentNames( "ambient", "diffuse", "specular", "gloss" );
			fc2.compRanges[ 3 ] = new Point( 0, 100 );

			var vertexAGAL:String = "" +
					"// transform vertex position to scene space\n" +
					"m44 vt0, va0, vc4\n" +
					"// interpolate direction to light\n" +
					"sub vt1, vc12, vt0 \n" +
					"mov v0, vt1 \n" +
					"// interpolate direction to camera\n" +
					"sub vt1, vc13, vt0 \n" +
					"mov v1, vt1 \n" +
					"// transform normals to scene space (ignoring position)\n" +
					"m44 vt1, va1, vc8\n" +
					"// interpolate normals\n" +
					"mov v2, vt1 \n" +
					"// interpolate uvs\n" +
					"mov v3, va2 \n" +
					"// output\n" +
					"m44 op, va0, vc0";
			var fragmentAGAL:String = "" +
					"// normalize input\n" +
					"nrm ft0.xyz, v0 \n" +
					"nrm ft1.xyz, v1 \n" +
					"nrm ft2.xyz, v2 \n" +
					"// read texture\n" +
					"tex ft3, v3, fs0<2d, linear, nomip> \n" +
					"mul ft3, ft3, fc0\n" +
					"// calculate diffuse term - ft4\n" +
					"dp3 ft4.x, ft2.xyz, ft0.xyz // find projection of direction to light on normal - ft4.x\n" +
					"sat ft4.x, ft4.x // ignore negative values\n" +
					"mul ft4.x, ft4.x, fc2.y // multiply projection of direction to light on normal with light's diffuse amount\n" +
					"add ft4.x, ft4.x, fc2.x // add light's ambient amount\n" +
					"mul ft4.xyz, ft4.xxx, ft3.xyz // multiply by material's diffuse color\n" +
					"// calculate specular term - ft5\n" +
					"add ft5.xyz, ft0.xyz, ft1.xyz // evaluate half vector\n" +
					"nrm ft5.xyz, ft5.xyz // normalize half vector\n" +
					"dp3 ft5.x, ft2.xyz, ft5.xyz // find projection of half vector on normal\n" +
					"sat ft5.x, ft5.x // ignore negative values\n" +
					"pow ft5.x, ft5.x, fc2.w // apply concentration (gloss)\n" +
					"mul ft5.x, ft5.x, fc2.z // multiply with light's specular amount\n" +
					"mul ft5.xyz, ft5.xxx, fc1 // multiply by materials specular color\n" +
					"// output - ft6\n" +
					"add ft6.xyz, ft4.xyz, ft5.xyz // combine diffuse and specular terms\n" +
					"mov oc, ft6.xyz // output\n";

			setAGAL( vertexAGAL, fragmentAGAL );
		}
	}
}
