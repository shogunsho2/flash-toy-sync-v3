package {
	
	import components.KeyboardInput;
	import components.StateManager;
	import controllers.AnimationPlaybackController;
	import controllers.AnimationSizeController;
	import controllers.HierarchyPanelController;
	import controllers.SaveDataController;
	import controllers.ScriptSampleMarkersEditorController;
	import controllers.ScriptTrackerMarkersEditorController;
	import controllers.StrokerToyController;
	import controllers.StrokerToyEditorController;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import states.AnimationInfoStates;
	import states.AnimationPlaybackStates;
	import states.AnimationSizeStates;
	import states.EditorStates;
	import states.ScriptStates;
	import core.TranspiledDisplayObjectEventFunctions;
	import core.TranspiledMovieClip;
	import core.TranspiledStage;
	import ui.MainMenu;
	import ui.TextElement;
	import ui.TextStyles;
	import visualComponents.Animation;
	import visualComponents.Borders;
	
	/**
	 * ...
	 * @author notSafeForDev
	 */
	public class Index {
		
		private var stateManager : StateManager;
		
		private var animationInfoStates : AnimationInfoStates;
		private var animationPlaybackStates : AnimationPlaybackStates;
		private var animationSizeStates : AnimationSizeStates;
		private var editorStates : EditorStates;
		private var scriptStates : ScriptStates;
		
		private var animationPlaybackController : AnimationPlaybackController;
		private var animationSizeController : AnimationSizeController;
		private var hierarchyPanelController : HierarchyPanelController;
		private var saveDataController : SaveDataController;
		private var scriptSampleMarkersEditorController : ScriptSampleMarkersEditorController;
		private var scriptTrackermarkersEditorController : ScriptTrackerMarkersEditorController;
		private var strokerToyController : StrokerToyController;
		private var strokerToyEditorController : StrokerToyEditorController;
		
		private var container : TranspiledMovieClip;
		private var mainMenu : MainMenu;
		private var borders : Borders;
		private var animation : Animation;
		private var errorText : TextElement;
		
		public function Index(_container : MovieClip) {
			stateManager = new StateManager();
			
			container = new TranspiledMovieClip(_container);
			
			TranspiledStage.init(_container, 30);
			KeyboardInput.init(_container);
			
			initializeStates();
			initializeControllers();
			addVisualComponents();
			
			errorText.text = "A test error to see if the text works";
			
			TranspiledDisplayObjectEventFunctions.addEnterFrameEventListener(_container, this, onEnterFrame, null);
		}
		
		private function onAnimationSelected(_name : String) : void {
			animationInfoStates._name.setValue(_name);
		}
		
		private function onAnimationLoaded(_swf : MovieClip, _stageWidth : Number, _stageHeight : Number, _frameRate : Number) : void {
			if (_stageWidth > 0 && _stageHeight > 0) {
				animationSizeStates._width.setValue(_stageWidth);
				animationSizeStates._height.setValue(_stageHeight);
			}
			
			animationInfoStates._isLoaded.setValue(true);
		}
		
		private function onEnterFrame() : void {
			updateControllers();
			
			stateManager.notifyListeners();
		}
		
		private function onMainMenuBrowseAnimation() : void {
			animation.browse(this, onAnimationSelected);
		}
		
		private function onMainMenuPlayAnimation() : void {
			animation.load(AnimationInfoStates.name.value);
		}
		
		private function addVisualComponents() : void {
			addAnimation();
			addBorders();
			addMainMenu();
			addErrorText();
		}
		
		private function addAnimation() : void {
			animation = new Animation(container.sourceMovieClip);
			
			animation.loadedEvent.listen(this, onAnimationLoaded);
		}
		
		private function addBorders() : void {
			borders = new Borders(container.sourceMovieClip, 0xFF0000);
		}
		
		private function addMainMenu() : void {
			mainMenu = new MainMenu(container.sourceMovieClip);
			
			mainMenu.browseAnimationEvent.listen(this, onMainMenuBrowseAnimation);
			mainMenu.playAnimationEvent.listen(this, onMainMenuPlayAnimation);
		}
		
		private function addErrorText() : void {
			errorText = new TextElement(container.sourceMovieClip);
			TextStyles.applyErrorStyle(errorText);
			
			var errorTextTextFormat : TextFormat = errorText.getTextFormat();
			errorTextTextFormat.align = TextElement.ALIGN_CENTER;
			errorText.setTextFormat(errorTextTextFormat);
			
			errorText.element.y = TranspiledStage.stageHeight - 80;
			errorText.element.width = TranspiledStage.stageWidth;
		}
		
		private function initializeStates() : void {
			animationInfoStates = new AnimationInfoStates(stateManager);
			animationPlaybackStates = new AnimationPlaybackStates(stateManager);
			animationSizeStates = new AnimationSizeStates(stateManager);
			editorStates = new EditorStates(stateManager);
			scriptStates = new ScriptStates(stateManager);
		}
		
		private function initializeControllers() : void {
			animationPlaybackController = new AnimationPlaybackController(animationPlaybackStates);
			animationSizeController = new AnimationSizeController(animationSizeStates);
		}
		
		private function updateControllers() : void {
			animationPlaybackController.update();
			animationSizeController.update();
		}
	}
}