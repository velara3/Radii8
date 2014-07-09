<?php
/*
Controller name: Categories
Controller description: Methods for working with categories
*/
class JSON_API_Categories_Controller {
	
	
	public function save_option($id, $value) {
		$option_exists = (get_option($id, null) !== null);
	
		if ($option_exists) {
			update_option($id, $value);
		} else {
			add_option($id, $value);
		}
	}
	
	public function enable_controllers() {
		global $json_api;
		
		$available_controllers = $json_api->get_controllers();
		$active_controllers = explode(',', get_option('json_api_controllers', 'core'));
		$controllers = "core,categories,posts,user,attachments,projects";
		//$this->save_option('json_api_controllers', implode(',', $active_controllers));
		//$this->save_option('json_api_controllers', implode(',', 'core'));
		$action = "activate";
		//$action = "deactivate";
		
		foreach ($controllers as $controller) {
			if (in_array($controller, $available_controllers)) {
				if ($action == 'activate' && !in_array($controller, $active_controllers)) {
					$active_controllers[] = $controller;
				} else if ($action == 'deactivate') {
					$index = array_search($controller, $active_controllers);
					if ($index !== false) {
						unset($active_controllers[$index]);
					}
				}
			}
		}
		
		$id = 'json_api_test';
		$value = 'test value';
		$option_exists = (get_option($id, null) !== null);
		if ($option_exists) {
		//	update_option($id, $value);
		} else {
		//	add_option($id, $value);
		}
		//$this->save_option('json_api_controllers', implode(',', $active_controllers));
		
		return array(
				'available'=> $available_controllers,
				'active'=> $active_controllers,
				'core'=> get_option('json_api_test')
				);
		
	}
	
	/**
	 * Get list of categories. As it is, if the category is not used by any post
	 * it's not returned. 
	 */
	public function get_categories() {
		global $json_api;
		$fields = array();
		
		if ( isset( $_REQUEST['type'] ) ) {
			$fields['type'] = $_REQUEST['type'];
		}
		
		if ( isset( $_REQUEST['child_of '] ) ) {
			$fields['child_of '] = $_REQUEST['child_of '];
		}
		
		if ( isset( $_REQUEST['parent'] ) ) {
			$fields['parent'] = $_REQUEST['parent'];
		}
		
		if ( isset( $_REQUEST['orderby'] ) ) {
			$fields['orderby'] = $_REQUEST['orderby'];
		}
		
		if ( isset( $_REQUEST['order'] ) ) {
			$fields['order'] = $_REQUEST['order'];
		}
		
		if ( isset( $_REQUEST['hide_empty'] ) ) {
			$fields['hide_empty'] = $_REQUEST['hide_empty'];
		}
		
		if ( isset( $_REQUEST['hierarchical'] ) ) {
			$fields['hierarchical'] = $_REQUEST['hierarchical'];
		}
		
		if ( isset( $_REQUEST['exclude'] ) ) {
			$fields['exclude'] = $_REQUEST['exclude'];
		}
		
		if ( isset( $_REQUEST['include'] ) ) {
			$fields['include'] = $_REQUEST['include'];
		}
		
		if ( isset( $_REQUEST['number'] ) ) {
			$fields['number'] = $_REQUEST['number'];
		}
		
		if ( isset( $_REQUEST['taxonomy'] ) ) {
			$fields['taxonomy'] = $_REQUEST['taxonomy'];
		}
		
		if ( isset( $_REQUEST['pad_counts'] ) ) {
			$fields['pad_counts'] = $_REQUEST['pad_counts'];
		}
		
		//$categories = $json_api->introspector->get_categories($fields);
		$categories = get_categories($fields);
		
		$result = array(
				'count' => count($categories),
				'categories' => $categories
		);
			
		return $result;
	}
	
	/**
	 * Add category
	 */
	public function create_category() {
		global $json_api;
		
		$name = $json_api->query->name;
		$parent = intval($_GET['parent']);
		
		// Make sure we have the name
		if (!$name) {
			$json_api->error("The category name is required.");
		}
		
		$id = $this->get_category_exists($name, $parent);
		
		
		if ( $id ) {
			//return $id;
		}
		
		// Make sure the user is allowed to add a category.
		if ( !current_user_can('manage_categories') ) {
			$json_api->error('Sorry, you do not have the right to add a category.');
		}
		
		if (!function_exists('term_exists')) {
			return "function doesn't exists";
		}
		
		$exists = (bool) function_exists('term_exists');
		
		
		if (!$id) {
			try {
				//ob_start();
				$wp_category = $this->wp_create_category( $name, $parent );
				$wp_category = get_term_by('id', $wp_category, 'category');
				$wp_category = new JSON_API_Category($wp_category);
				//ob_end_clean();
				$created = true;
			} catch (Exception $e) {
				$json_api->error('Caught exception: ' . $e->getMessage());
			}
		}
		else {
			$wp_category = get_term_by('id', $id, 'category');
			$wp_category = new JSON_API_Category($wp_category);
			$created = false;
		}
		
		$result = array(
				'created' => $created,
				'status' => "ok",
				'category' => $wp_category
		);
		
		return $result;
	}
	
	/**
	 * Returns true if category exists
	 */
	public function category_exists() {
		global $json_api;

		$name = $json_api->query->name;
		$parent = 0;
		
		if ($json_api->query->parent) {
			$parent = $json_api->query->parent;
		}
		
		$exists = category_exists($name, $parent);

		$result = array(
				'id' => $category_ID,
				'exists' => exists
		);
		
		return $result;
	}
	
	public function get_category() {
		global $json_api;
		
		$name = $json_api->query->name;
		$parent = $json_api->query->parent;
		
		$id = term_exists($name, 'category', $parent);
		
		if ( is_array($id) ) {
			$id = $id['term_id'];
		}
		
		$wp_category = $json_api->introspector->get_category_by_id($id);
		
		$result = array(
				'category' => $wp_category,
		);
		
		return $result;
	}
	
	public function get_category_by_id($category_id) {
		$category_id = $json_api->query->category_id;
		
		return $json_api->introspector->get_category_by_id($category_id);
	}
	
	public function get_category_by_slug() {
		$category_slug = $json_api->query->category_slug;
		
		return $json_api->introspector->get_category_by_slug($category_slug);
	}
	
	public function get_tags() {
		return $json_api->introspector->get_tags();
	}
	
	public function get_tag_by_id() {
		$tag_id = $json_api->query->tag_id;
		
		return $json_api->introspector->get_tag_by_id($tag_id);
	}
	
	public function get_tag_by_slug() {
		$tag_slug = $json_api->query->tag_slug;
		
		return $json_api->introspector->get_tag_by_slug($tag_slug);
	}
	
	/**
	 * {@internal Missing Short Description}}
	 *
	 * @since 2.0.0
	 *
	 * @param unknown_type $cat_name
	 * @param unknown_type $parent
	 * @return unknown
	 */
	protected function wp_create_category( $cat_name, $parent = 0 ) {
		if ( $id = $this->get_category_exists($cat_name, $parent) )
			return $id;
	
		return $this->wp_insert_category( array('cat_name' => $cat_name, 'category_parent' => $parent) );
	}
	
	/**
	 * {@internal Missing Short Description}}
	 *
	 * @since 2.0.0
	 *
	 * @param unknown_type $cat_name
	 * @return unknown
	 */
	protected function get_category_exists($cat_name, $parent = 0) {
		$id = term_exists($cat_name, 'category', $parent);
		if ( is_array($id) )
			$id = $id['term_id'];
		return $id;
	}
	
	/**
	 * Updates an existing Category or creates a new Category.
	 *
	 * @since 2.0.0
	 *
	 * @param mixed $catarr See defaults below. Set 'cat_ID' to a non-zero value to update an existing category. The 'taxonomy' key was added in 3.0.0.
	 * @param bool $wp_error Optional, since 2.5.0. Set this to true if the caller handles WP_Error return values.
	 * @return int|object The ID number of the new or updated Category on success. Zero or a WP_Error on failure, depending on param $wp_error.
	 */
	protected function wp_insert_category($catarr, $wp_error = false) {
		$cat_defaults = array('cat_ID' => 0, 'taxonomy' => 'category', 'cat_name' => '', 'category_description' => '', 'category_nicename' => '', 'category_parent' => '');
		$catarr = wp_parse_args($catarr, $cat_defaults);
		extract($catarr, EXTR_SKIP);
	
		if ( trim( $cat_name ) == '' ) {
			if ( ! $wp_error )
				return 0;
			else
				return new WP_Error( 'cat_name', __('You did not enter a category name.') );
		}
	
		$cat_ID = (int) $cat_ID;
	
		// Are we updating or creating?
		if ( !empty ($cat_ID) )
			$update = true;
		else
			$update = false;
	
		$name = $cat_name;
		$description = $category_description;
		$slug = $category_nicename;
		$parent = $category_parent;
	
		$parent = (int) $parent;
		if ( $parent < 0 )
			$parent = 0;
	
		if ( empty( $parent ) || ! term_exists( $parent, $taxonomy ) || ( $cat_ID && term_is_ancestor_of( $cat_ID, $parent, $taxonomy ) ) )
			$parent = 0;
	
		$args = compact('name', 'slug', 'parent', 'description');
	
		if ( $update )
			$cat_ID = wp_update_term($cat_ID, $taxonomy, $args);
		else
			$cat_ID = wp_insert_term($cat_name, $taxonomy, $args);
	
		if ( is_wp_error($cat_ID) ) {
			if ( $wp_error )
				return $cat_ID;
			else
				return 0;
		}
	
		return $cat_ID['term_id'];
	}
}
?>