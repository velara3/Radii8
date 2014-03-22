package com.flexcapacitor.components
{
	//import caurina.transitions.Tweener;
	
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.effects.Sequence;
	import mx.managers.PopUpManager;
	import mx.utils.BitFlagUtil;
	
	import spark.components.Group;
	import spark.components.Panel;
	import spark.effects.Rotate3D;
	import spark.effects.easing.Linear;
	import spark.layouts.supportClasses.LayoutBase;
	
	import com.flexcapacitor.skins.ReversablePanelSkin;
	
	use namespace mx_internal;
	
	public class ReversablePanel extends Panel
	{
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		mx_internal static const BACK_PANEL_PROPERTY_FLAG:uint = 1 << 0;
		
		/**
		 *  @private
		 */
		mx_internal static const BACK_PANEL_LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
		
		/**
		 *  @private
		 */
		mx_internal static const BACK_PANEL_VISIBLE_PROPERTY_FLAG:uint = 1 << 2;
		
		/**
		 *  @private
		 */
		mx_internal static const BACK_CONTROLBAR_PROPERTY_FLAG:uint = 1 << 0;
		
		/**
		 *  @private
		 */
		mx_internal static const BACK_CONTROLBAR_LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
		
		/**
		 *  @private
		 */
		mx_internal static const BACK_CONTROLBAR_VISIBLE_PROPERTY_FLAG:uint = 1 << 2;
		
		//--------------------------------------------------------------------------
		//
		//  Class mixins
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Placeholder for mixin by PanelAccImpl.
		 */
		mx_internal static var createAccessibilityImplementation:Function;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function ReversablePanel()
		{
			super();
			
			// default skin uses graphical dropshadow which 
			// we don't want to be hittable
			mouseEnabled = false;
			
			createRotateSequence();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables 
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Several properties are proxied to backPanelContentGroup.  However, when backPanelContentGroup
		 *  is not around, we need to store values set on SkinnableContainer.  This object 
		 *  stores those values.  If backPanelContentGroup is around, the values are stored 
		 *  on the backPanelContentGroup directly.  However, we need to know what values 
		 *  have been set by the developer on the SkinnableContainer (versus set on 
		 *  the backPanelContentGroup or defaults of the backPanelContentGroup) as those are values 
		 *  we want to carry around if the backPanelContentGroup changes (via a new skin). 
		 *  In order to store this info effeciently, backPanelContentGroupProperties becomes 
		 *  a uint to store a series of BitFlags.  These bits represent whether a 
		 *  property has been explicitely set on this SkinnableContainer.  When the 
		 *  backPanelContentGroup is not around, backPanelContentGroupProperties is a typeless 
		 *  object to store these proxied properties.  When backPanelContentGroup is around,
		 *  backPanelContentGroupProperties stores booleans as to whether these properties 
		 *  have been explicitely set or not.
		 */
		mx_internal var backPanelContentGroupProperties:Object = { visible: false };
		
		/**
		 *  @private
		 *  Several properties are proxied to backControlBarGroup.  However, when backControlBarGroup
		 *  is not around, we need to store values set on SkinnableContainer.  This object 
		 *  stores those values.  If backControlBarGroup is around, the values are stored 
		 *  on the backControlBarGroup directly.  However, we need to know what values 
		 *  have been set by the developer on the SkinnableContainer (versus set on 
		 *  the backControlBarGroup or defaults of the backControlBarGroup) as those are values 
		 *  we want to carry around if the backControlBarGroup changes (via a new skin). 
		 *  In order to store this info effeciently, backControlBarGroupProperties becomes 
		 *  a uint to store a series of BitFlags.  These bits represent whether a 
		 *  property has been explicitely set on this SkinnableContainer.  When the 
		 *  backControlBarGroup is not around, backControlBarGroupProperties is a typeless 
		 *  object to store these proxied properties.  When backControlBarGroup is around,
		 *  backControlBarGroupProperties stores booleans as to whether these properties 
		 *  have been explicitely set or not.
		 */
		mx_internal var backControlBarGroupProperties:Object = { visible: false };
		//mx_internal var backControlBarGroupProperties:Object = {  };
		
		//--------------------------------------------------------------------------
		//
		//  Skin parts 
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  backPanelContentGroup
		//---------------------------------- 
		
		[SkinPart(required="false")]
		
		/**
		 *  The skin part that defines the appearance of the 
		 *  back panel area of the container.
		 *  By default, the PanelSkin class defines the back panel area to appear at the bottom 
		 *  of the content area of the Panel container with a grey background. 
		 *
		 *  @see spark.skins.spark.PanelSkin
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var backPanelGroup:Group;
		
		//----------------------------------
		//  backControlBarGroup
		//---------------------------------- 
		
		[SkinPart(required="false")]
		
		/**
		 *  The skin part that defines the appearance of the 
		 *  back control bar area of the container.
		 *  By default, the PanelSkin class defines the control bar area to appear at the bottom 
		 *  of the content area of the Panel container with a grey background. 
		 *
		 *  @see spark.skins.spark.PanelSkin
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var backControlBarGroup:Group;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties: UIComponent
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		
		public var flipped:Boolean;
		
		public var centerOnFlip:Boolean;
		
		public var rotationSequence:Sequence;
		
		/**
		 * Amount in ms to offset switching on flip
		 **/
		public var switchOnFlipOffset:int = -30;
		
		private var _rotationDuration:int = 200;

		/**
		 * Total amount in milliseconds to play the rotation animation
		 **/
		public function get rotationDuration():int
		{
			return _rotationDuration;
		}

		public function set rotationDuration(value:int):void
		{
			_rotationDuration = value;
			
			if (rotationSequence) {
				rotationSequence.duration = value/rotationSequence.children.length; // since there are two effects
			}
		}
		
		override public function set controlBarContent(value:Array):void
		{
			super.controlBarContent = value;
		}
		
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			
			this.setStyle("skinClass", Class(ReversablePanelSkin));
		}
		
		
		//----------------------------------
		//  backPanelContentGroupContent
		//---------------------------------- 
		
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  The set of components to include in the back panel area of the 
		 *  Panel container. 
		 *  The location and appearance of the back panel area of the Panel container 
		 *  is determined by the spark.skins.spark.PanelSkin class. 
		 *  By default, the PanelSkin class defines the back panel area to appear at the bottom 
		 *  of the content area of the Panel container with a grey background. 
		 *  Create a custom skin to change the default appearance of the control bar.
		 *
		 *  @default null
		 *
		 *  @see spark.skins.spark.PanelSkin
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backPanelContent():Array
		{
			if (backPanelGroup)
				return backPanelGroup.getMXMLContent();
			else
				return backPanelContentGroupProperties.backPanelContent;
		}
		
		/**
		 *  @private
		 */
		public function set backPanelContent(value:Array):void
		{
			if (backPanelGroup)
			{
				backPanelGroup.mxmlContent = value;
				backPanelContentGroupProperties = BitFlagUtil.update(backPanelContentGroupProperties as uint, 
					BACK_PANEL_PROPERTY_FLAG, value != null);
			}
			else
				backPanelContentGroupProperties.backPanelContent = value;
			
			invalidateSkinState();
		}
		
		//----------------------------------
		//  backPanelLayout
		//---------------------------------- 
		
		/**
		 *  Defines the layout of the back panel area of the container.
		 *
		 *  @default HorizontalLayout
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backPanelGroupLayout():LayoutBase
		{
			return (backPanelGroup) 
			? backPanelGroup.layout 
				: backPanelContentGroupProperties.layout;
		}
		
		/**
		 *  @private
		 */
		public function set backPanelGroupLayout(value:LayoutBase):void
		{
			if (backPanelGroup)
			{
				backPanelGroup.layout = value;
				backPanelContentGroupProperties = BitFlagUtil.update(backPanelContentGroupProperties as uint, 
					BACK_PANEL_LAYOUT_PROPERTY_FLAG, true);
			}
			else
				backPanelContentGroupProperties.layout = value;
		}
		
		//----------------------------------
		//  backPanelVisible
		//---------------------------------- 
		
		/**
		 *  If <code>true</code>, the back panel area is visible.
		 *  The flag has no affect if there is no value set for
		 *  the <code>backPanelContent</code> property.
		 *
		 *  <p><b>Note:</b> The Panel container does not monitor the 
		 *  <code>backPanelContentGroup</code> property. 
		 *  If other code makes it invisible, the Panel container 
		 *  might not update correctly.</p>
		 *
		 *  @default true
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backPanelGroupVisible():Boolean
		{
			return (backPanelGroup) 
			? backPanelGroup.visible 
				: backPanelContentGroupProperties.visible;
		}
		
		/**
		 *  @private
		 */
		public function set backPanelGroupVisible(value:Boolean):void
		{
			if (backPanelGroup)
			{
				backPanelGroup.visible = value;
				backPanelContentGroupProperties = BitFlagUtil.update(backPanelContentGroupProperties as uint, 
					BACK_PANEL_VISIBLE_PROPERTY_FLAG, value);
			}
			else
				backPanelContentGroupProperties.visible = value;
			
			invalidateSkinState();
			if (skin)
				skin.invalidateSize();
		}
		
		
		//----------------------------------
		//  backControlBarContent
		//---------------------------------- 
		
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  The set of components to include in the back control bar area of the 
		 *  Panel container. 
		 *  The location and appearance of the back control bar area of the Panel container 
		 *  is determined by the spark.skins.spark.PanelSkin class. 
		 *  By default, the PanelSkin class defines the back control bar area to appear at the bottom 
		 *  of the content area of the Panel container with a grey background. 
		 *  Create a custom skin to change the default appearance of the back control bar.
		 *
		 *  @default null
		 *
		 *  @see spark.skins.spark.PanelSkin
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backControlBarContent():Array
		{
			if (backControlBarGroup)
				return backControlBarGroup.getMXMLContent();
			else
				return backControlBarGroupProperties.controlBarContent;
		}
		
		/**
		 *  @private
		 */
		public function set backControlBarContent(value:Array):void
		{
			if (backControlBarGroup)
			{
				backControlBarGroup.mxmlContent = value;
				backControlBarGroupProperties = BitFlagUtil.update(backControlBarGroupProperties as uint, 
					CONTROLBAR_PROPERTY_FLAG, value != null);
			}
			else
				backControlBarGroupProperties.controlBarContent = value;
			
			invalidateSkinState();
		}
		
		//----------------------------------
		//  backControlBarGroupVisible
		//---------------------------------- 
		
		/**
		 *  If <code>true</code>, the back panel area is visible.
		 *  The flag has no affect if there is no value set for
		 *  the <code>backPanelContent</code> property.
		 *
		 *  <p><b>Note:</b> The Panel container does not monitor the 
		 *  <code>backPanelContentGroup</code> property. 
		 *  If other code makes it invisible, the Panel container 
		 *  might not update correctly.</p>
		 *
		 *  @default true
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backControlBarGroupVisible():Boolean
		{
			return (backControlBarGroup) 
			? backControlBarGroup.visible 
				: backControlBarGroupProperties.visible;
		}
		
		/**
		 *  @private
		 */
		public function set backControlBarGroupVisible(value:Boolean):void
		{
			if (backControlBarGroup)
			{
				backControlBarGroup.visible = value;
				backControlBarGroupProperties = BitFlagUtil.update(backControlBarGroupProperties as uint, 
					BACK_PANEL_VISIBLE_PROPERTY_FLAG, value);
			}
			else
				backControlBarGroupProperties.visible = value;
			
			invalidateSkinState();
			if (skin)
				skin.invalidateSize();
		}
		
		//----------------------------------
		//  backControlBarGroupLayout
		//---------------------------------- 
		
		/**
		 *  Defines the layout of the back panel area of the container.
		 *
		 *  @default HorizontalLayout
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backControlBarGroupLayout():LayoutBase
		{
			return (backControlBarGroup) 
			? backControlBarGroup.layout 
				: backControlBarGroupProperties.layout;
		}
		
		/**
		 *  @private
		 */
		public function set backControlBarGroupLayout(value:LayoutBase):void
		{
			if (backControlBarGroup)
			{
				backControlBarGroup.layout = value;
				backControlBarGroupProperties = BitFlagUtil.update(backControlBarGroupProperties as uint, 
					BACK_CONTROLBAR_LAYOUT_PROPERTY_FLAG, true);
			}
			else
				backControlBarGroupProperties.layout = value;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function initializeAccessibility():void
		{
			if (Panel.createAccessibilityImplementation != null)
				Panel.createAccessibilityImplementation(this);
		}
		
		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == backPanelGroup)
			{
				// copy proxied values from backPanelContentGroupProperties (if set) to contentGroup
				var newBackPanelContentGroupProperties:uint = 0;
				
				if (backPanelContentGroupProperties.backPanelContent !== undefined)
				{
					backPanelGroup.mxmlContent = backPanelContentGroupProperties.backPanelContent;
					newBackPanelContentGroupProperties = BitFlagUtil.update(newBackPanelContentGroupProperties, BACK_PANEL_PROPERTY_FLAG, true);
				}
				
				if (backPanelContentGroupProperties.layout !== undefined)
				{
					backPanelGroup.layout = backPanelContentGroupProperties.layout;
					newBackPanelContentGroupProperties = BitFlagUtil.update(newBackPanelContentGroupProperties, BACK_PANEL_LAYOUT_PROPERTY_FLAG, true);
				}
				
				if (backPanelContentGroupProperties.visible !== undefined)
				{
					backPanelGroup.visible = backPanelContentGroupProperties.visible;
					newBackPanelContentGroupProperties = BitFlagUtil.update(newBackPanelContentGroupProperties, BACK_PANEL_VISIBLE_PROPERTY_FLAG, true);
				}
				
				backPanelContentGroupProperties = newBackPanelContentGroupProperties;
			}
			else if (instance == backControlBarGroup)
			{
				// copy proxied values from backControlBarGroupProperties (if set) to backControlBarGroup
				var newBackControlBarGroupProperties:uint = 0;
				
				if (backControlBarGroupProperties.controlBarContent !== undefined)
				{
					backControlBarGroup.mxmlContent = backControlBarGroupProperties.controlBarContent;
					newBackControlBarGroupProperties = BitFlagUtil.update(newBackControlBarGroupProperties, BACK_CONTROLBAR_PROPERTY_FLAG, true);
				}
				
				if (backControlBarGroupProperties.layout !== undefined)
				{
					backControlBarGroup.layout = backControlBarGroupProperties.layout;
					newBackControlBarGroupProperties = BitFlagUtil.update(newBackControlBarGroupProperties, BACK_CONTROLBAR_LAYOUT_PROPERTY_FLAG, true);
				}
				
				if (backControlBarGroupProperties.visible !== undefined)
				{
					backControlBarGroup.visible = backControlBarGroupProperties.visible;
					newBackControlBarGroupProperties = BitFlagUtil.update(newBackControlBarGroupProperties, BACK_CONTROLBAR_VISIBLE_PROPERTY_FLAG, true);
				}
				
				backControlBarGroupProperties = newBackControlBarGroupProperties;
			}
		}
		
		/**
		 *  @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == backPanelGroup)
			{
				// copy proxied values from contentGroup (if explicitely set) to contentGroupProperties
				
				var newbackPanelContentGroupProperties:Object = {};
				
				if (BitFlagUtil.isSet(backPanelContentGroupProperties as uint, BACK_PANEL_PROPERTY_FLAG))
					newbackPanelContentGroupProperties.backPanelContent = backPanelGroup.getMXMLContent();
				
				if (BitFlagUtil.isSet(backPanelContentGroupProperties as uint, BACK_PANEL_LAYOUT_PROPERTY_FLAG))
					newbackPanelContentGroupProperties.layout = backPanelGroup.layout;
				
				if (BitFlagUtil.isSet(backPanelContentGroupProperties as uint, BACK_PANEL_VISIBLE_PROPERTY_FLAG))
					newbackPanelContentGroupProperties.visible = backPanelGroup.visible;
				
				backPanelContentGroupProperties = newbackPanelContentGroupProperties;
				
				backPanelGroup.mxmlContent = null;
				backPanelGroup.layout = null;
			}
			else if (instance == backControlBarGroup)
			{
				// copy proxied values from backControlBarGroup (if explicitely set) to backControlBarGroupProperties
				
				var newbackControlBarGroupProperties:Object = {};
				
				if (BitFlagUtil.isSet(controlBarGroupProperties as uint, BACK_CONTROLBAR_PROPERTY_FLAG))
					newbackControlBarGroupProperties.controlBarContent = backControlBarGroup.getMXMLContent();
				
				if (BitFlagUtil.isSet(controlBarGroupProperties as uint, BACK_CONTROLBAR_LAYOUT_PROPERTY_FLAG))
					newbackControlBarGroupProperties.layout = backControlBarGroup.layout;
				
				if (BitFlagUtil.isSet(controlBarGroupProperties as uint, BACK_CONTROLBAR_VISIBLE_PROPERTY_FLAG))
					newbackControlBarGroupProperties.visible = backControlBarGroup.visible;
				
				backControlBarGroupProperties = newbackControlBarGroupProperties;
				
				backControlBarGroup.mxmlContent = null;
				backControlBarGroup.layout = null;
			}
		}
		
		/**
		 * Creates the rotation animation
		 **/
		public function createRotateSequence():void {
			rotationSequence = new Sequence();
			// duration sets the duration of each effect
			// since this is a sequence we divide by two since there are two animations
			rotationSequence.duration = rotationDuration/2;
			
			var linearEase:Linear = new Linear();
			linearEase.easeInFraction = 0;
			linearEase.easeOutFraction = 0;
			
			var rotate1:Rotate3D = new Rotate3D();
			rotate1.angleYFrom = 0; 
			rotate1.angleYTo = 90; 
			rotate1.startDelay = 0;
			rotate1.suspendBackgroundProcessing = true;
			rotate1.autoCenterTransform = true;
			rotate1.easer = linearEase;
			
			var rotate2:Rotate3D = new Rotate3D();
			rotate2.angleYFrom = -90; 
			rotate2.angleYTo = 0; 
			rotate2.startDelay = 0; 
			rotate2.suspendBackgroundProcessing = true;
			rotate2.autoCenterTransform = true;
			rotate2.easer = linearEase;
			
			rotationSequence.target = this;
			rotationSequence.children = [rotate1, rotate2];
		}
		
		public var frontWidth:Number;
		public var backWidth:Number;
		
		public var frontHeight:Number;
		public var backHeight:Number;
		
		/**
		 * Flip to the other view
		 **/
		public function flip(noDuration:Boolean = false):void 
		{
			flipped = !flipped;
			
			if (noDuration) {
				switchOnFlip();
			}
			else {
				var rotationTime:Number = rotationDuration/1000;
				var switchTime:Number = rotationTime/2+(switchOnFlipOffset/1000);
				IVisualElement(titleDisplay).visible = false;
				
				rotationSequence.play(null, !flipped);
				/*
				Tweener.addTween(this, {z:150, time:rotationTime, transition:"easeOutExpo"});
				Tweener.addTween(this, {z:0, time:rotationTime, delay:rotationTime, transition:"easeOutExpo"});
				
				Tweener.addTween(this, {delay:switchTime, transition:"linear", onComplete:switchOnFlip});
				Tweener.addTween(this, {delay:rotationTime, transition:"linear", onComplete:flipTransitionComplete});
				*/
			}
			
			//trace("flipping:" + getTimer());
		}
		
		private var _halfRotation:Sequence;
		private function get halfRotation():Sequence
		{
			if (_halfRotation == null) {
				_halfRotation =	new Sequence();
				_halfRotation.duration = rotationDuration;
				
				var linearEase:Linear = new Linear();
				linearEase.easeInFraction = 0;
				linearEase.easeOutFraction = 0;
				
				var rotate2:Rotate3D = new Rotate3D();
				rotate2.angleYFrom = -90; 
				rotate2.angleYTo = 0; 
				rotate2.startDelay = 0; 
				rotate2.suspendBackgroundProcessing = true;
				rotate2.autoCenterTransform = true;
				rotate2.easer = linearEase;
				_halfRotation.target = this;
				_halfRotation.children = [rotate2];
			}
			
			return _halfRotation;
		}
		
		private var _halfRotationBack:Sequence;
		private function get halfRotationBack():Sequence
		{
			if (_halfRotationBack == null) {
				_halfRotationBack =	new Sequence();
				_halfRotationBack.duration = rotationDuration;
				
				var linearEase:Linear = new Linear();
				linearEase.easeInFraction = 0;
				linearEase.easeOutFraction = 0;
				
				var rotate1:Rotate3D = new Rotate3D();
				rotate1.angleYFrom = 0; 
				rotate1.angleYTo = 90; 
				rotate1.startDelay = 0;
				rotate1.suspendBackgroundProcessing = true;
				rotate1.autoCenterTransform = true;
				rotate1.easer = linearEase;
				_halfRotationBack.target = this;
				_halfRotationBack.children = [rotate1];
			}
			
			return _halfRotationBack;
		}
		public function halfFlip(reverse:Boolean):void
		{
			this.z = 150;
			this.visible = true;
			if (reverse) {
				this.flipped = false;
				halfRotationBack.play(null, true);
			} else {
				halfRotation.play();
			}
			
			/*
			Tweener.addTween(this, {z:0, time:(rotationDuration/1000), delay:(rotationDuration/1000), transition:"easeOutExpo"});
			*/
		}
		
		/**
		 * 
		 **/
		
		protected function switchOnFlip():void
		{
			//contentGroup.visible = !flipped;
			
			if (backPanelGroup) {
				if (flipped) {
					frontWidth = width;
					frontHeight = height;
					width = NaN;
					height = NaN;
				}
				else {
					width = frontWidth;
					height = frontHeight;
				}
				
				// content group
				backPanelGroupVisible = flipped;
				backPanelGroup.includeInLayout = flipped;
				contentGroup.visible = !flipped;
				contentGroup.includeInLayout = !flipped;
				
				// control bar group
				// if controlBarGroup in panel skin is not created 
				// immediately controlbargroup is null
				// set itemCreationPolicy to immediate in controlBarGroup parent
				backControlBarGroupVisible = flipped;
				backControlBarGroup.includeInLayout = flipped;
				controlBarVisible = !flipped;
				controlBarGroup.includeInLayout = !flipped;
				
				if (centerOnFlip) {
					PopUpManager.centerPopUp(this);
				}
			}
			
			//trace("switch on flip:" + getTimer());
			
		}
		
		/**
		 * 
		 **/
		protected function flipTransitionComplete():void {
			IVisualElement(titleDisplay).visible = true;
			//trace("flip complete:" + getTimer());
		}
		
		/**
		 *  @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function getCurrentSkinState():String
		{
			var state:String = enabled ? "normal" : "disabled";
			
			if (!flipped) {
				if (controlBarGroup)
				{
					if (BitFlagUtil.isSet(controlBarGroupProperties as uint, CONTROLBAR_PROPERTY_FLAG) &&
						BitFlagUtil.isSet(controlBarGroupProperties as uint, VISIBLE_PROPERTY_FLAG)) {
						state += "WithControlBar";
					}
				}
				else
				{
					if (controlBarGroupProperties.controlBarContent && controlBarGroupProperties.visible) {
						state += "WithControlBar";
					}
				}
			}
			else {
				if (backControlBarGroup)
				{
					if (BitFlagUtil.isSet(backControlBarGroupProperties as uint, BACK_CONTROLBAR_PROPERTY_FLAG) &&
						BitFlagUtil.isSet(backControlBarGroupProperties as uint, BACK_CONTROLBAR_VISIBLE_PROPERTY_FLAG)) {
						state += "WithControlBar";
					}
				}
				else
				{
					if (backControlBarGroupProperties.controlBarContent && backControlBarGroupProperties.visible) {
						state += "WithControlBar";
					}
				}
			}
			//trace("state="+state);
			return state;
		}
	}
}