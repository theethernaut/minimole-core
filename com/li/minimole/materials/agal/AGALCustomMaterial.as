package com.li.minimole.materials.agal {

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

	public class AGALCustomMaterial extends AGALMaterialBase {
		private var _textures:Vector.<Texture>;
		private var _bmds:Vector.<BitmapData>;
		private var _vertexConstants:Vector.<Vector.<Number>>;
		private var _fragmentConstants:Vector.<Vector.<Number>>;
		private var _vertexAGAL:String;
		private var _fragmentAGAL:String;
		private var _requiresNormalsBuffer:Boolean;
		private var _requiresUVBuffer:Boolean;
		private var _requiresMeshTransform:Boolean;
		private var _requiresMeshReducedTransform:Boolean;

		public function AGALCustomMaterial() {
			super();
		}

		override protected function buildProgram3d():void {
			initAGAL( _vertexAGAL, _fragmentAGAL );
			if( _bmds != null ) {
				var len:uint = _bmds.length;
				_textures = new Vector.<Texture>();
				for( var i:uint; i < len; i++ ) {
					var bmd:BitmapData = _bmds[i ];
					var texture:Texture = _context3d.createTexture( bmd.width, bmd.height, Context3DTextureFormat.BGRA, false );
					texture.uploadFromBitmapData( bmd );
					_textures.push( texture );
				}
			}
		}

		override public function drawMesh( mesh:Mesh, light:PointLight ):void {
			if( !_isProgramValid ) {
				return;
			}

			var i:uint, len:uint;

			_context3d.setProgram( _program3d );

			// set fragment constants
			if( _fragmentConstants != null ) {
				len = _fragmentConstants.length;
				for( i = 0; i < len; ++i ) {
					_context3d.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, i, _fragmentConstants[ i ] );
				}
			}

			// set vertex constants
			var modelViewProjectionMatrix:Matrix3D = new Matrix3D();
			modelViewProjectionMatrix.append( mesh.transform );
			modelViewProjectionMatrix.append( Core3D.instance.camera.viewProjectionMatrix );
			var vcOffset:uint = 4;
			_context3d.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, modelViewProjectionMatrix, true ); // mvc - vc0 to vc3
			if( _requiresMeshTransform ) {
				vcOffset += 4;
				_context3d.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, vcOffset, mesh.transform, true ); // transform - vc4 to vc7
			}
			if( _requiresMeshReducedTransform ) {
				vcOffset += 4;
				_context3d.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, vcOffset, mesh.reducedTransform, true );// reduced transform - vc8 to vc11
			}
			if( _vertexConstants != null ) {
				len = _vertexConstants.length;
				for( i = 0; i < len; ++i ) {
					_context3d.setProgramConstantsFromVector( Context3DProgramType.VERTEX, vcOffset + i, _vertexConstants[ i ] );
				}
			}

			// set vertex attributes
			var vaIndex:uint;
			_context3d.setVertexBufferAt( vaIndex, mesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 ); // positions - va0
			if( _requiresNormalsBuffer ) {
				vaIndex++;
				_context3d.setVertexBufferAt( vaIndex, mesh.normalsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 ); // normals - va1
			}
			if( _requiresUVBuffer ) {
				vaIndex++;
				_context3d.setVertexBufferAt( vaIndex, mesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 ); // uvs - va2
			}

			// set textures
			if( _textures != null ) {
				len = _textures.length;
				for( i = 0; i < len; ++i ) {
					_context3d.setTextureAt( i, _textures[ i ] );
				}
			}

			// draw
			try {
				_context3d.drawTriangles( mesh.indexBuffer );
			}
			catch( e:Error ) {
				trace( "Draw triangles failed: " + e.message );
			}
		}

		override public function deactivate():void {
			var i:uint;

			// clear textures
			if( _textures != null ) {
				var len:uint = _textures.length;
				for( i = 0; i < len; ++i ) {
					_context3d.setTextureAt( i, null );
				}
			}

			// clear vertex attributes
			var vaIndex:uint;
			_context3d.setVertexBufferAt( vaIndex, null );
			if( _requiresNormalsBuffer ) {
				vaIndex++;
				_context3d.setVertexBufferAt( vaIndex, null );
			}
			if( _requiresMeshReducedTransform ) {
				vaIndex++;
				_context3d.setVertexBufferAt( vaIndex, null );
			}
		}

		public function addTexture( bitmapData:BitmapData ):void {
			if( _bmds == null ) {
				_bmds = new Vector.<BitmapData>();
			}
			bitmapData = TextureUtils.ensurePowerOf2( bitmapData );
			_bmds.push( bitmapData );
		}

		public function addVertexConstant( float4:Vector.<Number> ):void {
			if( _vertexConstants == null ) {
				_vertexConstants = new Vector.<Vector.<Number>>();
			}
			_vertexConstants.push( float4 );
		}

		public function getVertexConstantByIndex( index:uint ):Vector.<Number> {
			return _vertexConstants[ index ];
		}

		public function setVertexConstantByIndex( float4:Vector.<Number>, index:uint ):void {
			_vertexConstants[ index ] = float4;
		}

		public function addFragmentConstant( float4:Vector.<Number> ):void {
			if( _fragmentConstants == null ) {
				_fragmentConstants = new Vector.<Vector.<Number>>();
			}
			_fragmentConstants.push( float4 );
		}

		public function getFragmentConstantByIndex( index:uint ):Vector.<Number> {
			return _fragmentConstants[ index ];
		}

		public function setFragmentConstantByIndex( float4:Vector.<Number>, index:uint ):void {
			_fragmentConstants[ index ] = float4;
		}

		public function setAGALDefinitions( vertexAGAL:String, fragmentAGAL:String ):void {
			_vertexAGAL = vertexAGAL;
			_fragmentAGAL = fragmentAGAL;
		}

		public function set requiresNormalsBuffer( value:Boolean ):void {
			_requiresNormalsBuffer = value;
		}

		public function set requiresUVBuffer( value:Boolean ):void {
			_requiresUVBuffer = value;
		}

		public function set requiresMeshTransform( value:Boolean ):void {
			_requiresMeshTransform = value;
		}

		public function set requiresMeshReducedTransform( value:Boolean ):void {
			_requiresMeshReducedTransform = value;
		}
	}
}
