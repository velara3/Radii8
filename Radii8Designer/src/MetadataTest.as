package {
	import flash.display.Sprite;
	import flash.utils.describeType;
	
	/**
	 * An example of enumerating a class's Metadata information.
	 * @author Pierre Chamberlain
	 */
	[CustomMeta(param1="foo",param2="bar")]
	public class MetadataTest extends Sprite{
		
		[MemberMetaExamplePrivate]
		private var _myPrivateVar:Boolean;
		
		[MemberMetaExamplePublic]
		public var myPublicVar:String;
		
		[MemberMetaExampleConstructor]
		public function MetadataTest() {
			super();
			
			//analyzeMetadata(this);
		}
		
		public static function getMetadata(object:*):* {
			var myClass:Class 		=  Object(object).constructor;
			var xDesc:XML 			=  describeType(myClass);
			var myClassName:String 	=  xDesc.@name;
			var xMetas:XMLList 		=  xDesc.factory..metadata;
			
			//Filter the Metadata Tags belonging to this Class only:
			var xMetaParent:XML;
			var metaParents:Array = [];
			trace(xMetas);
			
			for each(var xMeta:XML in xMetas) {
				xMetaParent =  xMeta.parent();
				if (xMeta.@name.indexOf("__go_to") > -1) {
					delete xMetaParent.children()[xMeta.childIndex()];
					continue;
				}
				
				if (xMetaParent.name() == "factory") {
					metaParents.push(xMeta);
					continue;
				}
				
				var declaredBy:String =  xMetaParent.attribute("declaredBy");
				if (declaredBy && declaredBy != myClassName) {
					continue;
				}
				
				metaParents.push( xMetaParent );
			}
			
			trace(metaParents.join("\n"));
			return metaParents;
		}
		
		public function analyzeMetadata(object:*):void{
			var myClass:Class =      Object(object).constructor;
			var xDesc:XML =        describeType(myClass);
			var myClassName:String =  xDesc.@name;
			var xMetas:XMLList =    xDesc.factory..metadata;
			
			//Filter the Metadata Tags belonging to this Class only:
			var xMetaParent:XML;
			var metaParents:Array =  [];
			for each(var xMeta:XML in xMetas) {
				xMetaParent =  xMeta.parent();
				if (xMeta.@name.indexOf("__go_to") > -1) {
					delete xMetaParent.children()[xMeta.childIndex()];
					continue;
				}
				
				if (xMetaParent.name() == "factory") {
					metaParents.push(xMeta);
					continue;
				}
				
				var declaredBy:String =  xMetaParent.attribute("declaredBy");
				if (declaredBy && declaredBy != myClassName) {
					continue;
				}
				
				metaParents.push( xMetaParent );
			}
			
			trace(metaParents.join("\n"));
		}
		
		[MemberMetaExampleMethod]
		public function myMethod():void {
			
		}
		
		[MemberMetaExampleGetter]
		public function get myAccessor():Boolean {
			return _myPrivateVar;
		}
		
		public function set myAccessor(value:Boolean):void {
			_myPrivateVar =  value;
		}
	}
}