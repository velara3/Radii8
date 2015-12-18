package com.flexcapacitor.model
{
	
	/**
	 * Used to store properties, styles and values from XML nodes during import
	 * */
	public class ValuesObject {
		
		/**
		 * List of properties 
		 * */
		public var properties:Array = [];
		
		/**
		 * List of styles 
		 * */
		public var styles:Array = [];
		
		/**
		 * Object containing values of styles and properties
		 * */
		public var values:Object = {};
		
		/**
		 * Array of attributes on the XML node
		 * */
		public var attributes:Array;
		
		/**
		 * Array of child node names on the XML node.
		 * For example, dataProvider would be a child node name: 
<pre>
&lt;s:ComboBox id="listOfThings">
   &lt;s:dataProvider>1,2,3&lt;/s:dataProvider>
&lt;/s:ComboBox>
</pre>
		 * */
		public var childNodeNames:Array;
		
		/**
		 * Array of child node names on the XML node.
		 * For example, "dataProvider" and "1,2,3" would be a child node name and child node value: 
<pre>
&lt;s:ComboBox id="listOfThings">
    &lt;s:dataProvider>1,2,3&lt;/s:dataProvider>
&lt;/s:ComboBox>
</pre>
		 * */
		public var childNodeValues:Object;
		
		/**
		 * An object containing all the styles whose values could not be casted into an acceptable type
		 * on the target object and the error as it's value.
		 * */
		public var stylesErrorsObject:Object;
		
		/**
		 * An object containing all the properties whose values could not be casted into an acceptable type
		 * on the target object and the error as it's value.
		 * */
		public var propertiesErrorsObject:Object;
	}
}