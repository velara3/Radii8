<?php
/*
Controller name: Projects
Controller description: Methods for getting projects
*/
class JSON_API_Projects_Controller {

    public function get_projects() {
        global $json_api;
        global $user_ID;
        global $wp_query;
        
		//$author = $json_api->introspector->get_author_by_id($json_api->query->author_id);
		//$category = $json_api->introspector->get_category_by_slug($json_api->query->category);
		$category = $json_api->introspector->get_category_by_slug("project");
		$status = $json_api->query->status;
		
		// Make sure we have the category
		if (!$category) {
			$json_api->error("The project category does not exist.");
		}
		
		if ( !is_user_logged_in() ) {
			$status = "publish";
		}

		$query = array(
	      'category_name' => $category->slug,
	      'post_status' => $status
	    );
	    
	    // Make sure we have required params
	    if ($json_api->query->user_id) {
	    	//return "something";
			$query['author'] = $json_api->query->user_id;;
	    }
	    
		
	    $posts = $json_api->introspector->get_posts($query);
	    
	    //return "test";
	    //return $this->posts_object_result($posts, $wp_query->query); // returns the query we just sent
	    return $this->posts_result($posts);
    }
    
	public function get_projects_by_user() {
		global $json_api;
		
		
        $user_id = $json_api->query->user_id;
        $user = get_userdata($user_id);
		$category = $json_api->introspector->get_category_by_slug("project");
		$status = $json_api->query->status;
		
		// Make sure we have the category
		if (!$category) {
			$json_api->error("The project category does not exist.");
		}
		
		if ( !is_user_logged_in() ) {
			$status = "publish";
		}
	    
	    $query = array(
	    	'category_name' => $category->slug,
	    	'post_status' => $status
	    );
	    
	    if (!$user) {
	    	$json_api->error("User with that ID not found.");
	    }
	    else {
	    	$query['author'] = $user_id;
	    }
	    
		//return $query;
	    $posts = $json_api->introspector->get_posts($query);
	    
	    return $this->posts_result($posts);
	}
  
  
	// Retrieve posts based on custom field key/value pair
	public function get_custom_posts() {
	  global $json_api;
	
	  // Make sure we have key/value query vars
	  if (!$json_api->query->key || !$json_api->query->value) {
	    $json_api->error("Include a 'key' and 'value' query var.");
	  }
	
	  // See also: http://codex.wordpress.org/Template_Tags/query_posts
	  $posts = $json_api->introspector->get_posts(array(
	    'meta_key' => $json_api->query->key,
	    'meta_value' => $json_api->query->value
	  ));
	
	  return array(
	    'key' => $key,
	    'value' => $value,
	    'posts' => $posts
	  );
	}
	
  protected function posts_object_result($posts, $object) {
    global $wp_query;
    
    // Convert something like "JSON_API_Category" into "category"
    $object_key = strtolower(substr(get_class($object), 9));
    
    return array(
      'count' => count($posts),
      'count_total' => (int) $wp_query->found_posts,
      'pages' => (int) $wp_query->max_num_pages,
      $object_key => $object,
      'posts' => $posts
    );
  }
  
  protected function posts_result($posts) {
    global $wp_query;
    
    return array(
      'count' => count($posts),
      'count_total' => (int) $wp_query->found_posts,
      'pages' => (int) $wp_query->max_num_pages,
      'posts' => $posts
    );
  }
}

?>