package com.li.minimole.materials.agal.vo.registers
{

	import com.li.minimole.materials.agal.vo.registers.AGALRegister;

	public class Varying extends AGALRegister
	{
		public function Varying( name:String ) {
			super( name );
			registerPrefix = "v";
		}
	}
}
