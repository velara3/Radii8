package com.flexcapacitor.utils {
	
	import com.flexcapacitor.controller.Radiate;
	
	import spark.primitives.Line;

	public class MoveUtils {
		
		public function MoveUtils() {
			
		}
		
		public static function moveLeft(element:Object, amount:Number):void {
			var leftValue:Object;
			var rightValue:Object;
			var horizontalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var xFrom:Number;
			var xTo:Number;
			var xDiff:Number;
			
			if (element is Line) {
				line = element as Line;
				
				xDiff = -amount;
				xFrom = line.xFrom + xDiff;
				propertiesObject["xFrom"] = xFrom;
				properties.push("xFrom");
				
				if (isNaN(line.percentWidth)) {
					xTo = line.xTo + xDiff;
					propertiesObject["xTo"] = xTo;
					properties.push("xTo");
				}
				
			}
			else {
				leftValue = element.left;
				rightValue = element.right;
				horizontalCenter = element.horizontalCenter;
				
				/**
				 * If left is set then set x to nothing
				 * If left and right are set then set width to nothing
				 * If horizontalCenter is set than set left and right to nothing
				 * Otherwise set left to nothing
				 * */
				if (leftValue!=null && rightValue!=null) {
					propertiesObject.left = Number(element.left) - amount;
					propertiesObject.right = Number(element.right) + amount;
					properties.push(MXMLDocumentConstants.LEFT, MXMLDocumentConstants.RIGHT);
				}
				else if (leftValue!=null) {
					propertiesObject.left = Number(element.left) - amount;
					properties.push(MXMLDocumentConstants.LEFT);
				}
				else if (rightValue!=null) {
					propertiesObject.right = Number(element.right) + amount;
					properties.push(MXMLDocumentConstants.RIGHT);
				}
				else if (horizontalCenter!=null) {
					propertiesObject.horizontalCenter = Number(element.horizontalCenter) - amount;
					properties.push(MXMLDocumentConstants.HORIZONTAL_CENTER);
				}
				else {
					propertiesObject.x = element.x - amount;
					properties.push(MXMLDocumentConstants.X);
				}
			}
			
			Radiate.moveElement2(element, null, properties, propertiesObject);
		}
		
		public static function moveRight(element:Object, amount:Number):void {
			var leftValue:Object;
			var rightValue:Object;
			var horizontalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var xFrom:Number;
			var xTo:Number;
			var xDiff:Number;
			
			
			if (element is Line) {
				line = element as Line;
				
				xDiff = amount;
				xFrom = line.xFrom + xDiff;
				propertiesObject["xFrom"] = xFrom;
				properties.push("xFrom");
				
				if (isNaN(line.percentWidth)) {
					xTo = line.xTo + xDiff;
					propertiesObject["xTo"] = xTo;
					properties.push("xTo");
				}
				
			}
			else {
				leftValue = element.left;
				rightValue = element.right;
				horizontalCenter = element.horizontalCenter;
				
				if (leftValue!=null && rightValue!=null) {
					propertiesObject.left = Number(element.left) + amount;
					propertiesObject.right = Number(element.right) - amount;
					properties.push(MXMLDocumentConstants.LEFT, MXMLDocumentConstants.RIGHT);
				}
				else if (leftValue!=null) {
					propertiesObject.left = Number(element.left) + amount;
					properties.push(MXMLDocumentConstants.LEFT);
				}
				else if (rightValue!=null) {
					propertiesObject.right = Number(element.right) - amount;
					properties.push(MXMLDocumentConstants.RIGHT);
				}
				else if (horizontalCenter!=null) {
					propertiesObject.horizontalCenter = Number(element.horizontalCenter) + amount;
					properties.push(MXMLDocumentConstants.HORIZONTAL_CENTER);
				}
				else {
					propertiesObject.x = element.x + amount;
					properties.push(MXMLDocumentConstants.X);
				}
			}
			
			Radiate.moveElement2(element, null, properties, propertiesObject);
		}
		
		public static function moveUp(element:Object, amount:Number):void {
			var topValue:Object;
			var bottomValue:Object;
			var verticalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var yFrom:Number;
			var yTo:Number;
			var yDiff:Number;
			
			if (element is Line) {
				line = element as Line;
				
				yDiff = -amount;
				yFrom = line.yFrom + yDiff;
				propertiesObject["yFrom"] = yFrom;
				properties.push("yFrom");
				
				if (isNaN(line.percentHeight)) {
					yTo = line.yTo + yDiff;
					propertiesObject["yTo"] = yTo;
					properties.push("yTo");
				}
			}
			else {
				topValue = element.top;
				bottomValue = element.bottom;
				verticalCenter = element.verticalCenter;
				
				if (topValue!=null && bottomValue!=null) {
					propertiesObject.top = Number(element.top) - amount;
					propertiesObject.bottom = Number(element.bottom) + amount;
					properties.push(MXMLDocumentConstants.TOP, MXMLDocumentConstants.BOTTOM);
				}
				else if (topValue!=null) {
					propertiesObject.top = Number(element.top) - amount;
					properties.push(MXMLDocumentConstants.TOP);
				}
				else if (bottomValue!=null) {
					propertiesObject.bottom = Number(element.bottom) + amount;
					properties.push(MXMLDocumentConstants.BOTTOM);
				}
				else if (verticalCenter!=null) {
					propertiesObject.verticalCenter = Number(element.verticalCenter) - amount;
					properties.push(MXMLDocumentConstants.VERTICAL_CENTER);
				}
				else {
					propertiesObject.y = element.y - amount;
					properties.push(MXMLDocumentConstants.Y);
				}
			}
			
			Radiate.moveElement2(element, null, properties, propertiesObject);
		}
		
		public static function moveDown(element:Object, amount:Number):void {
			var topValue:Object;
			var bottomValue:Object;
			var verticalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var yFrom:Number;
			var yTo:Number;
			var yDiff:Number;
			
			
			if (element is Line) {
				line = element as Line;
				
				yDiff = amount;
				yFrom = line.yFrom + yDiff;
				propertiesObject["yFrom"] = yFrom;
				properties.push("yFrom");
				
				if (isNaN(line.percentHeight)) {
					yTo = line.yTo + yDiff;
					propertiesObject["yTo"] = yTo;
					properties.push("yTo");
				}
			}
			else {
				topValue = element.top;
				bottomValue = element.bottom;
				verticalCenter = element.verticalCenter;
				
				if (topValue!=null && bottomValue!=null) {
					propertiesObject.top = Number(element.top) + amount;
					propertiesObject.bottom = Number(element.bottom) - amount;
					properties.push(MXMLDocumentConstants.TOP, MXMLDocumentConstants.BOTTOM);
				}
				else if (topValue!=null) {
					propertiesObject.top = Number(element.top) + amount;
					properties.push(MXMLDocumentConstants.TOP);
				}
				else if (bottomValue!=null) {
					propertiesObject.bottom = Number(element.bottom) - amount;
					properties.push(MXMLDocumentConstants.BOTTOM);
				}
				else if (verticalCenter!=null) {
					propertiesObject.verticalCenter = Number(element.verticalCenter) + amount;
					properties.push(MXMLDocumentConstants.VERTICAL_CENTER);
				}
				else {
					propertiesObject.y = element.y + amount;
					properties.push(MXMLDocumentConstants.Y);
				}
			}
			
			Radiate.moveElement2(element, null, properties, propertiesObject);
			
		}
		
		
		
		public static function move(target:Object, direction:String, amount:Number):void {
			
			if (direction=="left") {
				moveLeft(target, amount);
			}
			else if (direction=="right") {
				moveRight(target, amount);
			}
			else if (direction=="up") {
				moveUp(target, amount);
			}
			else if (direction=="down") {
				moveDown(target, amount);
			}
		}
		
		public static function resetPosition(element:Object):void {
			var topValue:Object;
			var bottomValue:Object;
			var verticalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var yFrom:Number;
			var yTo:Number;
			var yDiff:Number;
			var xFrom:Number;
			var xTo:Number;
			var xDiff:Number;
			var reversed:Boolean;
			
			
			if (element is Line) {
				line = element as Line;
				
				if (line.xFrom>line.xTo) {
					propertiesObject["xFrom"] = line.xFrom-line.xTo;
					propertiesObject["xTo"] = 0;
					properties.push("xFrom");
					properties.push("xTo");
				}
				else {
					propertiesObject["xFrom"] = 0;
					propertiesObject["xTo"] = line.xTo-line.xFrom;
					properties.push("xFrom");
					properties.push("xTo");
				}
				
				if (line.yFrom>line.yTo) {
					propertiesObject["yFrom"] = line.yFrom-line.yTo;
					propertiesObject["yTo"] = 0;
					properties.push("yFrom");
					properties.push("yTo");
				}
				else {
					propertiesObject["yFrom"] = 0;
					propertiesObject["yTo"] = line.yTo-line.yFrom;
					properties.push("yFrom");
					properties.push("yTo");
				}
			}
			else {
				if ("verticalCenter" in element && element.verticalCenter!=undefined) {
					properties.push("verticalCenter");
					propertiesObject.verticalCenter = 0;
				}
				else if ("top" in element && element.top!=undefined) {
					properties.push("top");
					propertiesObject.top = 0;
				}
				else {
					properties.push("y");
					propertiesObject.y = 0;
				}
				
				if ("horizontalCenter" in element && element.horizontalCenter!=undefined) {
					properties.push("horizontalCenter");
					propertiesObject.horizontalCenter = 0;
				}
				else if ("left" in element && element.left!=undefined) {
					properties.push("left");
					propertiesObject.left = 0;
				}
				else {
					properties.push("x");
					propertiesObject.x = 0;
				}
			}
			
			Radiate.setProperties(element, properties, propertiesObject);
		}
		
		public static function roundPositionToIntegers(element:Object):void {
			var topValue:Object;
			var bottomValue:Object;
			var verticalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var yFrom:Number;
			var yTo:Number;
			var yDiff:Number;
			var xFrom:Number;
			var xTo:Number;
			var xDiff:Number;
			var reversed:Boolean;
			
			
			if (element is Line) {
				line = element as Line;
				
				if (line.xFrom>line.xTo) {
					propertiesObject["xFrom"] = line.xFrom-line.xTo;
					propertiesObject["xTo"] = Math.round(line.xTo);
					properties.push("xFrom");
					properties.push("xTo");
				}
				else {
					propertiesObject["xFrom"] = Math.round(line.xFrom);
					propertiesObject["xTo"] = line.xTo-line.xFrom;
					properties.push("xFrom");
					properties.push("xTo");
				}
				
				if (line.yFrom>line.yTo) {
					propertiesObject["yFrom"] = line.yFrom-line.yTo;
					propertiesObject["yTo"] = Math.round(line.yTo);
					properties.push("yFrom");
					properties.push("yTo");
				}
				else {
					propertiesObject["yFrom"] = Math.round(line.yFrom);
					propertiesObject["yTo"] = line.yTo-line.yFrom;
					properties.push("yFrom");
					properties.push("yTo");
				}
			}
			else {
				if ("verticalCenter" in element && element.verticalCenter!=undefined) {
					properties.push("verticalCenter");
					propertiesObject.verticalCenter = Math.round(element.verticalCenter);
				}
				else if ("top" in element && element.top!=undefined) {
					properties.push("top");
					propertiesObject.top = Math.round(element.top);
				}
				else {
					properties.push("y");
					propertiesObject.y = Math.round(element.y);
				}
				
				if ("horizontalCenter" in element && element.horizontalCenter!=undefined) {
					properties.push("horizontalCenter");
					propertiesObject.horizontalCenter = Math.round(element.horizontalCenter);
				}
				else if ("left" in element && element.left!=undefined) {
					properties.push("left");
					propertiesObject.left = Math.round(element.left);
				}
				else {
					properties.push("x");
					propertiesObject.x = Math.round(element.x);
				}
			}
			
			Radiate.setProperties(element, properties, propertiesObject);
		}
	}
}