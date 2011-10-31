package examples
{

	import com.li.minimole.camera.controller.OrbitCameraController;
	import com.li.minimole.core.Core3D;
	import com.li.minimole.core.View3D;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	import net.hires.debug.Stats;

	import uk.co.soulwire.gui.SimpleGUI;

	public class ExampleBase extends Sprite
	{
		public var view:View3D;
		public var gui:SimpleGUI;
		public var cameraController:OrbitCameraController;
		public var stats:Stats;

		public function ExampleBase()
		{
			addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
		}

		private function stageInitHandler(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);

			// Init stage.
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// Init 3d view.
			view = new View3D();
			addChild(view);

			// Stats
			stats = new Stats();
			stats.x = stage.stageWidth - 70;
			addChild(stats);

			// Turn on/off shader debugging.
			Core3D.instance.debugShaders = false;

			// Init camera controller.
			cameraController = new OrbitCameraController(view.camera);

			// stage listeners for camera control
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, stageMouseWheelHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUpHandler);

			// Start loop.
			addEventListener(Event.ENTER_FRAME, enterframeHandler);

			// UI.
			gui = new SimpleGUI(this);
			gui.show();

			onPostInit();
		}

		protected function onPostInit():void
		{

		}

		protected function onPreRender():void
		{

		}

		protected function onPostRender():void
		{

		}

		private function enterframeHandler(evt:Event):void
		{
			onPreRender();
			cameraController.update();
			view.scene.light.position = view.camera.position;
			view.render();
			onPostRender();
		}

		private function stageMouseWheelHandler(evt:MouseEvent):void
		{
			cameraController.mouseWheel(evt.delta);
		}

		private function stageMouseMoveHandler(evt:MouseEvent):void
		{
			cameraController.mouseMove(stage.mouseX, stage.mouseY);
		}

		private function stageMouseDownHandler(evt:MouseEvent):void
		{
			cameraController.mouseDown();
		}

		private function stageMouseUpHandler(evt:MouseEvent):void
		{
			cameraController.mouseUp();
		}

		private function stageKeyDownHandler(evt:KeyboardEvent):void
		{
			cameraController.keyDown(evt.keyCode);
		}

		private function stageKeyUpHandler(evt:KeyboardEvent):void
		{
			cameraController.keyUp(evt.keyCode);
		}
	}
}
