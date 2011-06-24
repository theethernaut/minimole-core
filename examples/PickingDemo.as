package examples
{
import com.bit101.components.Label;
import com.li.minimole.camera.controller.MKSOCameraController;
import com.li.minimole.core.Core3D;
import com.li.minimole.core.Mesh;
import com.li.minimole.core.View3D;

import com.li.minimole.core.math.Ray;
import com.li.minimole.materials.ColorMaterial;
import com.li.minimole.materials.GouraudColorMaterial;
import com.li.minimole.primitives.CubeR;
import com.li.minimole.primitives.Sphere;

import com.li.minimole.primitives.WireCube;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import flash.geom.Vector3D;
import flash.utils.setTimeout;

import uk.co.soulwire.gui.SimpleGUI;

/*
    Testing mouse interaction.
    TODO: Continue test with wirecube.
    TODO: Put wirecube in mesh rendering pipeline triggered by showBoundingBox = true.
 */
public class PickingDemo extends Sprite
{
    public var view:View3D;

    private var _cameraController:MKSOCameraController;
    private var _gui:SimpleGUI;

    private var _mesh:Mesh;
    private var _tracer3d:Sphere;
    private var _tracer2d:Sprite;
    private var _posLbl:Label;

    public function PickingDemo()
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

        // Models.
        var mat:GouraudColorMaterial = new GouraudColorMaterial();

        // Mesh.
        _mesh = new CubeR(mat, 0.5, 0.5, 0.5);
        _mesh.showBoundingBox = true;
        view.scene.addChild(_mesh);

        // 3d tracer.
        _tracer3d = new Sphere(new ColorMaterial(), 0.05);
        view.scene.addChild(_tracer3d);

        // 2d tracer.
        _tracer2d = new Sprite();
        _tracer2d.graphics.beginFill(0xFF0000);
        _tracer2d.graphics.drawCircle(0, 0, 5);
        _tracer2d.graphics.endFill();
        addChild(_tracer2d);

        // Init camera controller.
        _cameraController = new MKSOCameraController(view.camera);
        addChildAt(_cameraController, 0);

        // Start loop.
        addEventListener(Event.ENTER_FRAME, enterframeHandler);

        // UI.
        _gui = new SimpleGUI(this);
        _posLbl = _gui.addLabel("tracer pos: n/a", {width:200});
        setTimeout(showGUi, 1000);
    }

    private function showGUi():void
    {
        _gui.show();
    }

    private function enterframeHandler(evt:Event):void
    {
        // Spin obj.
//        _mesh.rotationDegreesX += 0.5;
//        _mesh.rotationDegreesY += 1;
//        _mesh.rotationDegreesZ += 0.75;

        // Update camera position.
        _cameraController.update();

        // Update mouse ray.
        var ray:Ray = view.camera.unproject(mouseX, mouseY);
//        _tracer3d.position = ray.p1;
        _tracer3d.position = new Vector3D(1, 0, 0);
//        _posLbl.text = "tracer pos: " + rnd(_nearTracer.x) + ", " + rnd(_nearTracer.y) + ", " + rnd(_nearTracer.z);
        _gui.update();

        //
        var cubeVertices:Vector.<Number> = _mesh.rawPositionsBuffer;
        var pos:Vector3D = new Vector3D(cubeVertices[0], cubeVertices[1], cubeVertices[2]);
//        pos = _mesh.transform.transformVector(pos);
//        var pos:Vector3D = new Vector3D(1, 0, 0);
        pos = view.camera.project(pos);
        _tracer2d.x = pos.x;
        _tracer2d.y = pos.y;
        _posLbl.text = "proj " + rnd(pos.x) + ", " + rnd(pos.y) + ", " + rnd(pos.z);

        // Light follows camera.
        view.scene.light.position = view.camera.position;

        // Render scene.
        view.render();
    }

    private function rnd(value:Number, decimals:uint = 2):Number
    {
        var multiplier:Number = Math.pow(10, decimals);
	    return Math.round(value*multiplier)/multiplier;
    }
}
}
