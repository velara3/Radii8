package com.flexcapacitor.managers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class DeferManager
	{
		public function DeferManager()
		{
		}
		
		public static var counter:int;
		public static var deferredDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * Calls a function after a set amount of time. 
		 * */
		public static function callAfter(time:int, method:Function, ...Arguments):void {
			var sprite:Sprite = new Sprite();
			var callTime:int = getTimer() + time;
			
			var listener:Function = function(e:Event):void {
				var difference:int = getTimer()-callTime-time;
				if (getTimer()>=callTime) {
					//trace("callAfter: time difference:" + difference);
					sprite.removeEventListener(Event.ENTER_FRAME, arguments.callee);
					method.apply(this, Arguments);
					method = null;
					deferredDictionary[sprite] = null;
					delete deferredDictionary[sprite];
					counter--;
				}
			}
				
			// todo: find out if this causes memory leaks
			sprite.addEventListener(Event.ENTER_FRAME, listener);
			
			deferredDictionary[sprite] = listener;
			counter++;
		}
		
		/**
		 * Calls a function after a frame 
		 * */
		public static function callLater(method:Function, ...Arguments):void {
			var sprite:Sprite = new Sprite();
			var startTime:int = getTimer();
			
			// todo: find out if this causes memory leaks
			sprite.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				var difference:int = getTimer()-startTime;
				//trace("callLater: time difference:" + difference);
				sprite.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				method.apply(this, Arguments);
				method = null;
			});
		}
	}
}