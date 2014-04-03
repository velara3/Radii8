<?php
/*
Controller name: Attachments
Controller description: Basic introspection methods for fetching attachments
*/

class JSON_API_Attachments_Controller {

    public function delete_attachment() {
        global $json_api;
        
        
        if ( !current_user_can( 'upload_files' ) && !current_user_can('delete_posts') ) {
        	$json_api->error("You do not have permission to delete files.");
        }
        //$json_api->error("Test 1 You do not have permission to delete files.");
        //return null;
        $nonce_id = $json_api->get_nonce_id('attachments', 'update_attachment');
        
        if (!wp_verify_nonce($json_api->query->nonce, $nonce_id)) {
        	//$json_api->error("Your 'nonce' value was incorrect. Use the 'get_nonce' API method.");
        }
        $id = $json_api->query->id !== null;
        
        if ($json_api->query->id !== null) {
        	$id = (integer) $json_api->query->id;
        }
        else {
        	$json_api->error("Include 'id' or 'slug' var in your request.");
        }
        
        $force_delete = true;
        if ($json_api->query->force_delete !== null) {
			$force_delete = (bool) $json_api->query->force_delete;
        }
        
        $result = wp_delete_attachment( $id, $force_delete );
        
    	if ( $result ) {
    		$successful = true;
    	}
    	else {
    		$successful = false;
    	}
    	
    	$result = array(
    			'post' => $result,
    			'deleted' => (bool) $successful
    	);
    	
    	return $result;
    }

    public function get_attachments() {
        global $json_api;
        global $user_ID;
    	
        // todo
        // support attachments by user
        // support attachments by post (this is supported)
        // support returning no attachments if user is not logged in
        // support returning all attachments for parent and it's descendents
		if (is_user_logged_in()) {
			$loggedIn = (bool) true;
		}
		else {
			$loggedIn = (bool) false;
		}
		
		if ($loggedIn) {
        	$user = get_userdata($user_ID);
		}

        if ($json_api->query->parent !== "null") {
            $parent = (integer) $json_api->query->parent;
        }
        else {
            $parent = null;
        }

        // we should check if the file the attachments are part of are published or not
	    $attachments = $json_api->introspector->get_attachments($parent);
	    
	    $output = array(
	    	'count' => count($attachments),
	    	'attachments' => $attachments
	    	);
	    
        return $output;
    }
}

?>