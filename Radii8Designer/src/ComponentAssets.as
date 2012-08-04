
package {
	import spark.components.BorderContainer;
	import spark.components.Button;
	
	/**
	 *  @private
	 *  This class is used to link additional classes into spark.swc
	 *  beyond those that are found by dependecy analysis starting
	 *  from the classes specified in manifest.xml.
	 *  For example, Button does not have a reference to ButtonSkin,
	 *  but ButtonSkin needs to be in framework.swc along with Button.
	 */
	public class ComponentAssets {
		
		public function ComponentAssets()
		{
		}
		
		import SparkClasses;SparkClasses;
	}
}