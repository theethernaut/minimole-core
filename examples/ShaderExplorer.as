package examples
{
import com.li.minimole.camera.controller.MKSOCameraController;
import com.li.minimole.core.Core3D;
import com.li.minimole.core.Mesh;
import com.li.minimole.core.View3D;

import com.li.minimole.core.utils.MeshUtils;
import com.li.minimole.materials.BitmapMaterial;
import com.li.minimole.materials.DepthColorMaterial;
import com.li.minimole.materials.WireframeMaterial;
import com.li.minimole.materials.EnviroCubicalMaterial;
import com.li.minimole.materials.EnviroSphericalMaterial;
import com.li.minimole.materials.GouraudColorMaterial;
import com.li.minimole.materials.IColorMaterial;
import com.li.minimole.materials.MaterialBase;
import com.li.minimole.materials.NormalsColorMaterial;
import com.li.minimole.materials.PhongBitmapMapMaterial;
import com.li.minimole.materials.PhongBitmapMaterial;
import com.li.minimole.materials.PhongColorMapMaterial;
import com.li.minimole.materials.PhongColorMaterial;
import com.li.minimole.materials.ColorMaterial;
import com.li.minimole.materials.PhongToonMaterial;
import com.li.minimole.materials.VertexColorMaterial;
import com.li.minimole.materials.XRayMaterial;
import com.li.minimole.parsers.ObjParser;

import com.li.minimole.primitives.Plane;
import com.li.minimole.primitives.Sphere;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.utils.setTimeout;

import uk.co.soulwire.gui.SimpleGUI;

[SWF(width="1280", height="768", backgroundColor="0x000000", frameRate="30")]
public class ShaderExplorer extends Sprite
{
    // Texture.
    [Embed(source="assets/head/Map-COL.jpg")]
    private var TextureImage:Class;

    // Normal map.
    [Embed(source="assets/head/Infinite-Level_02_World_SmoothUV.jpg")]
    private var NormalMap:Class;

    // Specular map.
    [Embed(source="assets/head/Map-spec.jpg")]
    private var SpecularMapImage:Class;

    // Model.
    [Embed (source="assets/head/head.obj", mimeType="application/octet-stream")]
    private var Model:Class;

    // Env map.
    [Embed (source="assets/cubemap_brightday1/brightday1_positive_x.png")]
    private var EnvPosX:Class;
    [Embed (source="assets/cubemap_brightday1/brightday1_negative_x.png")]
    private var EnvNegX:Class;
    [Embed (source="assets/cubemap_brightday1/brightday1_positive_y.png")]
    private var EnvPosY:Class;
    [Embed (source="assets/cubemap_brightday1/brightday1_negative_y.png")]
    private var EnvNegY:Class;
    [Embed (source="assets/cubemap_brightday1/brightday1_positive_z.png")]
    private var EnvPosZ:Class;
    [Embed (source="assets/cubemap_brightday1/brightday1_negative_z.png")]
    private var EnvNegZ:Class;

    public var view:View3D;
    public var mesh:Mesh;
    public var lightFollow:Boolean = true;
    public var rotateModel:Boolean = false;

    private var _cameraController:MKSOCameraController;
    private var _gui:SimpleGUI;

    private var _lightColorMaterial:ColorMaterial; // For the light dummy.

    private var _phongToonMaterial:PhongToonMaterial;
    private var _vertexColorMaterial:VertexColorMaterial;
    private var _colorMaterial:ColorMaterial;
    private var _depthColorMaterial:DepthColorMaterial;
    private var _normalsColorMaterial:NormalsColorMaterial;
    private var _gouraudColorMaterial:GouraudColorMaterial;
    private var _phongColorMaterial:PhongColorMaterial;
    private var _phongColorMapMaterial:PhongColorMapMaterial;
    private var _bitmapMaterial:BitmapMaterial;
    private var _phongBitmapMaterial:PhongBitmapMaterial;
    private var _phongBitmapMapMaterial:PhongBitmapMapMaterial;
    private var _enviroCubicalMaterial:EnviroCubicalMaterial;
    private var _enviroSphericalMaterial:EnviroSphericalMaterial;
    private var _xRayMaterial:XRayMaterial;
    private var _wireframeMaterial:WireframeMaterial;

    private var _normalsForced:Boolean;
    private var _counter:Number = 0;
    private var _lightTracer:Sphere;
    private var _bgPlane:Plane;

    private const USE_BG_PLANE:Boolean = false;
    private const USE_LIGHT_TRACER:Boolean = false;

    public function ShaderExplorer()
    {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(evt:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);

        // Init stage.
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        // Init 3d view.
        view = new View3D();
        addChild(view);

        // Set light.
        view.scene.light.color    = 0xFFFFFF;
        view.scene.light.ambient  = 0.0;
        view.scene.light.diffuse  = 0.8;
        view.scene.light.specular = 0.5;
        view.scene.light.concentration = 25;

        // Textures for bitmap materials.
        var texture:BitmapData = new TextureImage().bitmapData;
        var normalMap:BitmapData = new NormalMap().bitmapData;
        var specularMap:BitmapData = new SpecularMapImage().bitmapData;
        var envPosX:BitmapData = new EnvPosX().bitmapData;
        var envNegX:BitmapData = new EnvNegX().bitmapData;
        var envPosY:BitmapData = new EnvPosY().bitmapData;
        var envNegY:BitmapData = new EnvNegY().bitmapData;
        var envPosZ:BitmapData = new EnvPosZ().bitmapData;
        var envNegZ:BitmapData = new EnvNegZ().bitmapData;

        // Turn on/off shader debugging.
        Core3D.instance.debugShaders = true;

        // Color materials.
        _colorMaterial = new ColorMaterial();
//        _depthColorMaterial = new DepthColorMaterial();
//        _normalsColorMaterial = new NormalsColorMaterial();
        _gouraudColorMaterial = new GouraudColorMaterial();
        _phongColorMaterial = new PhongColorMaterial();
//        _phongColorMapMaterial = new PhongColorMapMaterial(0xFFFFFF, normalMap);
//        _bitmapMaterial = new BitmapMaterial(texture);
//        _phongBitmapMaterial = new PhongBitmapMaterial(texture);
//        _phongBitmapMapMaterial = new PhongBitmapMapMaterial(texture, normalMap, specularMap);
//        _enviroCubicalMaterial = new EnviroCubicalMaterial(envPosX, envNegX, envPosY, envNegY, envPosZ, envNegZ);
//        _enviroSphericalMaterial = new EnviroSphericalMaterial(envPosX);
//        _vertexColorMaterial = new VertexColorMaterial();
//        _phongToonMaterial = new PhongToonMaterial(0xFFFFFF, 6);
//        _xRayMaterial = new XRayMaterial();
//        _wireframeMaterial = new WireframeMaterial();

        // Bg plane.
        // We need to use a plane because hardware 3d is always beneath all other layers.
        if(USE_BG_PLANE)
        {
            var bgPlaneMat:BitmapMaterial = new BitmapMaterial(generateCheckerboardImage());
            bgPlaneMat.bothsides = true;
            _bgPlane = new Plane(bgPlaneMat, 50, 50);
            view.scene.addChild(_bgPlane);
        }

        // Model.
        mesh = new ObjParser(Model, _gouraudColorMaterial, 0.2);
        MeshUtils.prepareMeshForWireframe(mesh);
        view.scene.addChild(mesh);

        // Dummy light.
        if(USE_LIGHT_TRACER)
        {
            _lightColorMaterial = new ColorMaterial(view.scene.light.color);
            _lightTracer = new Sphere(_lightColorMaterial, 0.01, 8, 6);
            view.scene.addChild(_lightTracer);
        }

        // Init camera controller.
        _cameraController = new MKSOCameraController(view.camera);
        addChildAt(_cameraController, 0);

        // Start loop.
        addEventListener(Event.ENTER_FRAME, enterframeHandler);

        // GUI.
        _gui = new SimpleGUI(this);
        _gui.addGroup("Mesh:"); // Mesh.
        _gui.addSlider("mesh.x", -2, 2, {label:"x"});
        _gui.addSlider("mesh.y", -2, 2, {label:"y"});
        _gui.addSlider("mesh.z", -2, 2, {label:"z"});
        _gui.addSlider("mesh.rotationDegreesX", -180, 180, {label:"rotx"});
        _gui.addSlider("mesh.rotationDegreesY", -180, 180, {label:"roty"});
        _gui.addSlider("mesh.rotationDegreesZ", -180, 180, {label:"rotz"});
        _gui.addGroup("Light:");
        _gui.addSlider("view.scene.light.ambient", 0, 1, {label:"ambient"});
        _gui.addSlider("view.scene.light.diffuse", 0, 1, {label:"diffuse"});
        _gui.addSlider("view.scene.light.specular", 0, 1, {label:"specular"});
        _gui.addSlider("view.scene.light.concentration", 1, 200, {label:"concentration"});
        _gui.addColour("lightColor", {label:"color"});
        _gui.addGroup("Material:"); // Material.
        var mats:Array = [
            {label:"ColorMaterial",	         data:_colorMaterial},
//            {label:"DepthColorMaterial",	 data:_depthColorMaterial}, // TODO: Broken in PB3D 0.2
//            {label:"NormalsMaterial",	     data:_normalsColorMaterial},
            {label:"GouraudColorMaterial",   data:_gouraudColorMaterial},
            {label:"PhongColorMaterial",     data:_phongColorMaterial},
//            {label:"PhongColorMapMaterial",  data:_phongColorMapMaterial},
//            {label:"BitmapMaterial",         data:_bitmapMaterial},
//            {label:"PhongBitmapMaterial",    data:_phongBitmapMaterial},
//            {label:"PhongBitmapMapMaterial", data:_phongBitmapMapMaterial},
            /*{label:"EnviroCubicalMaterial",         data:_enviroMaterial},*/ // TODO: CubeMaps not yet supported in PB3D.
//            {label:"VertexColorMaterial",    data:_vertexColorMaterial},
//            {label:"PhongToonMaterial",      data:_phongToonMaterial},
//            {label:"EnviroSphericalMaterial",   data:_enviroSphericalMaterial}, // TODO: PB3D bug.
//            {label:"XRayMaterial",           data:_xRayMaterial},
//            {label:"WireframeMaterial",           data:_wireframeMaterial}
        ];
        _gui.addComboBox("meshMaterial", mats, {width:150, numVisibleItems:mats.length});
        _gui.addColour("materialColor");
        _gui.addGroup("Options:"); // Options.
        _gui.addToggle("rotateModel", {label:"spin model"});
        _gui.addToggle("forceNormals", {label:"hard normals (if a normal map is not used)"});
        _gui.addToggle("lightFollow", {label:"light follows camera (if light is used)"});
        setTimeout(showGUi, 1000);
    }

    private function showGUi():void
    {
        _gui.show();
    }

    public function get lightColor():uint
    {
        return view.scene.light.color;
    }
    public function set lightColor(value:uint):void
    {
        view.scene.light.color = value;
        _lightColorMaterial.color = value;
    }

    public function get materialColor():uint
    {
        if(mesh.material is IColorMaterial)
            return IColorMaterial(mesh.material).color;
        else
            return 0;
    }
    public function set materialColor(value:uint):void
    {
        if(mesh.material is IColorMaterial)
            IColorMaterial(mesh.material).color = value;
    }

    public function set forceNormals(value:Boolean):void
    {
        if(_normalsForced)
            mesh.restoreNormals();
        else
            mesh.forceNormals();
        mesh.updateNormalsBuffer();
        _normalsForced = value;
    }
    public function get forceNormals():Boolean
    {
        return _normalsForced;
    }

    public function set meshMaterial(value:MaterialBase):void
    {
        mesh.material = value;
        _gui.update();
    }
    public function get meshMaterial():MaterialBase
    {
        return mesh.material;
    }

    private function enterframeHandler(evt:Event):void
    {
        // Update model position.
        if(rotateModel)
            mesh.rotationDegreesY += 1;

        // Update camera position.
        _cameraController.update();

        // Make sure the plane looks 2D.
        if(USE_BG_PLANE)
        {
            var camPos:Vector3D = view.camera.position.clone();
            camPos.negate();
            camPos.scaleBy(5);
            _bgPlane.position = camPos;
            _bgPlane.scaleX = _bgPlane.scaleY = _bgPlane.scaleZ = view.camera.position.length/2;
            _bgPlane.lookAt(new Vector3D());
        }

        // Update light.
        if(lightFollow)
            view.scene.light.position = view.camera.position;
        else
        {
            _counter -= 0.025;
            view.scene.light.x = -1.5*Math.cos(_counter);
            view.scene.light.z = 1.5*Math.sin(_counter);
        }

        // Update light tracer position.
        if(USE_LIGHT_TRACER)
        {
            _lightTracer.position = view.scene.light.position;
        }

        // Render scene.
        view.render();
    }

    private function generateCheckerboardImage(cellSize:uint = 50, imageWidth:Number = 2048, imageHeight:Number = 2048, color1:uint = 0xCCCCCC, color2:uint = 0x000000):BitmapData
    {
        // draw 4 x 4 bitmap cells of alternating colors
        var pattern:BitmapData = new BitmapData(cellSize*2, cellSize*2, false);
        pattern.fillRect(new Rectangle(0, 0, cellSize, cellSize), color1);
        pattern.fillRect(new Rectangle(cellSize, 0, cellSize, cellSize), color2);
        pattern.fillRect(new Rectangle(0, cellSize, cellSize, cellSize), color2);
        pattern.fillRect(new Rectangle(cellSize, cellSize, cellSize, cellSize), color1);

        // fill entire area with of bitmap pattern
        var board:Sprite = new Sprite();
        board.graphics.beginBitmapFill(pattern);
        board.graphics.drawRect(0, 0, imageWidth, imageHeight);
        board.graphics.endFill();

        // Draw image.
        var image:BitmapData = new BitmapData(imageWidth, imageHeight, false, 0x000000);
        image.draw(board);
        return image;
    }
}
}
