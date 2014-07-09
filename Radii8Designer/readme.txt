				   
    THOUGHTS ON SUSTAINABILITY

	Quote from Digg, 
	"During beta, the Digg RSS reader is free. In a survey Digg published last month on its blog,
	however, the company found that over 40 percent of respondents are 
	"willing to pay for a Google Reader replacement." The company noted alongside the finding 
	that, "Free products on the Internet don't have a great track record. They tend to disappear, 
	leaving users in a lurch. We need to build a product that people can rely on and trust will
	always be there for them. We're not sure how pricing might work, but we do know that we'd 
	like our users to be our customers, not our product."
	
	
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
	• background image (used to compare design spec as you work - onion skin)
	
	ADDITIONAL FEATURE REQUIREMENTS
	• Templates - users can use their own MXML, HTML, PHP, etc templates and indicate locations for CSS, script includes, code blocks and layout 
	• Desktop environment - users can run on the desktop
	• Compiler integration - users can compile using the mxmlc or Falcon
	• Flex project support - users can connect to their Flex projects
	• Wordpress integration - users can create their own theme. tokens can be used to repeat sections and get values. results are assembled on the server by a theme assembler
	• Editors - users can create or edit text documents. using Ace editor or Moonshine to syntax highlight
	• Append CSS - users can append CSS to add to element CSS block and override the generated CSS
	• Includes - a view exists of external scripts to include (for CSS, JavaScript, MXML script)
	• Declarations - a view showing declared objects
	• Publishing - users can publish to their server (using Wordpress) or add in FTP for desktop version
	• ActionEffects - users can assemble actions based on ActionEffects and create different action paths
	• AST - a syntax tree can be created for code completion, documentation and error handling
	• Compiler integration - compiler can provide a problems panel (desktop only?)
	• Import and Export plugins - new or improved import and export plugins can be added to the environment for better input and output
	• Plugins - new and improved plugins can be added to the environment to add new or better feature sets
	• Tools - new and improved tools can be added to the environment to add new or better feature sets
	• Commands -  can be added to the environment to add missing or necessary functionality
	• Document types - new document types can be added for additional functionality. text, vector graphics editor
	• State inheritance - users should be able to create states based on other states (this exists in Flex via basedOn property) this can be used for design templates exporting pages based on state
	• Multi language support - users should be able to add and integrate server side code in the output. for example add PHP that wraps around an element or section of code  
	• Different work flows for output results - one is to generate code (one way), the other is create an AST from code (round trip), another is a mix of both including search and replace tokens and generated code in templates 
	• Examples - starting points and examples should be included for partial and even full example sites and apps
	• Previews - users should be able to preview in HTML or application (possibly in another browser or FP instance)
	• Import of PSD, AI files - users should be able to import PSD or AI. AS3 importers exist
	• CSS view - show styles applied to component and inherited from containers
	• Vector graphics editor - users should be able to create and edit vector graphics and use as skins
	• Animation timeline - users should be able to animate and trigger effects on elements (see ActionEffects)
	• Export options - panel for setting export options. for example, when converting to HTML, convert text element to an image option 
	
	Document Classes
	The document classes were made to support saving to local shared objects and remote save and retrieve to Wordpress were tacked on later.
	Documents don't yet support the file system for read and write. They need to support data coming from anywhere
	(dynamic instance, local shared object, file system, Wordpress API, database, etc). 
	There is always a question if undo and redo, save, load and open should be in the Document or the Radiate class. 
	I can't settle on one or the other but I'm leaning towards Document to have all the code and Radiate be a 
	wrapper that calls methods on the document class. They could be refactored. 
	
	Runtime Design layers
	http://sourceforge.net/adobe/flexsdk/wiki/Runtime%20Design%20Layers/
	
	
	Putting CSS in the head of the HTML page
	https://medium.com/coding-design/24888fbbd2e2
	
	ICONS and IMAGES
	
	This projects uses common icons from Eclipse, the Apache Flex SDK and default OS but may not be royalty free. 
	We need to check to see if any are copyrighted and replaced if need be before going live
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

	
	JS BASE 64 Encode / Decode
	http://jsbase64.codeplex.com/


	APPLICATION TYPES
	
	There are three main types of loaded sub-applications in Flex:
	
	Single-versioned applications
	are guaranteed to have been compiled with the same version of the compiler as the main application. They have the greatest level of interoperability with the main application, but they also require that you have complete control over the source of the sub-applications. 
	
	Multi-versioned applications
	can be compiled with older versions of the Flex framework than the main application that loads them. Their interoperability with the main application and other sub-applications is more limited than single-versioned applications.
	
	Sandboxed applications
	are loaded into their own security domains, and can be multi-versioned. Using sandboxed applications is the recommended practice for loading third-party applications. In addition, if your sub-applications use RPC or DataServices-related functionality, you should load them as sandboxed. 
	
	When compiling each of these types of applications, you should include the MarshallingSupport class into the main application and sub-applications. You do this with the includes compiler argument, as the following example shows:
	
	-includes=mx.managers.systemClasses.MarshallingSupport
	
	We use an application as a design canvas for a few reasons. 
	
	1. To import a remote application and allow editing
	2. To sandbox styles with the style manager
	3. To sandbox the application importing components at runtime from the development environment   
	
	
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

	TEST COMPONENT BOUNDS
	
<s:Application xmlns:fx="http://ns.adobe.com/mxml/2009" xmlns:s="library://ns.adobe.com/flex/spark">	<s:BorderContainer x="205" y="324"/>	<s:HGroup x="299" y="105">		<s:Spacer/>	</s:HGroup>	<s:LinkButton x="522" y="166"/>	<s:RichText x="628" y="166"/>	<s:TextArea x="470" y="326"/>	<s:Button x="622" y="255"/>	<s:CheckBox x="218" y="166"/>	<s:Label x="11" y="19" text="TEST COMPONENT BOUNDS" fontSize="25"/>	<s:Image x="561" y="255"/>	<s:Label x="471" y="405" text="DataGrid"/>	<s:Label x="560" y="237" text="Image"/>	<s:RadioButton x="436" y="255"/>	<s:Label x="739" y="150" text="VSlider"/>	<s:ComboBox dataProvider="Item 1,Item 2,Item 3" x="22" y="166"/>	<s:Label x="469" y="312" text="Text Area"/>	<s:HSlider x="324" y="166"/>	<s:Label x="622" y="237" text="Button"/>	<s:Label x="206" y="312" text="Border Container"/>	<s:VSlider x="749" y="167"/>	<s:List dataProvider="Item 1,Item 2,Item 3" x="22" y="326"/>	<s:Label x="22" y="310" text="List"/>	<s:Label x="254" y="237" text="Drop Down List"/>	<s:Label x="438" y="237" text="Radio Button"/>	<s:Label x="531" y="150" text="Link"/>	<s:ToggleButton x="164" y="255"/>	<s:Label x="324" y="150" text="HSlider"/>	<s:Label x="23" y="150" text="ComboBox"/>	<s:DropDownList dataProvider="Item 1,Item 2,Item 3" x="253" y="255"/>	<s:Label x="218" y="150" text="Checkbox"/>	<s:Label x="164" y="237" text="Toggle"/>	<s:Label x="22" y="237" text="Text Input"/>	<s:DataGrid x="469" y="418"/>	<s:TextInput x="22" y="255"/>	<s:Label x="627" y="150" text="Rich Text"/></s:Application>
