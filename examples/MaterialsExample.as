package examples {

	import com.li.minimole.materials.agal.AGALMaterial;
	import com.li.minimole.materials.agal.mappings.RegisterMapping;
	import com.li.minimole.materials.agal.registers.VertexAttribute;
	import com.li.minimole.materials.agal.registers.MatrixRegisterConstant;
	import com.li.minimole.materials.agal.registers.VectorRegisterConstant;
	import com.li.minimole.materials.agal.registers.FragmentSampler;

	public class MaterialsExample extends HeadExampleBase {

		public function MaterialsExample() {
			super();
		}

		override protected function onPostInit():void {
			super.onPostInit();

//			head.material = new AGALPhongBitmapMaterial( headTexture );
			testAgalCustomMaterial_phong_bitmap();
//			head.forceVertexNormalsToTriangleNormals();
		}

		private function testAgalCustomMaterial_phong_bitmap():void {

			var material:AGALMaterial = new AGALMaterial();

			material.addVertexAttribute( new VertexAttribute( "vertexPositions", VertexAttribute.POSITIONS ) ); // va0
			material.addVertexAttribute( new VertexAttribute( "vertexNormals", VertexAttribute.NORMALS ) ); // va1
			material.addVertexAttribute( new VertexAttribute( "vertexUVs", VertexAttribute.UVS ) ); // va2

			material.addFragmentSampler( new FragmentSampler( "texture", headTexture ) ); // fs0

			material.addVertexConstant( new MatrixRegisterConstant( "mvc", null, new RegisterMapping( RegisterMapping.MVC_MAPPING ) ) ); // vc0 to vc3
			material.addVertexConstant( new VectorRegisterConstant( "lightPosition", 0, 0, 0, 0, new RegisterMapping( RegisterMapping.CAMERA_MAPPING ) ) ); // vc4
			material.addVertexConstant( new VectorRegisterConstant( "cameraPosition", 0, 0, 0, 0, new RegisterMapping( RegisterMapping.CAMERA_MAPPING ) ) ); // vc5

			material.addFragmentConstant( new VectorRegisterConstant( "specularColor", 1, 1, 1, 1 ) ); // fc0
			material.addFragmentConstant( new VectorRegisterConstant( "lightProperties", 0, 1, 0.5, 50 ) ); // fc1

			var vertexAGAL:String = "" +
					// interpolate direction to light
					"sub vt0, vc4, va0                   \n" +
					"mov v0,  vt0                        \n" +
					// interpolate direction to camera
					"sub vt1, vc5, va0                   \n" +
					"mov v1,  vt1                        \n" +
					// interpolate normals
					"mov v2,  va1                        \n" +
					// interpolate uvs
					"mov v3,  va2                        \n" +
					// output positions
					"m44 op,  va0,  vc0                  \n";
			var fragmentAGAL:String = "" +
					// normalize input
					"nrm ft0.xyz, v0                     \n" +
					"nrm ft1.xyz, v1                     \n" +
					"nrm ft2.xyz, v2                     \n" +
					// read texture
					"tex ft3, v3, fs0<2d, linear, nomip> \n" +
					// calculate diffuse term - ft4
					"dp3 ft4.x,   ft2.xyz, ft0.xyz     	 \n" + // find projection of direction to light on normal - ft4.x
					"sat ft4.x,   ft4.x          	   	 \n" + // ignore negative values
					"mul ft4.x,   ft4.x,   fc1.y   	   	 \n" + // multiply projection of direction to light on normal with light's diffuse amount
					"add ft4.x,   ft4.x,   fc1.x   	   	 \n" + // add light's ambient amount
					"mul ft4.xyz, ft4.xxx, ft3.xyz	   	 \n" + // multiply by material's diffuse color
					// calculate specular term - ft5
					"add ft5.xyz, ft0.xyz, ft1.xyz       \n" + // evaluate half vector
					"nrm ft5.xyz, ft5.xyz                \n" + // normalize half vector
					"dp3 ft5.x,   ft2.xyz, ft5.xyz       \n" + // find projection of half vector on normal
					"sat ft5.x,   ft5.x                  \n" + // ignore negative values
					"pow ft5.x,   ft5.x,   fc1.w         \n" + // apply concentration (gloss)
					"mul ft5.x,   ft5.x,   fc1.z         \n" + // multiply with light's specular amount
					"mul ft5.xyz, ft5.xxx, fc0           \n" + // multiply by materials specular color
					// output - ft6
					"add ft6.xyz, ft4.xyz, ft5.xyz       \n" + // combine diffuse and specular terms
					"mov oc,      ft6.xyz                \n";  // output
			material.setAGAL( vertexAGAL, fragmentAGAL );
			material.setAGAL( vertexAGAL, fragmentAGAL );
			head.material = material;
		}
	}
}
