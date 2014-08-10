Radii8
======

An online and desktop design, develop and debug tool for creating graphic designs, websites, prototypes and applications. The online version connects to Wordpress and Wordpress MU for storage and retrieval. It can be adapted to create themes easily (maybe 1-3 weeks of work). The desktop version should eventually reference local files and projects. 

It uses the Flex SDK as underlying framework (for both the IDE and when publishing an application). It can generate MXML, HTML and Android XML. It may in the future publish to other languages. 

Home page:
 - About - http://www.radii8.com/blog/?page_id=2. 
 - Blog  - http://www.radii8.com/
 - Demo  - http://www.radii8.com/demo 
   - click New Project to see an empty new project (give it a minute to load)
 
Notes:
 - it is a prototype
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
 - see http://www.radii8.com/blog/?page_id=2
 
Roadmap:
 - http://www.radii8.com/blog/?page_id=2


This release is Apache 2.0 license.
