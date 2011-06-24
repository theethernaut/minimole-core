package com.li.minimole.materials
{
import com.li.minimole.core.Core3D;
import com.li.minimole.core.Mesh;
import com.li.minimole.core.utils.PB3DUtil;
import com.li.minimole.debugging.errors.AbstractMethodCalledError;

import com.li.minimole.lights.PointLight;

import flash.display3D.Context3D;
import flash.display3D.Program3D;

import com.adobe.pixelBender3D.*;
import com.adobe.pixelBender3D.utils.*;

import flash.utils.ByteArray;

/*
    Base class for single shader materials.
 */
public class MaterialBase
{
    public var transparent:Boolean = false;
    public var bothsides:Boolean = false;
    public var textureBased:Boolean = false;

    protected var _context3d:Context3D;
    protected var _program3d:Program3D;

    protected var _vertexRegisterMap:RegisterMap;
    protected var _fragmentRegisterMap:RegisterMap;
    protected var _parameterBufferHelper:ProgramConstantsHelper;

    private var _programBuilt:Boolean;

    public function MaterialBase()
    {
    }

    public function set context3d(context3d:Context3D):void
    {
        _context3d = context3d;

        if(!_programBuilt)
            buildProgram3d();
    }
    public function get context3d():Context3D
    {
        return _context3d;
    }

    protected function buildProgram3d():void
    {
        throw new AbstractMethodCalledError();
    }

    public function drawMesh(mesh:Mesh, light:PointLight):void
    {
        throw new AbstractMethodCalledError();
    }

    public function deactivate():void
    {
        throw new AbstractMethodCalledError();
    }

    protected function initPB3D(VertexClass:Class, MaterialClass:Class, FragmentClass:Class):void
    {
        // Build program.
        _program3d = _context3d.createProgram();
        var vertexProgram:PBASMProgram   = new PBASMProgram(readPBASMClass(VertexClass));
        var materialProgram:PBASMProgram = new PBASMProgram(readPBASMClass(MaterialClass));
        var fragmentProgram:PBASMProgram = new PBASMProgram(readPBASMClass(FragmentClass));
        var programs:AGALProgramPair = PBASMCompiler.compile(vertexProgram, materialProgram, fragmentProgram);

        // Set up param utils.
        _vertexRegisterMap = programs.vertexProgram.registers;
        _fragmentRegisterMap = programs.fragmentProgram.registers;
        _parameterBufferHelper = new ProgramConstantsHelper(_context3d, _vertexRegisterMap, _fragmentRegisterMap);

        if(Core3D.instance.debugShaders)
            PB3DUtil.traceAgalProgramPair(programs);

        // build shader.
        _program3d.upload(programs.vertexProgram.byteCode, programs.fragmentProgram.byteCode);

        // Report build.
        _programBuilt = true;
    }

    private function readPBASMClass(f:Class):String
    {
        var bytes:ByteArray = new f();
        return bytes.readUTFBytes(bytes.bytesAvailable);
    }
}
}
