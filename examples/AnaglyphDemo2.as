package examples
{
import com.bit101.components.Label;
import com.li.minimole.camera.controller.MKSOCameraController;
import com.li.minimole.core.Core3D;
import com.li.minimole.core.Mesh;
import com.li.minimole.core.View3D;

import com.li.minimole.core.render.AnaglyphRenderer;
import com.li.minimole.core.utils.TextureUtils;
import com.li.minimole.core.vo.RGB;
import com.li.minimole.materials.ColorMaterial;

import com.li.minimole.materials.PhongBitmapMaterial;
import com.li.minimole.parsers.ObjParser;
import com.li.minimole.primitives.Sphere;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import flash.geom.Vector3D;
import flash.utils.setTimeout;

import uk.co.soulwire.gui.SimpleGUI;

public class AnaglyphDemo2 extends Sprite
{
    // Texture.
    [Embed(source="assets/toroscene/texture-bake.jpg")]
    private var TextureImage:Class;

    // Model.
    [Embed (source="assets/toroscene/toroscene.obj", mimeType="application/octet-stream")]
    private var Model:Class;

    public var view:View3D;
    public var mesh:Mesh;
    public var anaglyphRenderer:AnaglyphRenderer;
    public var subjectTarget:Sphere;

    private var _ratioLbl:Label;
    private var _offLbl:Label;
    private var _disLbl:Label;
    private var _cameraController:MKSOCameraController;
    private var _gui:SimpleGUI;
    private var _subjectPosition:Vector3D = new Vector3D();

    public function AnaglyphDemo2()
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
        anaglyphRenderer = new AnaglyphRenderer();
        view.renderer = anaglyphRenderer;
        view.clearColor = new RGB(0, 0, 0);
        view.camera.z = 3;
        view.camera.y = 1;

        // Fixed light position.
        view.scene.light.position = new Vector3D(-1, 6, 6);

        // Turn on/off shader debugging.
        Core3D.instance.debugShaders = true;

        // Model.
        var texture:BitmapData = new TextureImage().bitmapData;
        texture = TextureUtils.flipBmd(texture, true, false);
        var material:PhongBitmapMaterial = new PhongBitmapMaterial(texture);
        var mesh:Mesh = new ObjParser(Model, material, 0.5);
        view.scene.addChild(mesh);

        // Target.
        subjectTarget = new Sphere(new ColorMaterial(0x00FF00), 0.01);
        view.scene.addChild(subjectTarget);
        subjectTarget.visible = false;

        // Init camera controller.
        _cameraController = new MKSOCameraController(view.camera);
        addChildAt(_cameraController, 0);

        // Start loop.
        addEventListener(Event.ENTER_FRAME, enterframeHandler);

        // UI.
        var sliderWidth:Number = 350;
        _gui = new SimpleGUI(this, null, "C");
        _gui.addGroup("Anaglyph shader options:");
        _gui.addSlider("anaglyphRenderer.anaglyphMaterial.greenFactor", 0, 1, {label:"green factor", tick:0.01, labelPrecision:2, width:sliderWidth});
        _gui.addSlider("anaglyphRenderer.anaglyphMaterial.blueFactor", 0, 1, {label:"blue factor", tick:0.01, labelPrecision:2, width:sliderWidth});
        _gui.addSlider("anaglyphRenderer.anaglyphMaterial.gammaFactor", -1, 1, {label:"gamma factor", tick:0.01, labelPrecision:2, width:sliderWidth});
        _gui.addSlider("anaglyphRenderer.anaglyphMaterial.offsetX", -0.25, 0.25, {label:"offset x", tick:0.001, labelPrecision:3, width:sliderWidth});
        _gui.addSlider("anaglyphRenderer.anaglyphMaterial.offsetY", -0.25, 0.25, {label:"offset y", tick:0.001, labelPrecision:3, width:sliderWidth});
        _gui.addGroup("Camera options:");
        _gui.addSlider("anaglyphRenderer.cameraOffset", -0.5, 0.5, {label:"camera offset", tick:0.001, labelPrecision:3, width:sliderWidth});
        _gui.addToggle("anaglyphRenderer.convergent", {label:"convergent"});
        _gui.addSlider("subjectX", -2, 2, {label:"subject x", tick:0.01, labelPrecision:2, width:sliderWidth});
        _gui.addSlider("subjectY", -2, 2, {label:"subject y", tick:0.01, labelPrecision:2, width:sliderWidth});
        _gui.addSlider("subjectZ", -2, 2, {label:"subject z", tick:0.01, labelPrecision:2, width:sliderWidth});
        _gui.addToggle("subjectTarget.visible", {label:"show subject target"});
        _gui.addGroup("Info:");
        _offLbl = _gui.addLabel("cam offset: n/a");
        _disLbl = _gui.addLabel("distance to target: n/a");
        _ratioLbl = _gui.addLabel("ratio (cam off/dis): n/a");
        setTimeout(showGUi, 1000);
    }

    private function updateRatioLabel():void
    {
        var delta:Vector3D = subjectTarget.position.subtract(view.camera.position);
        var dis:Number = delta.length;
        _disLbl.text = "distance to target: " + dis;
        var ratio:Number = anaglyphRenderer.cameraOffset/dis;
        _ratioLbl.text = "ratio (cam off/dis): " + ratio;
        _offLbl.text = "cam offset: " + anaglyphRenderer.cameraOffset;
        _gui.update();
    }

    public function set subjectX(value:Number):void
    {
        _subjectPosition.x = value;
        anaglyphRenderer.center.x = value;
        _cameraController.soCameraController.oCameraController.centerX = value;
        subjectTarget.x = value;
    }
    public function get subjectX():Number
    {
        return _subjectPosition.x;
    }
    public function set subjectY(value:Number):void
    {
        _subjectPosition.y = value;
        anaglyphRenderer.center.y = value;
        _cameraController.soCameraController.oCameraController.centerY = value;
        subjectTarget.y = value;
    }
    public function get subjectY():Number
    {
        return _subjectPosition.y;
    }
    public function set subjectZ(value:Number):void
    {
        _subjectPosition.z = value;
        anaglyphRenderer.center.z = value;
        _cameraController.soCameraController.oCameraController.centerZ = value;
        subjectTarget.z = value;
    }
    public function get subjectZ():Number
    {
        return _subjectPosition.z;
    }

    private function showGUi():void
    {
        _gui.show();
    }

    private function enterframeHandler(evt:Event):void
    {
        // Update camera position.
        _cameraController.update();

        // Light follows camera.
//        view.scene.light.position = view.camera.position;

        // Render scene.
        view.render();

        // Update label.
        updateRatioLabel();
    }

    private function rand(min:Number, max:Number):Number
    {
        return (max - min)*Math.random() + min;
    }
}
}
