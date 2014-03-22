	<!-- 5,483 lines of code-->
	<!-- radiate library 8103 
	654
	252
	53,549
	
	
			   preloader="com.flexcapacitor.preloader.SparkPreloader"
	-
	During beta, the Digg RSS reader is free. In a survey Digg published last month on its blog,
	however, the company found that over 40 percent of respondents are 
	"willing to pay for a Google Reader replacement." The company noted alongside the finding 
	that, "Free products on the Internet don't have a great track record. They tend to disappear, 
	leaving users in a lurch. We need to build a product that people can rely on and trust will
	always be there for them. We're not sure how pricing might work, but we do know that we'd 
	like our users to be our customers, not our product.
	
	
	Readings for new developers
	Thoughts on html design and development process and export
	http://24ways.org/2009/make-your-mockup-in-markup/
	http://www.sitepoint.com/forums/showthread.php?869812-Exactly-How-To-make-pixel-perfect-HTML-CSS-from-PNG-PSD
	http://elliotnash.me/why-designers-are-talking-about-the-wrong-thing?utm_source=buffer&utm_campaign=Buffer&utm_content=buffer970d2&utm_medium=twitter
	http://lifehacker.com/5974605/learn-beginner-and-advanced-htmlcss-skills-for-free
	http://learn.shayhowe.com/html-css/box-model
	http://bradfrostweb.com/blog/post/development-is-design/?utm_source=buffer&utm_campaign=Buffer&utm_content=buffer27075&utm_medium=twitter
	http://dizyne.net/40-best-html5-development-tools-save-time/
	
	Design workflows
	http://www.vanseodesign.com/blog/page/8/
	
	Image uploader fix for wordpress (in .htaccess in wp-admin folder):
	http://xperiments.es/blog/en/wordpress-flash-uploader-http-error/
	
	#BEGIN Image Upload HTTP Error Fix - am not using this (Using wpattachment service)
	<IfModule mod_security.c>
	<Files async-upload.php>
	SecFilterEngine Off
	SecFilterScanPOST Off
	</Files>
	</IfModule>
	#END Image Upload HTTP Error Fix

	GOOGLE TEST PAGE IMPORT MXML
	
<s:Application xmlns:fx="http://ns.adobe.com/mxml/2009" xmlns:s="library://ns.adobe.com/flex/spark" >
	<s:BorderContainer x="0" height="30" percentWidth="100" y="0" borderVisible="false" color="#CCCCCC" backgroundColor="#000000">
		<s:HGroup x="10" gap="16" y="5" fontWeight="bold">
			<s:Label x="99" y="128" text="+you"/>
			<s:Label text="Search"/>
			<s:Label text="Images"/>
			<s:Label text="YouTube"/>
			<s:Label text="Maps"/>
			<s:Label text="etc"/>
		</s:HGroup>
	</s:BorderContainer>
	<s:Image height="95" horizontalCenter="0" y="200" source="https://www.google.com/images/srpr/logo4w.png" width="269"/>
	<s:HGroup horizontalCenter="0" x="500" y="380">
		<s:Button label="Google Search" x="340" y="2"/>
		<s:Button label="I'm Feeling Lucky" x="418" y="327"/>
	</s:HGroup>
	<s:TextInput horizontalCenter="0" x="292" percentWidth="50" y="330"/>
	<s:Image x="1154" top="0" y="1" source=""/>
</s:Application>

	
	DESIGN VIEW FEATURE REQUIREMENTS
	
	The design view is the most important part of the application. 
	It must support the following features:
	
	• drag and drop - move
	• rotate 
	• resize - drag handles
	• drag into group, drag out of group
	• zoom in and zoom out, other functions work while zoomed in and out
	• drag item from off screen into screen
	• support scrollbars
	• select and work with components in the flex component tree (select tool)
	• select and work with graphic primitives (direct selection tool?)
	• support filters
	• remove listeners - so components don't react (button press doesn't change state, etc)
	• states
	• transitions
	• measurement rulers 
	• alignment tools
	• multiselection
	• rich editable text on double click of text component
	• overlay of image (for example iphone, ipad or layout grid or mock up image) 
	• snap to grid (while dragging)
	• snap to other elements (while dragging)
	• snap to rulers
	
	Runtime Design layers
	http://sourceforge.net/adobe/flexsdk/wiki/Runtime%20Design%20Layers/
	
	
	Putting CSS in the head of the HTML page
	https://medium.com/coding-design/24888fbbd2e2
	
	ICONS and IMAGES
	
	These need to be checked to see if any are copyrighted and replaced if need be before going live
	
	http://www.arungudelli.com/free/best-free-social-media-icons/ 
	
	
	PEOPLE LOOKING FOR TUTORIALS
	https://plus.google.com/103431617731538429495/posts/XeR8PAgqaeQ
	https://plus.google.com/101488159983725354983/posts/Dxh5kQi4cjG
	
	http://www.floreysoft.com/en/products.html
	
	Other Reasons for doing this project
	http://www.businessinsider.com/syndromes-drive-coders-crazy-2014-3
	http://startingdotneprogramming.blogspot.com/2013/04/i-knew-programmer-that-went-completely.html
	
	Flash Plugins
		Adobe Flash Extension (Plugins) for Character Animation

		Flash Power Tools Animation
		http://flash-powertools.com/
		
		TrickOrScript
		http://www.trickorscript.com/tricksandscripts.html
		
		CloudKid Tools
		http://cloudkid.com/tools
		
		Ajar Productions
		http://ajarproductions.com/blog/category/extensions/
		
		Dave Logan's Extensions
		http://www.animatordavelogan.com/extensions/
		
		ToonMonkey Extensions
		http://www.toonmonkey.com/extensions.html
	-->