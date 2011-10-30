package com.li.minimole.materials.agal
{

	import com.li.minimole.core.Core3D;
	import com.li.minimole.core.Mesh;
	import com.li.minimole.core.utils.TextureUtils;
	import com.li.minimole.lights.PointLight;

	import flash.display.BitmapData;

	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.textures.Texture;

	import flash.geom.Matrix3D;

	public class AGALBitmapMaterial extends AGALMaterialBase
	{
		private var _bmd:BitmapData;
		private var _texture:Texture;

		public function AGALBitmapMaterial( bitmapData:BitmapData )
		{
			super();

			_bmd = TextureUtils.ensurePowerOf2( bitmapData );
		}

		override protected function buildProgram3d():void
		{
			// define shader
			var vertexAGAL:String = "" +
					"mov v0, va1 \n" +
					"m44 op, va0, vc0 \n ";
			var fragmentAGAL:String = "" +
					"tex ft1, v0, fs0<2d, linear, nomip> \n" +
					"mov oc, ft1 \n";

			initAGAL( vertexAGAL, fragmentAGAL );

			// Build texture.
			_texture = _context3d.createTexture( _bmd.width, _bmd.height, Context3DTextureFormat.BGRA, false );
			_texture.uploadFromBitmapData( _bmd );
		}

		override public function drawMesh( mesh:Mesh, light:PointLight ):void
		{
			_context3d.setProgram( _program3d );

			// set model-view-projection matrix ( vc0 )
			var modelViewProjectionMatrix:Matrix3D = new Matrix3D();
			modelViewProjectionMatrix.append( mesh.transform );
			modelViewProjectionMatrix.append( Core3D.instance.camera.viewProjectionMatrix );
			_context3d.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, modelViewProjectionMatrix, true );

			// set vertex positions ( va0 )
			_context3d.setVertexBufferAt( 0, mesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );

			// set vertex uv's ( va1 )
			_context3d.setVertexBufferAt( 1, mesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 );

			// set texture ( fs0 )
			_context3d.setTextureAt( 0, _texture );

			// draw
			_context3d.drawTriangles( mesh.indexBuffer );
		}

		override public function deactivate():void
		{
			_context3d.setTextureAt( 0, null );
			_context3d.setVertexBufferAt( 0, null );
			_context3d.setVertexBufferAt( 1, null );
		}
	}
}
