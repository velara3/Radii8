
package com.flexcapacitor.model {
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	
	/**
	 * Describes how project data is displayed in a tree
	 * */
	public class ProjectDataDescriptor extends DefaultDataDescriptor {
		
		
		public function ProjectDataDescriptor() {
			super();
		}
		
		/**
		 * Get documents for now
		 * */
		override public function getChildren(node:Object, model:Object = null):ICollectionView {
			if ("documents" in node) {
				return node.documents;
			}
			
			return null;
		}
		
	
	    /**
	     *  Tests a node for termination.
	     *  Branches are non-terminating but are not required to have any leaf nodes.
	     *  If the node is XML, returns <code>true</code> if the node has children
	     *  or a <code>true isBranch</code> attribute.
	     *  If the node is an object, returns <code>true</code> if the node has a
	     *  (possibly empty) <code>children</code> field.
	     *
	     *  @param node The node object currently being evaluated.
	     *  @param model The collection that contains the node; ignored by this class.
	     *  
	     *  @return <code>true</code> if this node is non-terminating.
	     *  
	     *  @langversion 3.0
	     *  @playerversion Flash 9
	     *  @playerversion AIR 1.1
	     *  @productversion Flex 3
	     */
	    override public function isBranch(node:Object, model:Object = null):Boolean
	    {
	        if (node == null)
	            return false;
	            
	        var branch:Boolean = false;
	            
	        if (node is XML)
	        {
	            var childList:XMLList = node.children();
	            //accessing non-required e4x attributes is quirky
	            //but we know we'll at least get an XMLList
	            var branchFlag:XMLList = node.@isBranch;
	            //check to see if a flag has been set
	            if (branchFlag.length() == 1)
	            {
	                //check flag and return (this flag overrides termination status)
	                if (branchFlag[0] == "true")
	                    branch = true;
	            }
	            //since no flags, we'll check to see if there are children
	            else if (childList.length() != 0)
	            {
	                branch = true;
	            }
	        }
	        else if (node is Object)
	        {
	            try
	            {
	                if (node.documents != undefined)
	                {
	                    branch = true;
	                }
	            }
	            catch(e:Error)
	            {
	            }
	        }
	        return branch;
	    }

	}
}