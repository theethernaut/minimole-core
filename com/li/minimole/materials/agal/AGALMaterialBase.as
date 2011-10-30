package com.li.minimole.materials.agal
{

	import com.adobe.utils.AGALMiniAssembler;
	import com.li.minimole.materials.MaterialBase;

	import flash.display3D.Context3DProgramType;

	public class AGALMaterialBase extends MaterialBase
	{
		public function AGALMaterialBase()
		{
			super();
		}

		protected function initAGAL( vertexAGAL:String, fragmentAGAL:String ):void
		{
			// build shader
			_isProgramValid = true;
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX, vertexAGAL );
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT, fragmentAGAL );
			_program3d = _context3d.createProgram();
			try {
				_program3d.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode );
			}
			catch( e:Error ) {
				_isProgramValid = false;
				trace( "AGAL compilation failed: " + e.message );
			}
		}
	}
}
