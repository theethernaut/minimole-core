package com.li.minimole.materials.agal
{

	import com.li.minimole.core.Core3D;
	import com.li.minimole.core.Mesh;
	import com.li.minimole.core.utils.ColorUtils;
	import com.li.minimole.core.utils.TextureUtils;
	import com.li.minimole.core.utils.VectorUtils;
	import com.li.minimole.core.vo.RGB;
	import com.li.minimole.lights.PointLight;

	import flash.display.BitmapData;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;

	public class AGALPhongBitmapMaterial extends AGALMaterialBase
	{
		private var _bmd:BitmapData;
		private var _texture:Texture;
		private var _specularColor:Vector.<Number>;
		private var _lightProperties:Vector.<Number>;

		public function AGALPhongBitmapMaterial( bitmapData:BitmapData )
		{
			super();

			_bmd = TextureUtils.ensurePowerOf2( bitmapData );
			_specularColor = Vector.<Number>( [1.0, 1.0, 1.0, 1.0] );
			_lightProperties = Vector.<Number>( [0.0, 1.0, 1.0, 5.0] ); // ambient, diffuse, specular, specular concentration multiplier (gloss)
		}

		override protected function buildProgram3d():void
		{
			// define shader
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

			initAGAL( vertexAGAL, fragmentAGAL, false );

			// Build texture.
			_texture = _context3d.createTexture( _bmd.width, _bmd.height, Context3DTextureFormat.BGRA, false );
			_texture.uploadFromBitmapData( _bmd );
		}

		override public function drawMesh( mesh:Mesh, light:PointLight ):void
		{
			if( !_isProgramValid ) {
				return;
			}

			_context3d.setProgram( _program3d );

			// set fragment constants
			_context3d.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 0, VectorUtils.multiply4( _specularColor, light.colorVector ) ); 		// specular color   - fc0
			_context3d.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 1, VectorUtils.multiply4( _lightProperties, light.lightProperties ) ); // light properties - fc1
			_context3d.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 2, Vector.<Number>( [ 1.0, 0.0, 0.0, 0.0 ] ) ); 						// numeric literals - fc2

			// set vertex constants
			var modelViewProjectionMatrix:Matrix3D = new Matrix3D();
			modelViewProjectionMatrix.append( mesh.transform );
			modelViewProjectionMatrix.append( Core3D.instance.camera.viewProjectionMatrix );
			_context3d.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, modelViewProjectionMatrix, true );        // mvc - vc0 to vc3
			_context3d.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 4, mesh.transform, true ); 			        // transform - vc4 to vc7
			_context3d.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 8, mesh.reducedTransform, true );            // reduced transform - vc8 to vc11
			_context3d.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 12, light.positionVector ); 				    // light position   - vc12
			_context3d.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 13, Core3D.instance.camera.positionVector ); // camera position  - vc13

			// set vertex attributes
			_context3d.setVertexBufferAt( 0, mesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 ); // positions - va0
			_context3d.setVertexBufferAt( 1, mesh.normalsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 ); // normals - va1
			_context3d.setVertexBufferAt( 2, mesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 ); // uvs - va2

			// set texture ( fs0 )
			_context3d.setTextureAt( 0, _texture );

			// draw
			try {
				_context3d.drawTriangles( mesh.indexBuffer );
			}
			catch( e:Error ) {
				trace( "Draw triangles failed: " + e.message );
			}
		}

		override public function deactivate():void
		{
			_context3d.setTextureAt( 0, null );
			_context3d.setVertexBufferAt( 0, null );
			_context3d.setVertexBufferAt( 1, null );
			_context3d.setVertexBufferAt( 2, null );
		}

		public function get specularColor():uint
		{
			return _specularColor[0] * 255 << 16 | _specularColor[1] * 255 << 8 | _specularColor[2] * 255;
		}

		public function set specularColor( value:uint ):void
		{
			var rgb:RGB = ColorUtils.hexToRGB( value );
			_specularColor = Vector.<Number>( [rgb.r / 255, rgb.g / 255, rgb.b / 255, 1.0] );
		}
	}
}
