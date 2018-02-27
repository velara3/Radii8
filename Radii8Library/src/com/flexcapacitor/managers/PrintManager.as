package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	
	import mx.core.IUIComponent;
	import mx.graphics.ImageSnapshot;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import spark.primitives.BitmapImage;

	/**
	 * For printing
	 **/
	public class PrintManager {
		
		public function PrintManager() {
			
		}
		
		/**
		 * Print
		 * */
		public static function print(data:Object, scaleType:String = FlexPrintJobScaleType.MATCH_WIDTH, printAsBitmap:Boolean = false):Object {
			var flexPrintJob:FlexPrintJob = new FlexPrintJob();
			var radiate:Radiate = Radiate.instance;
			var printableObject:IUIComponent;
			var scaleX:Number;
			var scaleY:Number;
			
			if (data is IDocument) {
				printableObject = IUIComponent(IDocument(data).instance)
			}
			else if (data is IUIComponent) {
				printableObject = IUIComponent(data);
			}
			else {
				Radiate.error("Printing failed: Object is not of accepted type.");
				return false;
			}
			
			if (data && "scaleX" in data) {
				scaleX = data.scaleX;
				scaleY = data.scaleY;
			}
			
			flexPrintJob.printAsBitmap = printAsBitmap;
			
			if (printAsBitmap && data is IBitmapDrawable) {
				var imageBitmapData:BitmapData = ImageSnapshot.captureBitmapData(IBitmapDrawable(data));
				var bitmapImage:BitmapImage = new BitmapImage();
				bitmapImage.source = new Bitmap(imageBitmapData);
				//data = bitmapImage;
			}
			
			// show OS print dialog
			// printJobStarted is false if user cancels OS print dialog
			var printJobStarted:Boolean = flexPrintJob.start();
			
			
			// if user cancels print job and we continue then the stage disappears! 
			// so we exit out (ie we don't do the try statement)
			// workaround if we set the scale it reappears 
			// so, scaleX and scaleY are set to NaN on the object when we try to print and it fails
			if (!printJobStarted) {
				Radiate.error("Print job was not started");
				Radiate.dispatchPrintCancelledEvent(data, flexPrintJob);
				return false;
			}
			
			try {
				//info("Print width and height: " + flexPrintJob.pageWidth + "x" + flexPrintJob.pageHeight);
				flexPrintJob.addObject(printableObject, scaleType);
				flexPrintJob.send();
				Radiate.dispatchPrintCompleteEvent(data, flexPrintJob);
			}
			catch(e:Error) {
				// CHECK scale X and scale Y to see if they are null - see above
				if (data && "scaleX" in data && data.scaleX!=scaleX) {
					data.scaleX = scaleX;
					data.scaleY = scaleY;
				}
				
				// Printing failed: Error #2057: The page could not be added to the print job.
				Radiate.error("Printing failed: " + e.message);
				
				// TODO this should be print error event
				Radiate.dispatchPrintCancelledEvent(data, flexPrintJob);
				return false;
			} 
			
			return true;
		}
	}
}