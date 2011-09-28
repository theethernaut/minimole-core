package examples
{

	import com.li.minimole.materials.EnviroSphericalMaterial;
	import com.li.minimole.materials.GouraudColorMaterial;
	import com.li.minimole.materials.PhongBitmapMapMaterial;
	import com.li.minimole.materials.PhongBitmapMaterial;
	import com.li.minimole.materials.PhongToonMaterial;

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
			envPosX = new EnvPosX().bitmapData;
			envNegX = new EnvNegX().bitmapData;
			envPosY = new EnvPosY().bitmapData;
			envNegY = new EnvNegY().bitmapData;
			envPosZ = new EnvPosZ().bitmapData;
			envNegZ = new EnvNegZ().bitmapData;

			var phongBitmapMaterial:PhongBitmapMaterial = new PhongBitmapMaterial(headTexture);
			var phongBitmapMapMaterial:PhongBitmapMapMaterial = new PhongBitmapMapMaterial(headTexture, headNormalMapTexture, headSpecularMapTexture);
			var phongToonMaterial:PhongToonMaterial = new PhongToonMaterial();
			var enviroSphericalMaterial:EnviroSphericalMaterial = new EnviroSphericalMaterial(envPosX);

			head.material = enviroSphericalMaterial;
		}
	}
}
