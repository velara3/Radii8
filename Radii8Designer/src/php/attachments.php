<?php
/*
Controller name: Attachments
Controller description: Basic introspection methods for fetching attachments
*/

class JSON_API_Attachments_Controller {

    public function get_attachments() {
        global $json_api;

        if($json_api->query->parent !== "null")
            $parent = (integer) $json_api->query->parent;
        else
            $parent = null;    

	    $attachments = $json_api->introspector->get_attachments($parent);
	    
	    $output = array(
	    	'count' => count($attachments),
	    	'attachments' => $attachments
	    	);
	    
        return $output;
    }
}

?>