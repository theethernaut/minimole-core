package com.li.minimole.materials.agal.vo.registers
{

	import com.li.minimole.materials.agal.vo.registers.AGALRegister;

	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;

	public class FragmentSampler extends AGALRegister
	{
		public var texture:Texture;
		public function FragmentSampler( name:String = "", bitmap:BitmapData = null ) {
			registerPrefix = "fs";
			super( name, bitmap );
		}
	}
}
