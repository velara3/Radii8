/*
package com.flexcapacitor.utils {
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	
	public class MXMLImporter extends EventDispatcher {
		public function MXMLImporter(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}*/

	

package com.flexcapacitor.utils {
/*
	import com.hurlant.eval.ByteLoader;
	import com.hurlant.eval.CompiledESC;
	
	import es.xperiments.itemRenderers.Renderer;
	import es.xperiments.itemRenderers.RendererButton;
	import es.xperiments.utils.logging.Log;*/
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.controls.DataGrid;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.styles.IStyleClient;

	
	/**
	 * Import MXML. Parts based on Live MXML. 
	 * http://code.google.com/p/livemxml/
	 * 
	 * 
	 * 
	 * A way to load dynamically limited mxml files and compile it on the fly.
	 * - Based on the Class MXMLLoader from Manish Jethani.
	 *  http://manishjethani.com/blog/2008/04/02/the-mxmlloader-component/
	 *  http://www.xperiments.es/blog  
	 * */
	public class MXMLImporter extends EventDispatcher {
		//Dependencies
		// if you need a new component type, you need to declare it here
		
		public static var baseCode:XML = <code>
		<![CDATA[
		namespace xperimentsMXML = "es.xperiments.mxml";
		use namespace xperimentsMXML;
		
		import mx.core.*;
		import flash.net.*;
		import mx.controls.*;
		import es.xperiments.itemRenderers.*;
		
		
		
		var radioGroup:RadioButtonGroup = new RadioButtonGroup( );			
		function $( name:String ):UIComponent
		{
			return MXMLImporter.getChildByIds(idString, name);
		}
		function $DGC( name:String ):DataGridColumn
		{
			return MXMLImporter.getChildByIds(idString, name);
		}
		]]>
		</code>;
		
		public static var MXMLLoaderArray:Array = new Array( );
		public var idString:String;
		
		// Dummy instances for code insertion
		//private var _rte:RichTextEditor = new RichTextEditor();
		private var _classFactory:ClassFactory = new ClassFactory();
		private var _f:FileReference;
		
		/*
		private var _datagridColumn:DataGridColumn;
		private var _label:Label;
		private var _textInput:TextInput;
		private var _button:Button;
		private var _hBox:HBox;
		private var _panel:Panel;
		private var _vbox:VBox;
		private var _accordion:Accordion;
		private var _form:Form;
		private var _rbg:RadioButtonGroup;
		private var _rb:RadioButton;
		private var _cp:ColorPicker;
		private var _hslider:HSlider;
		private var _comboBox:ComboBox;
		private var _alert:Alert;*/
		
		
		private var _container:IVisualElement;
				
		private var _ids:Dictionary;

		private var _scriptContext:Object;
		//public static const esc:CompiledESC = new CompiledESC();

		private var _startCode:String = "";
		private var _initCode:String = "";
		public var document:IDocument;

		/**
		 * Refactor this
		 * */
		public function MXMLImporter(iDocument:IDocument, idStr:String, mxml:XML, container:IVisualElement) {
			idString = idStr;
			_container = container;
			_ids = new Dictionary();
			_initCode = "";
			_startCode = "";
			document = iDocument;
			
			
			var elName:String = mxml.localName();
			
			var timer:int = getTimer(); 
			
			Radiate.importingDocument = true;
			
			// TODO this is a special case we check for since 
			// we should have already created the application by now
			// we should handle this case before we get here (pass in the children of the application xml not application itself)
			if (elName=="Application") {
				Radiate.setAttributesOnComponent(document.instance, mxml);
			}
			else {
				createChildFromMXMLNode(mxml, container);
			}
			
			
			for each (var childNode:XML in mxml.children()) {
				
				if (String(childNode.name()).toLowerCase()=="script") {
					//new FrameDelay( parseScript,2,[ childNode ] );
				}
				else {
					createChildFromMXMLNode(childNode, container);
					//new FrameDelay( onComplete, 2 );
				}
			}
			
			Radiate.importingDocument = false;
			
			// using importing document flag it goes down from 5 seconds to 1 second
			//Radiate.log.info("Time to import: " + (getTimer()-timer));
			
			MXMLImporter.MXMLLoaderArray[ idString ] = this;
		}
		
		/**
		 * 
		 * */
		public static function getChildByIds(idString:String, name:String ):* {
			return MXMLImporter(MXMLImporter.MXMLLoaderArray[idString]).getChildById(name);
		}
		
		/**
		 * 
		 * */
		public function getChildById(id:String):* {
			return _ids[id];
		}
		
		/**
		 * 
		 * */
		public function parseScript(childNode:XML):void {
			// Parse Soruce text and replace import staments
			var inSrc:String = childNode.text();
            var src:String = String( baseCode ).split( 'idString' ).join( "'"+idString+"'" )+'\n'+_initCode+'\n'+inSrc+'\n'+_startCode;
			var import_staments_matches:Array = src.match( new RegExp('import [ a-z A-Z .* ]*','gi'));
			
			for (var i:uint = 0; i<import_staments_matches.length; i++ ) {
				var import_line:String = import_staments_matches[ i ];
				var className:String = import_line.split(" ")[ 1 ];
				var classNameParser:String = className.indexOf('*') !=-1 ? className.substr( 0, className.lastIndexOf('.') ):className;
				var classNameParserBeauty:String = classNameParser.split('.').join('');
				var outStr:String = 'namespace '+classNameParserBeauty+' = "'+classNameParser+'";';
				
				outStr+= 'use namespace '+classNameParserBeauty+';\n';
				src = src.replace( new RegExp( import_line,'gi'), outStr );	
			}
			
            /*
			Log.log( src );
            var bytes:ByteArray = esc.eval( src );
			ByteLoader.loadBytes(bytes);*/
			
			onComplete();		
		}
		
		/**
		 * 
		 * */
		private function onComplete( ):void {
			dispatchEvent(new MXMLImporterEvent( MXMLImporterEvent.INITIALIZE, idString ) );
		}

		/**
		 * 
		 * */
		private function createChildFromMXMLNode(node:XML, parent:Object):IVisualElement {
			var elementName:String = node.localName();
			var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			var componentDefinition:ComponentDefinition = Radiate.getDynamicComponentType(elementName);
			var className:String;
			var classType:Class;
			var currentDataProviderString:String; // current dataProvider
			var ignoreChildren:Boolean = false;
			var instance:Object;
			var instanceID:String;
			var attributeName:String;
			var attribute:XML;
			var array:Array;
			var functionName:String;
			
			if (componentDefinition==null) {
				
			}
			
			className =componentDefinition ? componentDefinition.className :null;
			classType = componentDefinition ? componentDefinition.classType as Class :null;
			
			
			if (componentDefinition==null && elementName!="RootWrapperNode") {
				var message:String = "Could not find definition for " + elementName + ". The document will be missing elements.";
				//message += " Add this class to Radii8LibrarySparkAssets.sparkManifestDefaults or add the library to the project that contains it.";
				Radiate.log.error(message);
				return null;
			}
			
			// classes to look into for decoding XML
			// XMLDecoder, SchemaTypeRegistry, SchemaManager, SchemaProcesser
			
			
			// special case for radio button group
			/*var object:* = SchemaTypeRegistry.getInstance().getClass(classType);
			var object2:* = SchemaTypeRegistry.getInstance().getClass(elementName);
			var object3:* = SchemaTypeRegistry.getInstance().getClass(node);
			var sm:mx.rpc.xml.SchemaManager = new mx.rpc.xml.SchemaManager();
			
			sm.addNamespaces({s:new Namespace("s", "library://ns.adobe.com/flex/spark")});
			var o:Object = sm.unmarshall(node);
			
			var q:QName = new QName(null, elementName);*/
			//var object2:* = SchemaTypeRegistry.getInstance().registerClass(;
			
	
			if (className!="mx.controls.RadioButtonGroup" && componentDefinition!=null) {
				//instance = new classType();
				instance = Radiate.createComponentForAdd(document, componentDefinition, true);
				instanceID = "";
				//Radiate.log.info("MXML Importer adding: " + elementName);
				
				// calling add before setting properties because some 
				// properties such as borderVisible need to be set after 
				// the component is added (maybe)
				Radiate.addElement(instance, parent);
				
				Radiate.setAttributesOnComponent(instance, node);
				/*for each (attribute in node.attributes()) {
					attributeName = attribute.name().toString();
					//Radiate.log.info(" found attribute: " + attributeName); 
					
					// check if property 
					if (attributeName in instance) {
						
						//Radiate.log.info(" setting property: " + attributeName);
						Radiate.setProperty(instance, attributeName, attribute.toString());
					 	
					}
					
					// could be style or event
					else {
						if (instance is IStyleClient) {
							//Radiate.log.info(" setting style: " + attributeName);
							Radiate.setStyle(instance, attributeName, attribute.toString());
						}
					}
				}*/
				
			}
			
			
			
			if (!ignoreChildren) {
				
				for each (var childNode:XML in node.children()) {
					createChildFromMXMLNode(childNode, instance);
				}
			}
			
			return instance as IVisualElement;
			
			
			
			// original code
			
			if (className!="mx.controls.RadioButtonGroup") {
				//instance = new classType();
				instance = Radiate.createComponentForAdd(componentDefinition, false);
				instanceID = "";
				
				for each (attribute in node.attributes()) {
					attributeName = attribute.name().toString();
					
					// check if property 
					if (attributeName in instance) {
						
						switch(attributeName) {
							case "width" :
							case "height":
								// Convert width="x%" to percentWidth="x"
								array = attribute.toString().split("%");
								
								if (array.length > 1) {
									if (attributeName == "width")
										instance.percentWidth = Number(array[0]);
									else
										instance.percentHeight = Number(array[0]);
								} else {
									instance[attributeName] = Number(attribute.toString());
								}
								break;				
							case "id" : 					
								_ids[ attribute.toString() ]=instance;
								instanceID = attribute.toString();
								//_initCode+='var '+instanceID+':UIComponent = $("'+instanceID+'");\n';

								break;
							case "dataProvider":
								currentDataProviderString = attribute.toString( );
								//instance['dataProvider'] = D.eval( attribute.toString( ) );
								break;
						
							default : 
								instance[attributeName] = attribute.toString();
								break;
						}
					 	
					}
					
					// could be style or event
					else {
						functionName = attribute.toString().substring(0,attribute.toString().indexOf("("));
					 	
					 	if (attribute.toString().indexOf("(")!=-1 && 
							attribute.toString().indexOf(")")!=1 ) {
					 		_startCode += '$("'+instanceID+'").addEventListener("'+attributeName+'",'+functionName+' );\n';
					 	}
					 	else {
							if (instance is IStyleClient) {
					 			IStyleClient(instance).setStyle(attributeName, attribute.toString());
							}
							else {
								
							}
					 	}
					}
				}
				
				// special component init
				
				var dgc:DataGridColumn;
				
				switch (className) {
					
					case "mx.controls.DataGrid":
						var dataGridColumnId:String = "";
						var dg:DataGrid = (instance as DataGrid);
						var dataGridItems:XMLList  = node..*::DataGridColumn;
	 					var colsArray:Array = [];

						for each (var dataGridItem:XML in dataGridItems) {
							dgc = new DataGridColumn( );
							
							for each (attribute in dataGridItem.attributes()) {
								attributeName = attribute.name().toString();
								
								if (dgc.hasOwnProperty(attributeName)) {
									switch(attributeName) {
										case "headerText":
											dgc.headerText = attribute.toString();
											break;
										case "dataField":
											dgc.dataField = attribute.toString();
											break;
										case "itemRenderer":
											_initCode += dataGridColumnId+'.itemRenderer = new ClassFactory('+attribute.toString()+'); ';
											break;									
									}							
								}
								else {
									switch(attributeName) {
										case "id":
											dataGridColumnId = attribute.toString();
											_ids[ attribute.toString() ]=dgc;
											_initCode+='var '+attribute.toString()+':DataGridColumn = $DGC("'+attribute.toString()+'");\n';
											break;
									}
								}
							}
							
							colsArray.push( dgc );
						}
					 	
						if ( colsArray.length>0 ) {
							dg.columns = colsArray;
						}
						
					 	// dg.dataProvider = D.eval( currentDataProviderString );
					 	ignoreChildren = true;
						
						break;	
					case "mx.controls.RadioButton":
						_initCode += instanceID+'.group = '+(instance as RadioButton).groupName+';\n';
						_initCode += instanceID+'.groupName = "'+(instance as RadioButton).groupName+'";\n';					
						break;
				}
				
				Radiate.addElement(instance, parent);
				//IVisualElementContainer(parent).addElement(instance);
				
			}
			else {
				var radioButtonGroupID:String ="";
				var tmpRBG:RadioButtonGroup = new RadioButtonGroup();
				var attributeRB:XML;

				for each (attributeRB in node.attributes()) {
					var nameRB:String =  attributeRB.name().toString();

					 if (nameRB=="id") {
					 	instanceID = attributeRB.toString();
						_initCode += 'var ' + instanceID + ':RadioButtonGroup = new RadioButtonGroup();\n';
					 }
					 else {

						if (tmpRBG.hasOwnProperty(nameRB)) {
							_startCode += instanceID+'.'+nameRB+' = "' + attributeRB.toString()+'";\n'; 
						}
						else {	
							functionName = attributeRB.toString().substring(0, attributeRB.toString().indexOf("("));
							
						 	if( attributeRB.toString().indexOf("(")!=-1 && attributeRB.toString().indexOf(")")!=1 ) {
						 		_initCode += '' + instanceID + '.addEventListener("' + nameRB + '",' + functionName + ' );\n';
						 	}
						 }					 	
					 	
					 }
				}
				
			}
			
			if (!ignoreChildren) {
				
				for each (childNode in node.children()) {
					createChildFromMXMLNode(childNode, instance);
				}
			}
			
			return instance as IVisualElement;
		}
	}
}
