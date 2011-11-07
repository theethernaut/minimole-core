package com.li.minimole.materials.agal.vo.registers
{

	public class AGALRegister
	{
		public var name:String;
		public var value:*;
		public var registerPrefix:String;
		public var registerIndex:int = -1;
		public var registerComps:String = "";

		public function AGALRegister( name:String = "", value:* = null ) {
			this.name = name;
			this.value = value;
		}

		public function toString():String {
			return registerIndex != -1 ? registerPrefix + registerIndex + registerComps : registerPrefix;
		}

		public function toStringExtended():String {
			return registerPrefix + registerIndex + ", " + name;
		}

		public function cloneRegister():AGALRegister {
			var clone:AGALRegister = new AGALRegister( name, value );
			clone.registerPrefix = registerPrefix;
			clone.registerIndex = registerIndex;
			clone.registerComps = registerComps;
			return clone;
		}

		// -----------------------
		// components
		// -----------------------

		public function get w():AGALRegister {
			registerComps = ".w";
			return cloneRegister();
		}

		public function get z():AGALRegister {
			registerComps = ".z";
			return cloneRegister();
		}

		public function get xxx():AGALRegister {
			registerComps = ".xxx";
			return cloneRegister();
		}

		public function get y():AGALRegister {
			registerComps = ".y";
			return cloneRegister();
		}

		public function get x():AGALRegister {
			registerComps = ".x";
			return cloneRegister();
		}

		public function get xyz():AGALRegister {
			registerComps = ".xyz";
			return cloneRegister();
		}
	}
}
