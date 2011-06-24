package examples
{
import com.li.minimole.camera.controller.MKSOCameraController;
import com.li.minimole.core.Core3D;
import com.li.minimole.core.Mesh;
import com.li.minimole.core.View3D;

import com.li.minimole.materials.LineMaterial;
import com.li.minimole.materials.LineMaterial;
import com.li.minimole.primitives.Lines;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import flash.geom.Vector3D;

import flash.utils.setTimeout;

import uk.co.soulwire.gui.SimpleGUI;

public class SegmentsDemo extends Sprite
{
    public var view:View3D;
    public var mesh:Mesh;

    private var _cameraController:MKSOCameraController;

    private var _gui:SimpleGUI;

    public function SegmentsDemo()
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

        // Lines.
        _lines = new Vector.<Lines>();
        createLines(0xFF0000, 100);
        createLines(0x00FF00, 100);
        createLines(0x0000FF, 100);

        // Init camera controller.
        _cameraController = new MKSOCameraController(view.camera);
        addChildAt(_cameraController, 0);

        // Start loop.
        addEventListener(Event.ENTER_FRAME, enterframeHandler);

        // UI.
        _gui = new SimpleGUI(this);
        _gui.addSlider("lineWidth", 0, 1, {label:"line width", labelPrecision:3});
        setTimeout(showGUi, 1000);
    }

    private var _lineWidth:Number = 0.02;
    public function set lineWidth(value:Number):void
    {
        _lineWidth = value;
        for(var i:uint; i < _lines.length; ++i)
        {
            LineMaterial(_lines[i].material).thickness = value;
        }
    }
    public function get lineWidth():Number
    {
        return _lineWidth;
    }

    private var _lines:Vector.<Lines>;
    private function createLines(color:uint, num:uint):void
    {
        // Material.
        var mMat:LineMaterial = new LineMaterial(color, _lineWidth);

        // Line.
        var lines:Lines = new Lines(mMat);
        view.scene.addChild(lines);
        var p0:Vector3D = new Vector3D();
        var p1:Vector3D = new Vector3D(2, 0, 0);
        for(var i:uint; i < num; ++i)
        {
            p0.x = rand(-1, 1);
            p0.y = rand(-1, 1);
            p0.z = rand(-1, 1);
            p1.x = rand(-1, 1);
            p1.y = rand(-1, 1);
            p1.z = rand(-1, 1);
            lines.createLine(p0, p1);
        }
        _lines.push(lines);
    }

    private function showGUi():void
    {
        _gui.show();
    }

    private function rand(min:Number, max:Number):Number
    {
        return (max - min)*Math.random() + min;
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
