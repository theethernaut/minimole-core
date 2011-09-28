package examples
{

	import com.li.minimole.core.Mesh;
	import com.li.minimole.materials.GouraudColorMaterial;
	import com.li.minimole.parsers.ObjParser;

	import flash.display.BitmapData;

	public class HeadExampleBase extends ExampleBase
	{
		// Texture.
		[Embed(source="assets/head/Map-COL.jpg")]
		private var HeadTexture:Class;

		// Normal map.
		[Embed(source="assets/head/Infinite-Level_02_World_SmoothUV.jpg")]
		private var HeadNormalMap:Class;

		// Specular map.
		[Embed(source="assets/head/Map-spec.jpg")]
		private var HeadSpecularMap:Class;

		// Model.
		[Embed (source="assets/head/head.obj", mimeType="application/octet-stream")]
		private var HeadModel:Class;

		public var head:Mesh;
		public var headTexture:BitmapData;
		public var headNormalMapTexture:BitmapData;
		public var headSpecularMapTexture:BitmapData;

		public function HeadExampleBase()
		{
			super();
		}

		override protected function onPostInit():void
		{
			// load materials
			headTexture = new HeadTexture().bitmapData;
        	headNormalMapTexture = new HeadNormalMap().bitmapData;
        	headSpecularMapTexture = new HeadSpecularMap().bitmapData;

			// load head
			head = new ObjParser(HeadModel, new GouraudColorMaterial(), 0.2);
			view.scene.addChild(head);
		}
	}
}
