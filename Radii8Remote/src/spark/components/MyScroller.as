

package components
{
    import flash.events.FocusEvent;
    
    import mx.managers.FocusManager;
    
    import spark.components.Scroller;
	
	/**
	 * Gets rid of focusmanager scroller bug
	 * https://bugs.adobe.com/jira/browse/SDK-29522
	 * */
    public class MyScroller extends MyScroller
    {
        public function MyScroller()
        {
            super();
        }

        override protected function focusInHandler(event:FocusEvent):void
        {
            if(FocusManager != null) {
                super.focusInHandler(event);
            }
        }
    }
}
