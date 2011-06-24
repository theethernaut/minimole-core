package examples
{
import com.li.minimole.camera.controller.MKSOCameraController;
import com.li.minimole.core.Core3D;
import com.li.minimole.core.View3D;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import flash.utils.setTimeout;

import uk.co.soulwire.gui.SimpleGUI;

/*
    Not actually an abstract class, rather a sample to copy and paste and create a new experiment.
    :P
 */
public class ExampleBase extends Sprite
{
    public var view:View3D;

    private var _cameraController:MKSOCameraController;
    private var _gui:SimpleGUI;

    public function ExampleBase()
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

        // Init camera controller.
        _cameraController = new MKSOCameraController(view.camera);
        addChildAt(_cameraController, 0);

        // Start loop.
        addEventListener(Event.ENTER_FRAME, enterframeHandler);

        // UI.
        _gui = new SimpleGUI(this);
        setTimeout(showGUi, 1000);
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
        view.scene.light.position = view.camera.position;

        // Render scene.
        view.render();
    }
}
}
