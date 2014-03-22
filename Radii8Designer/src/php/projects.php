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
		
		if ( !is_user_logged_in() ) {
			$status = "publish";
		}
	    
	    if (!$author) {
	    //  $json_api->error("Not found.");
	    }
	    
		// Make sure we have required params
		if (!$json_api->query->author_id || !$json_api->query->category) {
		//	$json_api->error("Include a 'author' and 'category' query var.");
		}
	  
	    $posts = $json_api->introspector->get_posts(array(
	      'author' => $user_ID,
	      'category_name' => $category->slug,
	      'post_status' => $status
	    ));
	    
	    //return "test";
	    return $this->posts_object_result($posts, $wp_query->query);
    }
    
	public function get_author_posts() {
		global $json_api;
		$author = $json_api->introspector->get_current_author();
	    
	    if (!$author) {
	      $json_api->error("Not found.");
	    }
	    
	    $posts = $json_api->introspector->get_posts(array(
	      'author' => $author->id
	    ));
	    
	    return $this->posts_object_result($posts, $author);
	}
  
  
	public function get_categories($args = null) {
	  global $json_api;
	  $wp_categories = $json_api->introspector->get_categories($args);
		
	  //$categories = array();
	  
	  //foreach ($wp_categories as $wp_category) {
	  //  if ($wp_category->term_id == 1 && $wp_category->slug == 'uncategorized') {
	  //    continue;
	  //  }
	  //  $categories[] = $this->get_category_object($wp_category);
	  //}
	  
	  $output = array();
	  $output['attachments'] = $json_api->introspector->get_categories($args);
	  return $output;
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
      'pages' => $wp_query->max_num_pages,
      'posts' => $posts
    );
  }
}

?>