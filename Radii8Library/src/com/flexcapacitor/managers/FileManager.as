package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.controller.RadiateUtilities;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	
	import spark.components.Application;

	/**
	 * Manage saving to file
	 **/
	public class FileManager extends Console {
		
		public function FileManager() {
			
		}
		
		/**
		 * Get the current document.
		 * */
		public static function get selectedDocument():IDocument {
			return Radiate.selectedDocument;
		}
		
		/**
		 * Get the current project.
		 * */
		public static function get selectedProject():IProject {
			return Radiate.selectedProject;
		}
		
		/**
		 * Save multiple files
		 * */
		public static function saveFiles(sourceData:SourceData, directory:Object, overwrite:Boolean = false):Boolean {
			var file:Object;
			var files:Array = sourceData.files;
			var fileName:String;
			var numberOfFiles:int = files ? files.length : 0;
			var fileClassDefinition:String = "flash.filesystem.File";
			var fileStreamDefinition:String = "flash.filesystem.FileStream";
			var FileClass:Object = ClassUtils.getDefinition(fileClassDefinition);
			var FileStreamClass:Object = ClassUtils.getDefinition(fileStreamDefinition);
			var fileStream:Object;
			var writeFile:Boolean;
			var filesCreated:Boolean;
			var fileInfo:FileInfo;
			
			for (var i:int;i<numberOfFiles;i++) {
				fileInfo = files[i];
				fileInfo.created = false;
				fileName = fileInfo.fileName + "." + fileInfo.fileExtension;
				
				if (!directory.exists) {
					directory.createDirectory();
				}
				
				file = directory.resolvePath(fileName);
				
				if (file.exists && !overwrite) {
					writeFile = false;
				}
				else {
					writeFile = true;
				}
				
				if (writeFile) {
					fileStream = new FileStreamClass();
					// this might be causing an error on windows - might need to change to read / write
					fileStream.open(file, "write");// FileMode.WRITE
					fileStream.writeUTFBytes(fileInfo.contents);
					fileStream.close();
					fileInfo.created = true;
					fileInfo.filePath = file.nativePath;
					fileInfo.url = file.url;
					filesCreated = true;
				}
			}
			
			return filesCreated;
		}
		
		/**
		 * Save file as
		 * */
		public static function saveFileAs(data:Object, name:String = "", extension:String = null):FileReference {
			var fileReference:FileReference;
			var fileName:String;
			
			fileName = name==null ? "" : name;
			
			if (fileName.indexOf(".")==-1 && data) {
				if (extension) {
					fileName = fileName + "." + extension;
				}
				else if ("fileExtension" in data && data.fileExtension) {
					fileName = fileName + "." + data.fileExtension;
				}
				else if ("extension" in data && data.extension) {
					fileName = fileName + "." + data.extension;
				}
			}
			
			// FOR SAVING A FILE (save as) WE MAY NOT NEED ALL THE LISTENERS WE ARE ADDING
			// add listeners
			fileReference = new FileReference();
			addFileSaveAsListeners(fileReference);
			
			if (data && !(data is String) && data is Object && "contents" in data) {
				fileReference.save(data.contents, fileName);
			}
			else {
				fileReference.save(data, fileName);
			}
			
			return fileReference;
		}
		
		/**
		 * Save target as image.
		 * */
		public static function saveAsImage(target:Object, options:Object = null):Boolean {
			var bitmapData:BitmapData;
			var fileName:String;
			var componentDescription:ComponentDescription;
			var result:Object;
			
			if (target==null) {
				error("No document to save");
				return false;
			}
			
			if (target is ComponentDescription) {
				componentDescription = target as ComponentDescription;
				target = componentDescription.instance;
			}
			else {
				componentDescription = selectedDocument.getItemDescription(target);
			}
			
			if (componentDescription) {
				fileName = componentDescription.name;
			}
			else {
				fileName = selectedDocument.name;
			}
			
			if (target) {
				if (target is IDocument || target is Application) {
					if (target is IDocument) {
						target = IDocument(target).instance;
					}
					
					//target = DisplayObjectUtils.getAnyTypeBitmapData(IDocument(target).instance);
					// we are using StageQuality to BEST since using anything higher shrinks the text (.75 / 1.25) if the font is
					// not embedded (currently found up to FP 25)
					
					// also, if we are taking a snapshot of the document we need to clip the edges
					// and not include anything outside of the visible rectangle
					// using getSnapshot which clips the UIComponent 
					result = ImageManager.getSnapshot(target as UIComponent, 1, StageQuality.BEST);
					
					if (result is Error) {
						Radiate.warn("An error occurred. " + (result as SecurityError));
					}
					else {
						bitmapData = result as BitmapData;
					}
				}
				else {
					try {
						bitmapData = DisplayObjectUtils.getAnyTypeBitmapData(target, StageQuality.BEST);
					}
					catch (errorEvent:ErrorEvent) {
						error(errorEvent.text, errorEvent);
					}
				}
				
				var byteArray:ByteArray;
				
				if (bitmapData) {
					if (bitmapData.width!=0 && bitmapData.height) {
						byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(bitmapData);
						saveFileAs(byteArray, fileName, "png");
						return true;
					}
					else {
						error("Selection must have a width and height greater than 0");
					}
				}
			}
			
			return false;
		}
		
		/**
		 * Adds file save as listeners. Rename or refactor
		 * */
		public static function addFileSaveAsListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.CANCEL, cancelFileSaveAsHandler, false, 0, true);
			dispatcher.addEventListener(Event.COMPLETE, completeFileSaveAsHandler, false, 0, true);
		}
		
		/**
		 * Removes file save as listeners. Rename or refactor
		 * */
		public static function removeFileListeners(dispatcher:IEventDispatcher):void {
			dispatcher.removeEventListener(Event.CANCEL, cancelFileSaveAsHandler);
			dispatcher.removeEventListener(Event.COMPLETE, completeFileSaveAsHandler);
		}
		
		/**
		 * File save as complete
		 * */
		public static function completeFileSaveAsHandler(event:Event):void {
			removeFileListeners(event.currentTarget as IEventDispatcher);
			
			Radiate.dispatchDocumentSaveCompleteEvent(Radiate.selectedDocument);
		}
		
		/**
		 * Cancel file save as
		 * */
		public static function cancelFileSaveAsHandler(event:Event):void {
			removeFileListeners(event.currentTarget as IEventDispatcher);
			
			Radiate.dispatchDocumentSaveAsCancelEvent(Radiate.selectedDocument);
		}
	}
}