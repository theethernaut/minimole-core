package
com.li.minimole.core.utils
{
import com.adobe.pixelBender3D.*;

/*
    Utility for tracing out PB3D stuff.
 */
public class PB3DUtil
{
    public function PB3DUtil()
    {
    }

    // ---------------------------------------------------------------------
    // General.
    // ---------------------------------------------------------------------

    public static function tracePB3DVersion():void
    {
        var v:Version = new Version();
        trace("PB3D Version - major: " + v.major + ", minor: " + v.minor);
    }

    // ---------------------------------------------------------------------
    // Programs.
    // ---------------------------------------------------------------------

    public static function traceAgalProgramPair(programPair:AGALProgramPair):void
    {
        trace("------------------------------------------------------------------------");
        trace("- AgalProgramPair -");
        trace("------------------------------------------------------------------------");

        trace("  vertexProgram:");
        traceAgalProgram(programPair.vertexProgram);
        trace("  fragmentProgram:");
        traceAgalProgram(programPair.fragmentProgram);
    }

    public static function traceAgalProgram(program:AGALProgram):void
    {
        trace("    - AgalProgram -");

        trace("      name: >>>" + program.name + "<<<");
        trace("      temp. register count: " + program.temporaryRegisterCount);
        trace("      byteCode: " + program.byteCode);
        trace("      registers: ");
        traceRegisterMap(program.registers)
    }

    // ---------------------------------------------------------------------
    // RegisterMap.
    // ---------------------------------------------------------------------

    public static function traceRegisterMap(registerMap:RegisterMap):void
    {
        trace("        - RegisterMap -");

        var i:uint;

        trace("          numericalConstants: ");
        traceNumericalConstantsInfo(registerMap.numericalConstants);

        if(registerMap.inputVertexRegisters)
        {
            trace("          vertexRegisters: " + registerMap.inputVertexRegisters.length);
            for(i = 0; i < registerMap.inputVertexRegisters.length; i++)
                traceVertexRegisterInfo(registerMap.inputVertexRegisters[i]);
        }

        if(registerMap.parameterRegisters)
        {
            trace("          parameterRegisters: " + registerMap.parameterRegisters.length);
            for(i = 0; i < registerMap.parameterRegisters.length; i++)
                traceParameterRegisterInfo(registerMap.parameterRegisters[i]);
        }

        if(registerMap.textureRegisters)
        {
            trace("          textureRegisters: " + registerMap.textureRegisters.length);
            for(i = 0; i < registerMap.textureRegisters.length; i++)
                traceTextureRegisterInfo(registerMap.textureRegisters[i]);
        }


    }

    // ---------------------------------------------------------------------
    // RegisterInfo.
    // ---------------------------------------------------------------------

    public static function traceVertexRegisterInfo(info:VertexRegisterInfo):void
    {
        trace("          - VertexRegisterInfo -");

        trace("            globalId: ");
        traceGlobalId(info.globalID);
        trace("            mapIndex: " + info.mapIndex);
//        trace("            inherited: ");
//        traceRegisterInfo(info);
    }

    public static function traceParameterRegisterInfo(info:ParameterRegisterInfo):void
    {
        trace("          - ParameterRegisterInfo -");

        trace("            globalId: ");
        traceGlobalId(info.globalID);
        trace("            elementGroup: ");
        traceRegisterElementGroup(info.elementGroup);
//        trace("            inherited: ");
//        traceRegisterInfo(info);
    }

    public static function traceTextureRegisterInfo(info:TextureRegisterInfo):void
    {
        trace("          - TextureRegisterInfo -");

        trace("            globalId: ");
        traceGlobalId(info.globalID);
        trace("            sampler: " + info.sampler);
//        trace("            inherited: ");
//        traceRegisterInfo(info);
    }

    // ---------------------------------------------------------------------
    // Details.
    // ---------------------------------------------------------------------

    public static function traceNumericalConstantsInfo(info:NumericalConstantInfo):void
    {
        trace("          - NumericalConstantsInfo -");

        trace("            startRegister: " + info.startRegister);
        trace("            values: ");
        for(var i:uint; i < info.values.length; ++i)
        {
            trace("              " + i + ": " + info.values[i]);
        }
    }

    public static function traceGlobalId(id:GlobalID):void
    {
        trace("              - GlobalID -");

        trace("                name: " + id.name);
        trace("                format: " + id.format);
        trace("                semantics: " + id.semantics);
    }

    public static function traceRegisterInfo(info:RegisterInfo):void
    {
        trace("              - RegisterInfo -");

        trace("                name: " + info.name);
        trace("                format: " + info.format);
        trace("                semantics: " + info.semantics);
    }

    public static function traceRegisterElementGroup(group:RegisterElementGroup):void
    {
        trace("              - RegisterElementGroup -");

        trace("                contiguous: " + group.contiguous);
        trace("                nElements: " + group.elements.length);
        trace("                elements: ");
        for each(var element:RegisterElement in group.elements)
            traceRegisterElement(element);
    }

    public static function traceRegisterElement(element:RegisterElement):void
    {
        trace("                  - RegisterElement -");

        trace("                    elementIndex: " + element.elementIndex);
        trace("                    registerIndex: " + element.registerIndex);
        trace("                    isValid: " + element.isValid);
    }
}
}
