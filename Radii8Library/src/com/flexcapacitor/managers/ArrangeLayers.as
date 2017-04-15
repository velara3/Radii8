package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.model.Document;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import mx.states.AddItems;
	
	import spark.layouts.BasicLayout;

	/**
	 * Helper class to for common arrange methods
	 * */
	public class ArrangeLayers {
		
		public function ArrangeLayers() {
			
		}
		
		/**
		 * Bring a layer forward
		 * */
		public static function bringForwards(target:Object, document:IDocument = null, setTarget:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var currentIndex:int;
			var dropIndex:int;
			var parentInstance:Object;
			
			if (target is ComponentDescription) {
				componentDescription = target as ComponentDescription;
			}
			else {
				componentDescription = document.getItemDescription(target);
			}
			
			if (componentDescription && componentDescription.parent) {
				currentIndex = ComponentDescription(componentDescription.parent).children.getItemIndex(componentDescription);
				
				if (currentIndex<ComponentDescription(componentDescription.parent).children.length-1) {
					parentInstance = ComponentDescription(componentDescription.parent).instance;
					
					if ("layout" in parentInstance && parentInstance.layout is BasicLayout) { 
						dropIndex = currentIndex + 1;
					}
					else {
						dropIndex = currentIndex + 2;
					}
					
					Radiate.moveElement2(componentDescription.instance, componentDescription.parent.instance, null, 
						null, RadiateEvent.MOVE_ITEM, AddItems.LAST, null, dropIndex);
					//radiate.setTarget(componentDescription.instance);
					//componentListTree.selectedItem = componentDescription;
				}
				
			}
			
		}
		
		/**
		 * Bring a layer to the front of other layers
		 * */
		public static function bringToFront(target:Object, document:IDocument = null, setTarget:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var currentIndex:int;
			var dropIndex:int;
			var numberOfItems:int;
			var parentInstance:Object;
			
			if (target is ComponentDescription) {
				componentDescription = target as ComponentDescription;
			}
			else {
				componentDescription = document.getItemDescription(target);
			}
			
			if (componentDescription && componentDescription.parent) {
				currentIndex = ComponentDescription(componentDescription.parent).children.getItemIndex(componentDescription);
				numberOfItems = ComponentDescription(componentDescription.parent).children.length;
				
				if (currentIndex!=numberOfItems-1) {
					parentInstance = ComponentDescription(componentDescription.parent).instance;
					
					if ("layout" in parentInstance && parentInstance.layout is BasicLayout) { 
						dropIndex = numberOfItems - 1;
					}
					else {
						//dropIndex = numberOfItems - 1;
						dropIndex = numberOfItems;
					}
					
					Radiate.moveElement2(componentDescription.instance, componentDescription.parent.instance, null, 
						null, RadiateEvent.MOVE_ITEM, AddItems.LAST, null, dropIndex);
					//radiate.setTarget(componentDescription.instance);
					//componentListTree.selectedItem = componentDescription;
				}
				
			}
			
		}
		
		public static function sendBackwards(target:Object, document:IDocument = null, setTarget:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var currentIndex:int;
			var dropIndex:int;
			
			if (target is ComponentDescription) {
				componentDescription = target as ComponentDescription;
			}
			else {
				componentDescription = document.getItemDescription(target);
			}
			
			if (componentDescription && componentDescription.parent) {
				currentIndex = ComponentDescription(componentDescription.parent).children.getItemIndex(componentDescription);
				
				if (currentIndex>0) {
					dropIndex = currentIndex - 1;
					Radiate.moveElement2(componentDescription.instance, componentDescription.parent.instance, null, 
						null, RadiateEvent.MOVE_ITEM, AddItems.LAST, null, dropIndex);
					//radiate.setTarget(componentDescription.instance);
					//componentListTree.selectedItem = componentDescription;
				}
				
			}
		}
		
		public static function sendToBack(target:Object, document:IDocument = null, setTarget:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var currentIndex:int;
			var dropIndex:int;
			
			if (target is ComponentDescription) {
				componentDescription = target as ComponentDescription;
			}
			else {
				componentDescription = document.getItemDescription(target);
			}
			
			if (componentDescription && componentDescription.parent) {
				currentIndex = ComponentDescription(componentDescription.parent).children.getItemIndex(componentDescription);
				
				if (currentIndex!=0) {
					//dropIndex = currentIndex - 1;
					dropIndex = 0;
					Radiate.moveElement2(componentDescription.instance, componentDescription.parent.instance, null, 
						null, RadiateEvent.MOVE_ITEM, AddItems.LAST, null, dropIndex);
					//radiate.setTarget(componentDescription.instance);
					//componentListTree.selectedItem = componentDescription;
				}
				
			}
		}
	}
}