Radii8
======

An online design, develop and debug tool for creating graphic designs and building applications. 
It uses the Flex SDK as underlying framework (for both the IDE and when publishing an application).
It may in the future it may publish to other technologies such as HTML and JS. 

Home page:
 - About - http://www.radii8.com/blog/?page_id=2. 
 - Blog  - http://www.radii8.com/
 - Demo  - http://www.radii8.com/demo 
   - click New Project to see an empty new project (give it a minute to load)
   - click Inspect demo project to load an existing remote application called "AboutYou" (aboutyou.swf).
 
 Notes:
 - very early prototype. earlier than alpha. this means 
  - you will cry when you see the code
  - no application framework 
  - contains dead code
  - contains code that is not commented (a lot is)
 - you can create a plugin based on what exists now (see the components in the views package) 

 What needs to be done:
 - conforming this document to https://github.com/infochimps-labs/style_guide/blob/master/style-guide-for-readme-files.md
 - conforming to Git project file and folders structure https://github.com/infochimps-labs/style_guide/blob/master/style-guide-for-repo-organization.md 
 - documentation on getting started
 - needs an application framework
 - needs full plugin API defined. for example for plugins we need things like:
   - getCurrentDocument(), getSelectedItem(), setProperty, getProperty etc
   - currently there are some methods available like 
     - radiate.setProperty(target:Object, property:String, value:*, description:String = null, keepUndefinedValues:Boolean = false);
 - needs many more things
 - see http://www.radii8.com/blog/?page_id=2
 
 Roadmap:
 http://www.radii8.com/blog/?page_id=2
 
 