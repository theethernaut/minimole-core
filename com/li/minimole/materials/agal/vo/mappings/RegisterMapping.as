package com.li.minimole.materials.agal.vo.mappings
{

	public class RegisterMapping
	{
		public static const MVC_MAPPING:String = "MVC_MAPPING";
		public static const TRANSFORM_MAPPING:String = "TRANSFORM_MAPPING";
		public static const REDUCED_TRANSFORM_MAPPING:String = "REDUCED_TRANSFORM_MAPPING";
		public static const CAMERA_MAPPING:String = "CAMERA_MAPPING";
		public static const POSITION_MAPPING:String = "POSITION_MAPPING";
		public static const FUNCTION_MAPPING:String = "FUNCTION_MAPPING";
		public static const OSCILLATOR_MAPPING:String = "OSCILLATOR_MAPPING";

		public var target:*;
		public var type:String;

		public function RegisterMapping( type:String, target:* = null ) {

			this.type = type;
			this.target = target;

			if( type == OSCILLATOR_MAPPING ) {
				var counter:Number = 0;
				this.target = function():Vector.<Number> {
					counter += 0.1;
					var x:Number = Math.sin( 0.5 * counter ) * 0.5 + 0.5;
					var y:Number = Math.sin( counter ) * 0.5 + 0.5;
					var z:Number = Math.sin( 2 * counter ) * 0.5 + 0.5;
					var w:Number = Math.sin( 3 * counter ) * 0.5 + 0.5;
					return Vector.<Number>( [ x, y, z, w ] );
				};
			}

		}
	}
}
