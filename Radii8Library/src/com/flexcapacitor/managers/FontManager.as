package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.utils.FontUtils;

	public class FontManager {
		
		public function FontManager() {
			
		}
		
		/**
		 * Get an array of fonts. Refactor to apply to projects and documents. 
		 * */
		public static function createFontsList():void {
			Radiate.fontsArray = FontUtils.getFontInformationDetails(null);
		}
	}
}