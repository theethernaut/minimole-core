package com.li.minimole.materials.agal
{

	import com.li.minimole.materials.agal.vo.mappings.RegisterMapping;
	import com.li.minimole.materials.agal.vo.registers.VertexAttribute;
	import com.li.minimole.materials.agal.vo.registers.MatrixRegisterConstant;
	import com.li.minimole.materials.agal.vo.registers.VectorRegisterConstant;
	import com.li.minimole.materials.agal.vo.registers.FragmentSampler;

	import flash.display.BitmapData;
	import flash.geom.Point;

	public class AGALAdvancedPhongBitmapMaterial extends AGALMaterial
	{
		public function AGALAdvancedPhongBitmapMaterial( texture:BitmapData, normalMap:BitmapData, specularMap:BitmapData ) {
			
			super();

			// TODO: translate to AGAL-ish
			
			addVertexAttribute( new VertexAttribute( "vertexPositions", VertexAttribute.POSITIONS ) ); // va0
			addVertexAttribute( new VertexAttribute( "vertexUVs", VertexAttribute.UVS ) ); // va1

			addFragmentSampler( new FragmentSampler( "texture", texture ) ); // fs0
			addFragmentSampler( new FragmentSampler( "normalMap", normalMap ) ); // fs1
			addFragmentSampler( new FragmentSampler( "specularMap", specularMap ) ); // fs2

			addVertexConstant( new MatrixRegisterConstant( "modelViewProjection", null, new RegisterMapping( RegisterMapping.MVC_MAPPING ) ) ); // vc0 to vc3
			addVertexConstant( new MatrixRegisterConstant( "transform", null, new RegisterMapping( RegisterMapping.TRANSFORM_MAPPING ) ) ); // vc4 to vc7
			var vc4:VectorRegisterConstant = addVertexConstant( new VectorRegisterConstant( "lightPosition", 0, 0, 0, 0, new RegisterMapping( RegisterMapping.CAMERA_MAPPING ) ) ) as VectorRegisterConstant; // vc8
			var vc5:VectorRegisterConstant = addVertexConstant( new VectorRegisterConstant( "cameraPosition", 0, 0, 0, 0, new RegisterMapping( RegisterMapping.CAMERA_MAPPING ) ) ) as VectorRegisterConstant; // vc9
			vc4.setComponentRanges( new Point( -5, 5 ), new Point( -5, 5 ), new Point( -5, 5 ), new Point( -5, 5 ) );
			vc5.setComponentRanges( new Point( -5, 5 ), new Point( -5, 5 ), new Point( -5, 5 ), new Point( -5, 5 ) );

			var fc0:VectorRegisterConstant = addFragmentConstant( new VectorRegisterConstant( "specularColor", 1, 1, 1, 1 ) ) as VectorRegisterConstant; // fc0
			fc0.setComponentNames( "red", "green", "blue", "alpha" );
			var fc1:VectorRegisterConstant = addFragmentConstant( new VectorRegisterConstant( "lightProperties", 0, 1, 0.5, 50 ) ) as VectorRegisterConstant; // fc1
			fc1.setComponentNames( "ambient", "diffuse", "specular", "gloss" );
			fc1.compRanges[ 3 ] = new Point( 0, 100 );
			var fc2:VectorRegisterConstant = addFragmentConstant( new VectorRegisterConstant( "numericLiterals", 2, 1 ) ) as VectorRegisterConstant; // fc2
			fc2.setComponentNames( "2", "1", "not used", "not used" );
			addFragmentConstant( new MatrixRegisterConstant( "reducedTransform", null, new RegisterMapping( RegisterMapping.REDUCED_TRANSFORM_MAPPING ) ) ); // fc3

			var vertexAGAL:String = "" +
					"// transform vertex position to scene space\n" +
					"m44 vt0, va0, vc4\n" +
					"// interpolate direction to light\n" +
					"sub vt1, vc8, vt0 \n" +
					"mov v0, vt1 \n" +
					"// interpolate direction to camera\n" +
					"sub vt1, vc9, vt0 \n" +
					"mov v1, vt1 \n" +
					"// interpolate uvs\n" +
					"mov v2, va1 \n" +
					"// output\n" +
					"m44 op, va0, vc0";
			var fragmentAGAL:String = "" +
					"// normalize input\n" +
					"nrm ft0.xyz, v0 // dir to light\n" +
					"nrm ft1.xyz, v1 // dir to camera\n" +
					"// read textures\n" +
					"tex ft3, v2, fs0<2d, linear, nomip> // texture\n" +
					"tex ft2, v2, fs1<2d, linear, nomip> // normal map\n" +
					"tex ft7, v2, fs2<2d, linear, nomip> // specular map\n" +
					"// adapt normal reading\n" +
					"mul ft2, ft2, fc2.x // multiply by 2\n" +
					"sub ft2, ft2, fc2.y // subtract 1\n" +
					"neg ft2.z, ft2.z // flip z\n" +
					"m44 ft2, ft2, fc3 // apply transform (ignoring position)\n" +
					"// calculate diffuse term - ft4\n" +
					"dp3 ft4.x, ft2.xyz, ft0.xyz // find projection of direction to light on normal - ft4.x\n" +
					"sat ft4.x, ft4.x // ignore negative values\n" +
					"mul ft4.x, ft4.x, fc1.y // multiply projection of direction to light on normal with light's diffuse amount\n" +
					"add ft4.x, ft4.x, fc1.x // add light's ambient amount\n" +
					"mul ft4.xyz, ft4.xxx, ft3.xyz // multiply by material's diffuse color\n" +
					"// calculate specular term - ft5\n" +
					"add ft5.xyz, ft0.xyz, ft1.xyz // evaluate half vector\n" +
					"nrm ft5.xyz, ft5.xyz // normalize half vector\n" +
					"dp3 ft5.x, ft2.xyz, ft5.xyz // find projection of half vector on normal\n" +
					"sat ft5.x, ft5.x // ignore negative values\n" +
					"pow ft5.x, ft5.x, fc1.w // apply concentration (gloss)\n" +
					"mul ft5.x, ft5.x, fc1.z // multiply with light's specular amount\n" +
					"mul ft5.xyz, ft5.xxx, fc0 // multiply by materials specular color\n" +
					"mul ft5.xyz, ft5.xyz, ft7.xyz // multiply by specular map\n" +
					"// output - ft6\n" +
					"add ft6.xyz, ft4.xyz, ft5.xyz // combine diffuse and specular terms\n" +
					"mov oc, ft6.xyz // output\n";
			setAGAL( vertexAGAL, fragmentAGAL );
			
		}
	}
}
