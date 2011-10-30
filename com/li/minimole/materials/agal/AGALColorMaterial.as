package com.li.minimole.materials.agal
{

	import com.li.minimole.core.Core3D;
	import com.li.minimole.core.Mesh;
	import com.li.minimole.core.utils.ColorUtils;
	import com.li.minimole.core.vo.RGB;
	import com.li.minimole.lights.PointLight;
	import com.li.minimole.materials.IColorMaterial;

	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;

	import flash.geom.Matrix3D;

	public class AGALColorMaterial extends AGALMaterialBase implements IColorMaterial
	{
		private var _color:Vector.<Number> = Vector.<Number>( [1.0, 1.0, 1.0, 1.0] );

		public function AGALColorMaterial( color:uint = 0xFFFFFF )
		{
			super();

			this.color = color;
		}

		override protected function buildProgram3d():void
		{
			// define shader
			var vertexAGAL:String = "" +
					"m44 op, va0, vc0 \n ";
			var fragmentAGAL:String = "" +
					"mov oc, fc0 \n";

			initAGAL( vertexAGAL, fragmentAGAL );
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

			// set color ( fc0 )
			_context3d.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 0, _color );

			// draw
			_context3d.drawTriangles( mesh.indexBuffer );
		}

		override public function deactivate():void
		{
			_context3d.setVertexBufferAt( 0, null );
		}

		public function get color():uint
		{
			return _color[0] * 255 << 16 | _color[1] * 255 << 8 | _color[2] * 255;
		}

		public function set color( value:uint ):void
		{
			var rgb:RGB = ColorUtils.hexToRGB( value );
			_color = Vector.<Number>( [rgb.r / 255, rgb.g / 255, rgb.b / 255, 1.0] );
		}
	}
}
