package com.flexcapacitor.utils {
	
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.conversion.TextFieldHtmlExporter;
	import flashx.textLayout.formats.ITextLayoutFormat;
	
	use namespace tlf_internal;
	
	public class TextFieldHTMLExporter2 extends TextFieldHtmlExporter {
		
		
		public function TextFieldHTMLExporter2() {
			
		}
		
		
		/**  
		 * Exports certain character level formats as a <FONT/> with appropriate attributes
		 * @param format format to export
		 * @param ifDifferentFromFormat if non-null, a value in format is exported only if it differs from the corresponding value in ifDifferentFromFormat
		 * @return XML	the populated XML element
		 * @private
		 */	
		override tlf_internal function exportFont(format:ITextLayoutFormat, ifDifferentFromFormat:ITextLayoutFormat=null):XML
		{
			var font:XML = super.exportFont(format, ifDifferentFromFormat);
			
			
			if (!ifDifferentFromFormat || ifDifferentFromFormat.fontSize != format.fontSize) {
				font = super.exportFontAttribute(font, "SIZE", format.fontSize);
				delete font.@SIZE;
				
				font.@style = "font-size:" + format.fontSize + "px";
			}
			
			return font;
		}
	}
}