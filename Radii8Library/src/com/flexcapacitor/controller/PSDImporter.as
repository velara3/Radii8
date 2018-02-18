package com.flexcapacitor.controller {
	import com.durej.PSDParser.PSDLayer;
	import com.durej.PSDParser.PSDParser;
	import com.flexcapacitor.effects.file.LoadFile;
	import com.flexcapacitor.managers.ComponentManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class PSDImporter extends Console {
		
		public function PSDImporter() {
			
		}
		
		
		
		/**
		 * Adds PSD to the document. <br/>
		 * Adds assets to the library and document<br/>
		 * Missing support for masks, shapes and text (text is shown as image)<br/>
		 * Takes quite a while to import. <br/>
		 * Could use performance testing.
		 * */
		public static function addPSDToDocument(documentThatPasteOfFilesToBeLoadedOccured:IDocument, psdFileData:ByteArray, iDocument:IDocument, 
												matchDocumentSizeToPSD:Boolean = true, addToAssets:Boolean = true, 
												pasteFileLoader:LoadFile = null, dropFileLoader:LoadFile = null):void {
			var radiate:Radiate = Radiate.instance;
			var componentDefinition:ComponentDefinition;
			var application:Object;
			var componentInstance:Object;
			var componentDescription:ComponentDescription;
			var path:String;
			var bitmapData:BitmapData;
			var psdParser:PSDParser;
			var numberOfLayers:int;
			var properties:Array = [];
			var propertiesObject:Object; // could be causing performance issues - try typed
			var psdLayer:PSDLayer;
			var compositeBitmapData:BitmapData;
			var compositeWidth:int;
			var compositeHeight:int;
			var addCompositeImage:Boolean;
			var imageData:ImageData;
			var blendModeKey:String;
			var blendMode:String;
			var insideFolder:Boolean;
			var isFolderVisible:Boolean;
			var layerType:String;
			var layerName:String;
			var folderName:String;
			var layerVisible:Boolean;
			var layers:Array;
			var layersAndFolders:Dictionary;
			var parentInstance:Object;
			var layerFilters:Array;
			var layerID:int;
			var parentLayerID:int;
			var currentFolders:Array = [];
			var foldersDictionary:Object = [];
			var xOffset:int;
			var yOffset:int;
			var parentGroup:Object;// could be causing performance issues - try typed
			var hasShapes:Boolean;
			var hasMasks:Boolean;
			var resized:Boolean;
			var showInfo:Boolean = false;
			var testForErrors:Boolean = false;
			var time:int;
			var setDefaultsPre:Boolean = true;
			var setDefaultsPost:Boolean = false;
			
			addCompositeImage = true;
			
			layersAndFolders = new Dictionary(true);
			
			application = iDocument && iDocument.instance ? iDocument.instance : null;
			
			// is iDocument and this variable the same? when is this not the same???
			if (documentThatPasteOfFilesToBeLoadedOccured==null) {
				documentThatPasteOfFilesToBeLoadedOccured = iDocument;
			}
			
			//setupPasteFileLoader();
			
			psdParser = PSDParser.getInstance();
			
			time = getTimer();
			
			if (testForErrors) {
				psdParser.parse(psdFileData);
			}
			
			try {
				if (!testForErrors) {
					psdParser.parse(psdFileData);
				}
			}
			catch (errorObject:*) {
				var errorMessage:String;
				var stack:String;
				
				if ("getStackTrace" in errorObject) {
					stack = errorObject.getStackTrace();
				}
				
				if (errorObject) {
					errorMessage = Object(errorObject).toString();
				}
				
				error("Could not import the PSD. " + errorMessage, errorObject);
				
				pasteFileLoader ? pasteFileLoader.removeReferences(true) : -1;
				dropFileLoader ? dropFileLoader.removeReferences(true) : -1;
				
				return;
			}
			
			time = getTimer() - time;
			
			//layersLevel = iDocument.instance;
			//this.addChild(layersLevel);
			
			layers = psdParser.allLayers ? psdParser.allLayers : [];
			numberOfLayers = layers ? layers.length : 0;
			
			info("Time to import: " + int(time/1000) + " seconds. Number of layers: " + numberOfLayers);
			
			compositeBitmapData = psdParser.composite_bmp;
			compositeWidth		= compositeBitmapData ? compositeBitmapData.width : 0;
			compositeHeight		= compositeBitmapData ? compositeBitmapData.height : 0;
			
			// add composite of the PSD
			if (addCompositeImage || numberOfLayers==0) {
				
				componentDefinition 		= ComponentManager.getComponentType("Image");
				componentInstance 			= ComponentManager.createComponentToAdd(iDocument, componentDefinition, setDefaultsPre);
				
				propertiesObject 			= {};
				propertiesObject.source 	= compositeBitmapData;
				
				propertiesObject.visible 	= numberOfLayers==0 ? true : false;
				
				properties.push("source");
				properties.push("visible");
				
				Radiate.addElement(componentInstance, application, properties, null, null, propertiesObject);
				
				Radiate.updateComponentAfterAdd(iDocument, componentInstance, setDefaultsPost);
				
				componentDescription = iDocument.getItemDescription(componentInstance);
				
				if (numberOfLayers!=0) {
					componentDescription.locked = true;
					componentDescription.visible = propertiesObject.visible;
					componentDescription.name = "Composite Layer";
				}
				
				if (addToAssets) {
					imageData = new ImageData();
					imageData.bitmapData = compositeBitmapData;
					imageData.name = "Composite Layer";
					imageData.layerInfo = psdLayer;
					
					radiate.addAssetToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured, false);
				}
			}
			
			if (numberOfLayers==0 && compositeBitmapData==null) {
				warn("The PSD did not contain any readable layers.");
				pasteFileLoader ? pasteFileLoader.removeReferences(true) : -1;
				dropFileLoader ? dropFileLoader.removeReferences(true) : -1;
				
				if (addToAssets && imageData) {
					radiate.dispatchAssetAddedEvent(imageData);
				}
				
				radiate.dispatchAssetLoadedEvent(imageData, documentThatPasteOfFilesToBeLoadedOccured, false, false);
				
				return;
			}
			
			
			
			// Layer groups are being parsed and they are also PSDLayer class type.
			
			// There are 4 layer types :
			// LayerType_FOLDER_OPEN, LayerType_FOLDER_CLOSED , 
			// LayerType_HIDDEN and LayerType_NORMAL.
			
			// Layer folder hidden is marker for the end of the layer group. 
			// So if you want to parse the folder structure, check where the layer type folder 
			// starts and then every layer that follows is inside of that folder, 
			// until you reach layer type hidden.
			
			// order from top to bottom from PSD
			layers.reverse();
			
			// loop through layers and get the folders 
			for (var a:int;a<numberOfLayers;a++)  {
				psdLayer					= layers[a];
				layerType 					= psdLayer.type;
				layerID 					= psdLayer.layerID;
				layerName 					= psdLayer.name;
				layersAndFolders[layerID] 	= psdLayer;
				
				// create groups 
				if (layerType==PSDLayer.LayerType_FOLDER_OPEN || 
					layerType==PSDLayer.LayerType_FOLDER_CLOSED) {
					insideFolder = true;
					isFolderVisible = psdLayer.isVisible;
					folderName = psdLayer.name;
					parentLayerID = layerID;
					
					// get last added folder id
					if (currentFolders.length) {
						psdLayer.parentLayerID = currentFolders[0];
					}
					
					
					componentDefinition 		= ComponentManager.getComponentType("Group");
					
					componentInstance 			= ComponentManager.createComponentToAdd(iDocument, componentDefinition, setDefaultsPre);
					
					propertiesObject 			= {};
					propertiesObject.x 			= 0;
					propertiesObject.y			= 0;
					propertiesObject.lowestX 	= [];
					propertiesObject.lowestY	= [];
					
					// properties to set
					properties = [];
					
					// properties to set
					properties.push("x");
					properties.push("y");
					
					if (psdLayer.alpha!=1) {
						propertiesObject.alpha 	= psdLayer.alpha;
						properties.push("alpha");
					}
					
					if (psdLayer.isVisible==false) {
						propertiesObject.visible = false;
						properties.push("visible");
					}
					
					if (psdLayer.blendModeKey!="norm") {
						blendMode = DisplayObjectUtils.getBlendModeByKey(psdLayer.blendModeKey);
						
						if (blendMode) {
							propertiesObject.blendMode 	= blendMode;
							properties.push("blendMode");
						}
					}
					
					parentGroup = {};
					parentGroup.properties = properties;
					parentGroup.propertiesObject = propertiesObject;
					parentGroup.instance = componentInstance;
					parentGroup.parentID = currentFolders && currentFolders.length ? currentFolders[0] : 0;
					
					foldersDictionary[layerID] = parentGroup;
					
					if (showInfo) {
						trace("Creating folder properties for " + layerID + " " + layerName);
					}
					
					// add group layer id ordered as depth
					currentFolders.unshift(layerID);
					
				}
				else if (layerType==PSDLayer.LayerType_HIDDEN) {
					insideFolder = false;
					isFolderVisible = false;
					folderName = null;
					layerID = currentFolders.shift();
					
					parentGroup = foldersDictionary[layerID];
					
					// set the group location to start where the contents start - later subtract the difference
					parentGroup.propertiesObject.x = Math.min.apply(null, parentGroup.propertiesObject.lowestX);
					parentGroup.propertiesObject.y = Math.min.apply(null, parentGroup.propertiesObject.lowestY);
					
				}
				else if (layerType==PSDLayer.LayerType_NORMAL) {
					
					if (currentFolders.length) {
						psdLayer.parentLayerID = currentFolders[0];
						parentGroup = foldersDictionary[currentFolders[0]];
						
						while (parentGroup) {
							parentGroup.propertiesObject.lowestX.push(psdLayer.position.x);
							parentGroup.propertiesObject.lowestY.push(psdLayer.position.y);
							parentGroup = foldersDictionary[parentGroup.parentID];
						}
					}
					else {
						psdLayer.parentLayerID = 0;
					}
				}
				
			}
			
			// order from bottom to top from PSD
			layers.reverse();
			
			
			// loop through layers and create properties object with layer destination
			for (var i:int;i<numberOfLayers;i++)  {
				psdLayer				= psdParser.allLayers[i];
				bitmapData				= psdLayer.bmp;
				
				layerType 				= psdLayer.type;
				layerVisible 			= psdLayer.isVisible;
				layerName 				= psdLayer.name;
				layerFilters			= psdLayer.filters_arr;
				layerID					= psdLayer.layerID;
				
				parentLayerID 			= psdLayer.parentLayerID;
				
				parentGroup 			= foldersDictionary[parentLayerID];
				
				if (parentGroup) {
					xOffset = 0;
					yOffset = 0;
					
					// get different in location when layers are added to groups
					while (parentGroup) {
						xOffset += parentGroup.propertiesObject.x;
						yOffset += parentGroup.propertiesObject.y;
						parentGroup = foldersDictionary[parentGroup.parentID];
					}
				}
				else {
					xOffset = 0;
					yOffset = 0;
				}
				
				if (layerType==PSDLayer.LayerType_FOLDER_OPEN || 
					layerType==PSDLayer.LayerType_FOLDER_CLOSED ||
					layerType==PSDLayer.LayerType_HIDDEN) {
					
					if (showInfo) {
						trace("Looping through layers excluding folder " + layerID + " " + layerName);
					}
					
					continue;
				}
				
				if (showInfo) {
					trace("Looping through layers adding " + layerID + " " + layerName);
				}
				
				if (layerID==0 && showInfo) {
					trace("  - shape");
					hasShapes = true;
				}
				
				// need to keep track of errors during import
				if (bitmapData==null) {
					continue;
				}
				else if (bitmapData.width==0 || bitmapData.height==0) {
					continue;
				}
				
				componentDefinition 		= ComponentManager.getComponentType("Image");
				
				componentInstance 			= ComponentManager.createComponentToAdd(iDocument, componentDefinition, setDefaultsPre);
				
				propertiesObject 			= {};
				propertiesObject.source 	= bitmapData;
				propertiesObject.x 			= psdLayer.position.x - xOffset;
				propertiesObject.y 			= psdLayer.position.y - yOffset;
				
				// properties to set
				properties = [];
				
				// properties to set
				properties.push("x");
				properties.push("y");
				properties.push("source");
				
				if (psdLayer.alpha!=1) {
					propertiesObject.alpha 	= psdLayer.alpha;
					properties.push("alpha");
				}
				
				if (psdLayer.isVisible==false) {
					propertiesObject.visible = false;
					properties.push("visible");
				}
				
				if (psdLayer.blendModeKey!="norm") {
					blendMode = DisplayObjectUtils.getBlendModeByKey(psdLayer.blendModeKey);
					
					if (blendMode) {
						propertiesObject.blendMode 	= blendMode;
						properties.push("blendMode");
					}
				}
				
				if (layerFilters && layerFilters.length) {
					propertiesObject.filters = layerFilters;
					properties.push("filters");
				}
				
				if (parentLayerID!=0) {
					parentGroup = foldersDictionary[parentLayerID];
					parentInstance = parentGroup.instance;
				}
				else {
					parentInstance = application;
				}
				
				// if on level 0 - no parent - add it in next loop so we keep the
				// layer order
				//if (parentLayerID==0) {
				
				parentGroup 					= {};
				parentGroup.properties 			= properties;
				parentGroup.propertiesObject 	= propertiesObject;
				parentGroup.instance 			= componentInstance;
				parentGroup.parentInstance 		= parentInstance;
				
				foldersDictionary[layerID] 		= parentGroup;
				
			}
			
			// add folders to document
			
			var customParent:Object;
			
			// loop through layers and add folders and top level layers 
			for (var b:int;b<numberOfLayers;b++)  {
				psdLayer		= layers[b];
				layerType 		= psdLayer.type;
				layerName 		= psdLayer.name;
				layerID 		= psdLayer.layerID;
				parentLayerID	= psdLayer.parentLayerID;
				parentGroup 	= foldersDictionary[layerID];
				
				if (parentGroup==null) {
					continue;
				}
				
				//trace("adding " +  psdLayer.name + " ("+ layerID+")");
				// get parent folder if one exists
				customParent = parentLayerID!=0 ? foldersDictionary[parentLayerID] : null;
				
				parentInstance = customParent ? customParent.instance : application;
				
				componentInstance = parentGroup.instance;
				
				if (showInfo) {
					trace("Adding layer " + layerName + " to group " + parentLayerID);
				}
				
				Radiate.addElement(componentInstance, parentInstance, parentGroup.properties, null, null, parentGroup.propertiesObject);
				
				Radiate.updateComponentAfterAdd(iDocument, componentInstance, setDefaultsPost);
				
				componentDescription = iDocument.getItemDescription(componentInstance);
				
				if (componentDescription) {
					componentDescription.locked = psdLayer.isLocked;
					componentDescription.visible = psdLayer.isVisible;
					componentDescription.name = psdLayer.name;
					componentDescription.layerInfo = psdLayer;
				}
				
				if (addToAssets && layerType==PSDLayer.LayerType_NORMAL) {
					imageData = new ImageData();
					imageData.bitmapData = psdLayer.bmp;
					imageData.name = psdLayer.name;
					imageData.layerInfo = psdLayer;
					
					radiate.addAssetToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured, false);
				}
			}
			
			// remove file references
			if (pasteFileLoader) {
				pasteFileLoader.removeReferences(true);
			}
			
			// remove file references
			if (dropFileLoader) {
				dropFileLoader.removeReferences(true);
			}
			
			const WIDTH:String = "width";
			const HEIGHT:String = "height";
			
			if (matchDocumentSizeToPSD) {
				resized = RadiateUtilities.sizeDocumentToBitmapData(documentThatPasteOfFilesToBeLoadedOccured, compositeBitmapData);
			}
			
			// dispatch event 
			if (addToAssets && imageData) {
				radiate.dispatchAssetAddedEvent(imageData);
			}
			
			if (hasShapes || hasMasks) {
				info("A PSD was partially imported. It does not fully support shapes or masks. Be sure to upload the images added to the Library.");
			}
			else {
				info("A PSD was imported. Be sure to upload the images added to the Library.");
			}
			
			radiate.setTarget(iDocument.instance);
			
			imageData = Radiate.getImageDataFromBitmapData(compositeBitmapData);
			
			radiate.dispatchAssetLoadedEvent(imageData, documentThatPasteOfFilesToBeLoadedOccured, resized, true);
		}
	}
}