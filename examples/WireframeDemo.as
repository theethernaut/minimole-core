package examples
{
import com.li.minimole.camera.controller.MKSOCameraController;
import com.li.minimole.core.Core3D;
import com.li.minimole.core.Mesh;
import com.li.minimole.core.View3D;

import com.li.minimole.core.utils.MeshUtils;
import com.li.minimole.materials.WireframeMaterial;
import com.li.minimole.materials.MaterialBase;
import com.li.minimole.materials.WireframeMaterialSimple;
import com.li.minimole.parsers.ObjParser;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import flash.utils.setTimeout;

import uk.co.soulwire.gui.SimpleGUI;

public class WireframeDemo extends Sprite
{
    // Model.
//    [Embed (source="assets/shuttle/shuttle.obj", mimeType="application/octet-stream")]
    [Embed (source="assets/head/head.obj", mimeType="application/octet-stream")]
    private var Model:Class;

    public var view:View3D;
    public var mesh:Mesh;

    private var _cameraController:MKSOCameraController;
    private var _gui:SimpleGUI;

    public var wireframeMaterial:WireframeMaterial;

    public function WireframeDemo()
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

        // Turn on/off shader debugging.
        Core3D.instance.debugShaders = true;

        // Material.
        wireframeMaterial = new WireframeMaterial();

        // Model.
        mesh = new ObjParser(Model, wireframeMaterial, 0.2);
        MeshUtils.prepareMeshForWireframe(mesh);
        view.scene.addChild(mesh);

        // Init camera controller.
        _cameraController = new MKSOCameraController(view.camera);
        addChildAt(_cameraController, 0);

        // Start loop.
        addEventListener(Event.ENTER_FRAME, enterframeHandler);

        // UI.
        _gui = new SimpleGUI(this);
        _gui.addColumn("Options:");
        _gui.addSlider("wireframeMaterial.lineFactor", 0.0, 200.0, {label:"line factor"});
        _gui.addColour("wireframeMaterial.color");
        setTimeout(showGUi, 1000);
    }

    private function showGUi():void
    {
        _gui.show();
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
        // Update camera position.
        _cameraController.update();

        // Light follows camera.
        view.scene.light.position = view.camera.position;

        // Render scene.
        view.render();
    }
}
}
