package examples {

	import com.li.minimole.materials.agal.AGALBitmapMaterial;
	import com.li.minimole.materials.agal.AGALColorMaterial;
	import com.li.minimole.materials.agal.AGALCustomMaterial;
	import com.li.minimole.materials.agal.AGALPhongBitmapMaterial;
	import com.li.minimole.materials.agal.AGALPhongColorMaterial;
	import com.li.minimole.materials.pb3d.PB3DEnviroSphericalMaterial;
	import com.li.minimole.materials.pb3d.PB3DGouraudColorMaterial;
	import com.li.minimole.materials.pb3d.PB3DPhongBitmapMapMaterial;
	import com.li.minimole.materials.pb3d.PB3DPhongBitmapMaterial;
	import com.li.minimole.materials.pb3d.PB3DPhongToonMaterial;

	import flash.display.BitmapData;
	import flash.events.Event;

	public class MaterialsExample extends HeadExampleBase {
		// Env map.
		/*[Embed (source="assets/cubemap_brightday1/brightday1_positive_x.png")]
		 private var EnvPosX:Class;
		 [Embed (source="assets/cubemap_brightday1/brightday1_negative_x.png")]
		 private var EnvNegX:Class;
		 [Embed (source="assets/cubemap_brightday1/brightday1_positive_y.png")]
		 private var EnvPosY:Class;
		 [Embed (source="assets/cubemap_brightday1/brightday1_negative_y.png")]
		 private var EnvNegY:Class;
		 [Embed (source="assets/cubemap_brightday1/brightday1_positive_z.png")]
		 private var EnvPosZ:Class;
		 [Embed (source="assets/cubemap_brightday1/brightday1_negative_z.png")]
		 private var EnvNegZ:Class;

		 public var envPosX:BitmapData;
		 public var envNegX:BitmapData;
		 public var envPosY:BitmapData;
		 public var envNegY:BitmapData;
		 public var envPosZ:BitmapData;
		 public var envNegZ:BitmapData;*/

		public function MaterialsExample() {
			super();
		}

		override protected function onPostInit():void {
			super.onPostInit();

			// load cube map textures
//			envPosX = new EnvPosX().bitmapData;
//			envNegX = new EnvNegX().bitmapData;
//			envPosY = new EnvPosY().bitmapData;
//			envNegY = new EnvNegY().bitmapData;
//			envPosZ = new EnvPosZ().bitmapData;
//			envNegZ = new EnvNegZ().bitmapData;

//			testHardCodedPb3dMaterials();
//			testHardCodedAgalMaterials();
//			testAgalCustomMaterial_color();
//			testAgalCustomMaterial_bitmap();
			testAgalCustomMaterial_phong_bitmap();

//			head.forceVertexNormalsToTriangleNormals();
		}

		private function testAgalCustomMaterial_phong_bitmap():void {
			var agalCustomMaterial:AGALCustomMaterial = new AGALCustomMaterial();
			agalCustomMaterial.addTexture( headTexture );
			agalCustomMaterial.requiresUVBuffer = true;
			agalCustomMaterial.requiresNormalsBuffer = true;
			agalCustomMaterial.requiresMeshTransform = true;
			agalCustomMaterial.requiresMeshReducedTransform = true;
			agalCustomMaterial.addFragmentConstant( Vector.<Number>( [ 1.0, 1.0, 1.0, 1.0 ] ) ); // specular color
			agalCustomMaterial.addFragmentConstant( Vector.<Number>( [ 0.0, 1.0, 0.3, 9.0 ] ) ); // ambient, diffuse, specular, specular concentration multiplier (gloss)
			agalCustomMaterial.addFragmentConstant( Vector.<Number>( [ 1.0, 0.0, 0.0, 0.0 ] ) ); // numeric literals
			agalCustomMaterial.addVertexConstant( Vector.<Number>( [] ) ); // light position ( dummy )
			agalCustomMaterial.addVertexConstant( Vector.<Number>( [] ) ); // camera position ( dummy )
			addEventListener( Event.ENTER_FRAME, function( event:Event ):void { // update camera position and light position to shader on enterframe
				agalCustomMaterial.setVertexConstantByIndex( view.camera.positionVector, 0 );
				agalCustomMaterial.setVertexConstantByIndex( view.camera.positionVector, 1 );
			});
			var vertexAGAL:String = "" +
					"m44 vt0, va0,  vc4                  \n" + // line 1 - transform vertex position to scene space
					"sub vt0, vc12, vt0                  \n" + // line 2 - get direction to light
					"mov v0,  vt0                        \n" + // line 3 - interpolate direction to light - v0
					"sub vt1, vc13, vt0                  \n" + // line 4 - get direction to camera
					"mov v1,  vt1                        \n" + // line 5 - interpolate direction to camera - v1
					"m44 vt2, va1,  vc8                  \n" + // line 6 - transform vertex normal to scene space (ignoring position)
					"mov v2,  vt2                        \n" + // line 7 - interpolate vertex normal - v2
					"mov v3,  va2                        \n" + // line 8 - interpolate vertex uv - v3
					"m44 op,  va0,  vc0                  \n";  // line 9 - output vertex position to clip space
			var fragmentAGAL:String = "" +
					// normalize input
					"nrm ft0.xyz, v0                     \n" + // line 1 - normalize interpolated direction to light - ft0
					"mov ft0.w,   fc2.x                  \n" + // line 2 - set w to 1.0
					"nrm ft1.xyz, v1                     \n" + // line 3 - normalize interpolated direction to camera - ft1
					"mov ft1.w,   fc2.x                  \n" + // line 4 - set w to 1.0
					"nrm ft2.xyz, v2                     \n" + // line 5 - normalize interpolated normal - ft2
					"mov ft2.w,   fc2.x                  \n" + // line 6 - set w to 1.0
					// read texture
					"tex ft3, v3, fs0<2d, linear, nomip> \n" + // line 7 - sample texture at interpolated uv
					// calculate diffuse term - ft4
					"dp3 ft4.x,   ft2,     ft0     	   	 \n" + // line 8  - find projection of direction to light on normal - ft4.x
					"max ft4.x,   ft4.x,   fc2.w   	   	 \n" + // line 9  - ignore negative values
					"mul ft4.x,   ft4.x,   fc1.y   	   	 \n" + // line 10 - multiply projection of direction to light on normal with light's diffuse amount
					"add ft4.x,   ft4.x,   fc1.x   	   	 \n" + // line 11 - add light's ambient amount
					"mul ft4.xyz, ft4.xxx, ft3.xyz	   	 \n" + // line 12 - multiply by material's diffuse color
					// calculate specular term - ft5
					"add ft5.xyz, ft0.xyz, ft1.xyz       \n" + // line 13  - evaluate half vector
					"nrm ft5.xyz, ft5.xyz                \n" + // line 14 - normalize half vector
					"dp3 ft5.x,   ft2.xyz, ft5.xyz       \n" + // line 15 - find projection of half vector on normal
					"max ft5.x,   ft5.x,   fc2.w         \n" + // line 16 - ignore negative values
					"pow ft5.x,   ft5.x,   fc1.w         \n" + // line 17 - apply concentration (gloss)
					"mul ft5.x,   ft5.x,   fc1.z         \n" + // line 18 - multiply with light's specular amount
					"mul ft5.xyz, ft5.xxx, fc0           \n" + // line 19 - multiply by materials specular color
					// output - ft6
					"add ft6.xyz, ft4.xyz, ft5.xyz       \n" + // line 20 - combine diffuse and specular terms
					"mov ft6.w,   fc2.x			         \n" + // line 21 - set ft6.w = 1.0
					"mov oc,      ft6                    \n";  // line 22 - output
			agalCustomMaterial.setAGALDefinitions( vertexAGAL, fragmentAGAL );
			head.material = agalCustomMaterial;
		}

		private function testAgalCustomMaterial_bitmap():void {
			var agalCustomMaterial:AGALCustomMaterial = new AGALCustomMaterial();
			agalCustomMaterial.addTexture( headTexture );
			agalCustomMaterial.requiresUVBuffer = true;
			var vertexAGAL:String = "" +
					"mov v0, va1 \n" +
					"m44 op, va0, vc0 \n ";
			var fragmentAGAL:String = "" +
					"tex ft1, v0, fs0<2d, linear, nomip> \n" +
					"mov oc, ft1 \n";
			agalCustomMaterial.setAGALDefinitions( vertexAGAL, fragmentAGAL );
			head.material = agalCustomMaterial;
		}

		private function testAgalCustomMaterial_color():void {
			var agalCustomMaterial:AGALCustomMaterial = new AGALCustomMaterial();
			agalCustomMaterial.addFragmentConstant( Vector.<Number>( [ 1.0, 0.0, 1.0, 1.0 ] ) );
			var vertexAGAL:String = "" +
					"m44 op, va0, vc0 \n ";
			var fragmentAGAL:String = "" +
					"mov oc, fc0 \n";
			agalCustomMaterial.setAGALDefinitions( vertexAGAL, fragmentAGAL );
			head.material = agalCustomMaterial;
		}

		private function testHardCodedAgalMaterials():void {
			// AGAL materials
//			var agalBitmapMaterial:AGALBitmapMaterial = new AGALBitmapMaterial( headTexture );
//			var agalColorMaterial:AGALColorMaterial = new AGALColorMaterial( 0x00FF00 );
//			var agalPhongColorMaterial:AGALPhongColorMaterial = new AGALPhongColorMaterial( 0xFF0000 );
//			var agalPhongBitmapMaterial:AGALPhongBitmapMaterial = new AGALPhongBitmapMaterial( headTexture );
//			head.material = agalPhongBitmapMaterial;
		}

		private function testHardCodedPb3dMaterials():void {
			// PB3D materials
//			var phongBitmapMaterial:PB3DPhongBitmapMaterial = new PB3DPhongBitmapMaterial(headTexture);
//			var phongBitmapMapMaterial:PB3DPhongBitmapMapMaterial = new PB3DPhongBitmapMapMaterial(headTexture, headNormalMapTexture, headSpecularMapTexture);
//			var phongToonMaterial:PB3DPhongToonMaterial = new PB3DPhongToonMaterial();
//			var enviroSphericalMaterial:PB3DEnviroSphericalMaterial = new PB3DEnviroSphericalMaterial(envPosX);
//			head.material = enviroSphericalMaterial
		}
	}
}
