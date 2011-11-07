package com.li.minimole.materials.agal.vo.registers
{

	import com.li.minimole.materials.agal.vo.registers.AGALRegister;

	import flash.display3D.Context3DVertexBufferFormat;

	public class VertexAttribute extends AGALRegister
	{
		public static const POSITIONS:String = "POSITIONS BUFFER";
		public static const NORMALS:String = "NORMALS BUFFER";
		public static const UVS:String = "UV BUFFER";

		public var format:String;
		public function VertexAttribute( name:String = "", type:String = "" ) {

			super( name, type );
			refreshFormat();
			registerPrefix = "va";
		}

		public function refreshFormat():void {
			switch( value ) {
				case POSITIONS: {
					this.format = Context3DVertexBufferFormat.FLOAT_3;
					break;
				}
				case NORMALS: {
					this.format = Context3DVertexBufferFormat.FLOAT_3;
					break;
				}
				case UVS: {
					this.format = Context3DVertexBufferFormat.FLOAT_2;
					break;
				}
				default: {
					throw new Error( "Unrecognized vertex attribute type." );
				}
			}
		}

		override public function toStringExtended():String {
			return registerPrefix + registerIndex + ", " + name + " - " + value + ", " + format;
		}
	}
}
