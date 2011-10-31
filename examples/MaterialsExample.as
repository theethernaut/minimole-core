package examples
{

	import com.li.minimole.materials.agal.AGALBitmapMaterial;
	import com.li.minimole.materials.agal.AGALColorMaterial;
	import com.li.minimole.materials.agal.AGALPhongColorMaterial;
	import com.li.minimole.materials.pb3d.PB3DEnviroSphericalMaterial;
	import com.li.minimole.materials.pb3d.PB3DGouraudColorMaterial;
	import com.li.minimole.materials.pb3d.PB3DPhongBitmapMapMaterial;
	import com.li.minimole.materials.pb3d.PB3DPhongBitmapMaterial;
	import com.li.minimole.materials.pb3d.PB3DPhongToonMaterial;

	import flash.display.BitmapData;

	public class MaterialsExample extends HeadExampleBase
	{
		// Env map.
		[Embed (source="assets/cubemap_brightday1/brightday1_positive_x.png")]
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
		public var envNegZ:BitmapData;

		public function MaterialsExample()
		{
			super();
		}

		override protected function onPostInit():void
		{
			super.onPostInit();

			// load cube map textures
//			envPosX = new EnvPosX().bitmapData;
//			envNegX = new EnvNegX().bitmapData;
//			envPosY = new EnvPosY().bitmapData;
//			envNegY = new EnvNegY().bitmapData;
//			envPosZ = new EnvPosZ().bitmapData;
//			envNegZ = new EnvNegZ().bitmapData;

			// PB3D materials
//			var phongBitmapMaterial:PB3DPhongBitmapMaterial = new PB3DPhongBitmapMaterial(headTexture);
//			var phongBitmapMapMaterial:PB3DPhongBitmapMapMaterial = new PB3DPhongBitmapMapMaterial(headTexture, headNormalMapTexture, headSpecularMapTexture);
//			var phongToonMaterial:PB3DPhongToonMaterial = new PB3DPhongToonMaterial();
//			var enviroSphericalMaterial:PB3DEnviroSphericalMaterial = new PB3DEnviroSphericalMaterial(envPosX);

			// AGAL materials
//			var agalBitmapMaterial:AGALBitmapMaterial = new AGALBitmapMaterial( headTexture );
//			var agalColorMaterial:AGALColorMaterial = new AGALColorMaterial( 0x00FF00 );
			var agalPhongColorMaterial:AGALPhongColorMaterial = new AGALPhongColorMaterial( 0xFF0000 );

			head.material = agalPhongColorMaterial;

//			head.forceVertexNormalsToTriangleNormals();
		}
	}
}
