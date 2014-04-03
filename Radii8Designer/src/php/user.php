<?php
/*
Controller name: User
Controller description: Adds an API for user and site management. 

You can change the contact name and email that is sent to users 
by setting global variables in wp_config.php. 

For example, 
define('JSON_API_EMAIL_FROM', "contact@mysite.com");
define('JSON_API_EMAIL_FROM_NAME', "My Site Contact");
*/

add_filter('wp_mail_from', 'new_mail_from');
add_filter('wp_mail_from_name', 'new_mail_from_name');

function new_mail_from($old) {
	// define these values in wp_config.php
	if (defined('JSON_API_EMAIL_FROM')) {
		$email = JSON_API_EMAIL_FROM;
	} else {
		$email = $old;
	}
	return $email;
}

function new_mail_from_name($old) {
	if (defined('JSON_API_EMAIL_FROM_NAME')) {
		$from = JSON_API_EMAIL_FROM_NAME;
	} else {
		$from = $old;
	}
	return $from;
}


class JSON_API_User_Controller {

	/**
	 * Checks if user is logged in. Just calls get_logged_in_user(). 
	 */
	public function is_user_logged_in() {
		$result = $this->get_logged_in_user();
		
		return $result;
	}
	
	/**
	 * Get the user that is logged in
	 */
	public function get_logged_in_user() {
		global $user_ID;
		
		if (is_user_logged_in()) { // this refers to the global method not local
			$loggedIn = (bool) true;
		}
		else {
			$loggedIn = (bool) false;
		}
		
		$avatarURL = get_avatar($user_ID);
		$user = get_userdata($user_ID);
		$dom = new DOMDocument();
		$dom->loadHTML($avatarURL);
		$avatarURL = $dom->getElementsByTagName('img')->item(0)->getAttribute('src');
		
		$result = array(
			'id' => $user_ID,
			'displayName' => "",
			'loggedIn' => $loggedIn,
			'avatar' => $avatarURL
		);
		
		if ($user) {
			$result['displayName'] = $user->data->display_name;
			$result['contact'] = $user->data->user_email;
		}
		
		if (is_multisite()) {
			$user_blogs = get_blogs_of_user( $user_ID );
			$result['blogs'] = $user_blogs;
		}
		
		return $result;
	}
	
	/**
	 * Logout user.
	 */
	public function logout() {
	
		wp_logout();
		wp_set_current_user(0); // force immediate logout
		
		// would like to clear all cookies - wp_logout() may do this
		//$reauth = empty($_REQUEST['reauth']) ? false : true;
		
		// Clear any stale cookies.
		//if ( $reauth ) {
		//	wp_clear_auth_cookie();
		//}
		
		$results = $this->get_logged_in_user();
		
		return $results;
	}
	
	/**
	 * Login user. SSL support is not tested. 
	 */
	public function login() {
		global $json_api;
		
		$secure_cookie = '';
	
		// If the user wants ssl but the session is not ssl, force a secure cookie.
		if ( !empty($_POST['log']) && !force_ssl_admin() ) {
			$user_name = sanitize_user($_POST['log']);
			if ( $user = get_user_by('login', $user_name) ) {
				
				// i'm guessing the user can change their login options to work with SSL
				if ( get_user_option('use_ssl', $user->ID) ) {
					$secure_cookie = true;
					
					//passing true to like so, force_ssl_admin(true), makes force_ssl_admin() return true and vice versa
					//force_ssl_admin(true); http://codex.wordpress.org/Function_Reference/force_ssl_admin
					
					// we are declaring error but not returning it for now
					$errors = new WP_Error();
					$errors->add('use_ssl', __("The login must use ssl."));
					
					// not implemeted now
					//return $errors;
				}
				
			}
		}
		
		if ( isset( $_REQUEST['redirect_to'] ) ) {
			$redirect_to = $_REQUEST['redirect_to'];
			// Redirect to https if user wants ssl
			if ( $secure_cookie && false !== strpos($redirect_to, 'wp-admin') ) {
				$redirect_to = preg_replace('|^http://|', 'https://', $redirect_to);
			}
		} else {
			$redirect_to = admin_url();
		}
		
	
		$reauth = empty($_REQUEST['reauth']) ? false : true;
	
		
		// If the user was redirected to a secure login form from a non-secure admin page, and secure login is required but secure admin is not, then don't use a secure
		// cookie and redirect back to the referring non-secure admin page.  This allows logins to always be POSTed over SSL while allowing the user to choose visiting
		// the admin via http or https.
		if ( !$secure_cookie && is_ssl() && force_ssl_login() && !force_ssl_admin() && ( 0 !== strpos($redirect_to, 'https') ) && ( 0 === strpos($redirect_to, 'http') ) ) {
			$secure_cookie = false;
		}
		
		
		//$user = wp_authenticate_username_password('', $_POST['log'], $_POST['pwd']);
		$user = wp_signon('', $secure_cookie);
		
		if (is_wp_error($user)) {
		
			// user is an error object
			$errors = $user;
			
			// if both login and password are empty no error is added so we add one now
			if (empty($_POST['log']) && empty($_POST['pwd'])) {
				$errors->add('invalid_username', __("The username is empty."));
			}
			
			// Clear errors if loggedout is set.
			if ( !empty($_GET['loggedout']) || $reauth ) {
				$errors = new WP_Error();
			}
		
			// If cookies are disabled we can't log in even with a valid user+pass
			if ( isset($_POST['testcookie']) && empty($_COOKIE[TEST_COOKIE]) ) {
				$errors->add('test_cookie', __("Cookies are blocked or not supported by your browser. You must <a href='http://www.google.com/cookies.html'>enable cookies</a> to use WordPress."));
			}
		
			// Some parts of this script use the main login form to display a message
			if		( isset($_GET['loggedout']) && TRUE == $_GET['loggedout'] ) {
				$errors->add('loggedout', __('You are now logged out.'), 'message');
			}
			elseif	( isset($_GET['registration']) && 'disabled' == $_GET['registration'] ) {
				$errors->add('registerdisabled', __('User registration is currently not allowed.'));
			}
			elseif	( isset($_GET['checkemail']) && 'confirm' == $_GET['checkemail'] ) {
				$errors->add('confirm', __('Check your e-mail for the confirmation link.'), 'message');
			}
			elseif	( isset($_GET['checkemail']) && 'newpass' == $_GET['checkemail'] ) {
				$errors->add('newpass', __('Check your e-mail for your new password.'), 'message');
			}
			elseif	( isset($_GET['checkemail']) && 'registered' == $_GET['checkemail'] ) {
				$errors->add('registered', __('Registration complete. Please check your e-mail.'), 'message');
			}
			elseif	( $interim_login ) {
				$errors->add('expired', __('Your session has expired. Please log-in again.'), 'message'); 
			}
		
			// Clear any stale cookies.
			if ( $reauth ) {
				wp_clear_auth_cookie();
			}
			
			return $errors;
		}
	
		//if (!$reauth) {
	
			// does not redirect
			if ( ( empty( $redirect_to ) || $redirect_to == 'wp-admin/' || $redirect_to == admin_url() ) ) {
				// If the user doesn't belong to a blog, send them to user admin. If the user can't edit posts, send them to their profile.
				if ( is_multisite() && !get_active_blog_for_user($user->ID) && !is_super_admin( $user->ID ) ) {
					$redirect_to = user_admin_url();
				}
				elseif ( is_multisite() && !$user->has_cap('read') ) {
					$redirect_to = get_dashboard_url( $user->ID );
				}
				elseif ( !$user->has_cap('edit_posts') ) {
					$redirect_to = admin_url('profile.php');
				}
			}
			
			
			wp_set_current_user( $user->ID );
			
			$user = $this->get_logged_in_user();
			
			// left in redirect_to since we could return the value later if we wanted
			
			return $user;
		//}
		
	}
	
	/**
	 * Retrieve lost password for user. 
	 */
	public function lost_password() {
		global $wpdb, $current_site;

		$errors = new WP_Error();

		if ( empty( $_POST['username'] ) ) {
			$errors->add('empty_username', __('Enter a username or e-mail address.'));
		}
		else if ( strpos( $_POST['username'], '@' ) ) {
			$user_data = get_user_by( 'email', trim( $_POST['username'] ) );
			
			if ( empty( $user_data ) ) {
				$errors->add('invalid_email', __('There is no user registered with that email address.'));
			}
		}
		else {
			$login = trim($_POST['username']);
			$user_data = get_user_by('login', $login);
		}

		do_action('lostpassword_post');

		if ( $errors->get_error_code() ) {
			return $errors;
		}

		if ( !$user_data ) {
			$errors->add('invalidcombo', __('Invalid username or e-mail.'));
			return $errors;
		}

		// redefining user_login ensures we return the right case in the email
		$user_login = $user_data->user_login;
		$user_email = $user_data->user_email;

		do_action('retreive_password', $user_login);  // Misspelled and deprecated
		do_action('retrieve_password', $user_login);

		$allow = apply_filters('allow_password_reset', true, $user_data->ID);

		if ( ! $allow ) {
			return new WP_Error('no_password_reset', __('Password reset is not allowed for this user'));
		}
		else if ( is_wp_error($allow) ) {
			return $allow;
		}

		$key = $wpdb->get_var($wpdb->prepare("SELECT user_activation_key FROM $wpdb->users WHERE user_login = %s", $user_login));
		
		if ( empty($key) ) {
			// Generate something random for a key...
			$key = wp_generate_password(20, false);
			do_action('retrieve_password_key', $user_login, $key);
			// Now insert the new md5 key into the db
			$wpdb->update($wpdb->users, array('user_activation_key' => $key), array('user_login' => $user_login));
		}
		
		$message = __('Someone requested that the password be reset for the following account:') . "\r\n\r\n";
		$message .= network_site_url() . "\r\n\r\n";
		//$message .= sprintf(__('Username: %s'), $user_login) . "\r\n";
		$message .= sprintf(__('Passkey: %s'), $key) . "\r\n\r\n";
		$message .= __('If this was a mistake, just ignore this email and nothing will happen.') . "\r\n\r\n";
		$message .= __('To reset your password, enter the passkey at the lost password screen.') . "\r\n\r\n";
		//$message .= __('Or visit the following address:') . "\r\n\r\n";
		//$message .= '<' . network_site_url("wp-login.php?action=rp&key=$key&login=" . rawurlencode($user_login), 'login') . ">\r\n";

		if ( is_multisite() ) {
			$blogname = $GLOBALS['current_site']->site_name;
		}
		else {
			// The blogname option is escaped with esc_html on the way into the database in sanitize_option
			// we want to reverse this for the plain text arena of emails.
			$blogname = wp_specialchars_decode(get_option('blogname'), ENT_QUOTES);	
		}
	
		$title = sprintf( __('[%s] Password Reset'), $blogname );

		$title = apply_filters('retrieve_password_title', $title);
		$message = apply_filters('retrieve_password_message', $message, $key);

		// email user
		if ( $message && !wp_mail($user_email, $title, $message) ) {
			$errors->add('email_not_sent', __('The e-mail could not be sent. Possible reason: your host may have disabled the mail() function.'));
		}
		
		$result = array(
			'message' => "A message was sent to the email address or user associated with that account.",
			'status' => "ok",
			'sent' => (bool) true
		);
		
		return $result;
	}
	
	/**
	 * Reset user password
	 */
	public function reset_password() {
		global $wpdb;
		
		$key = $_GET['key'];
		$login = $_GET['login'];
		$pass1 = $_POST['pass1'];
		
		//$user = check_password_reset_key($_GET['key'], $_GET['login']);
		// check_password_reset_key - start
		$key = preg_replace('/[^a-z0-9]/i', '', $key);

		if ( empty( $key ) || !is_string( $key ) ) {
			$errors = new WP_Error('invalid_key', __('Invalid key'));
			return $errors;
		}

		if ( empty($login) || !is_string($login) ) {
			$errors = new WP_Error('invalid_login', __('Invalid login'));
			return $errors;
		}

		if ( !isset($_POST['pass1']) || empty($_POST['pass1']) ) {
			$errors = new WP_Error('password_not_set', __('Password not set'));
			return $errors;
		}

		// was getting errors with external call so calling method here- should retry to use wp methods
		$user = $wpdb->get_row($wpdb->prepare("SELECT * FROM $wpdb->users WHERE user_activation_key = %s AND user_login = %s", $key, $login));

		if ( empty( $user ) ) {
			$errors = new WP_Error('invalid_key', __('Invalid key'));
			return $errors;
		}
		
		// check_password_reset_key - end
	
		if ( isset($_POST['pass1']) && $_POST['pass1'] != $_POST['pass2'] ) {
			$errors = new WP_Error('password_reset_mismatch', __('The passwords do not match.'));
			
			return $errors;
		}
		
		reset_password($user, $_POST['pass1']);
		
		$result = array(
			'status' => "ok",
			'reset' => (bool) true
		);
		
		return $result;
	}
	
	/**
	 * Registers a new user. Supports multisite.
	 */
	public function register() {
		
		if (!get_option('users_can_register')) {
			$error = new WP_Error();
			$error->add('users_cannot_register', __('Registration is not enabled for this site.'));
			return $error;
		}
		
		$user_name = $_POST['user_name'];
		$user_email = $_POST['user_email'];
		
		if ( empty($user_name) || empty($user_email) ) {
			$errors = new WP_Error();
				
			if (empty($user_name)) {
				$errors->add('username_required', __("A username is required."));
			}
				
			if (empty($user_email)) {
				$errors->add('email_required', __("A email is required."));
			}
	
			return $errors;
		}
		
		$result = wpmu_validate_user_signup($user_name, $user_email);
		extract($result);
		
		if ( $errors->get_error_code() ) {
			return $errors;
		}
		
		/** This filter is documented in wp-signup.php */
		$meta = apply_filters( 'add_signup_meta', array() );
		
		// this also sends out email 
		if (is_multisite()) {
			
			// Note: filters and admin options determine if an email is sent to the user
			// however, the user will still be signed up
			
			// this call was taking up to a minute
			// update- after more testing, a lot of calls were taking a while 
			// the problem fixed itself after a few minutes to half an hour
			$emailSent = wpmu_signup_user( $user_name, $user_email, $meta );
			$user = get_user_by('login', $user_name);
			$userId = $user ? $user->ID:-1; // seems to be null??
		}
		else {
			$userId = register_new_user($user_name, $user_email);
		}
		
		if (is_wp_error($result)) {
			return $result;
		}
		
		$result = array(
				'status'	=> 'ok',
				'user_name' => $user_name,
				'user_email'=> $user_email,
				'created'	=> (bool) true,
		);
		
		// multisite call returns -1 so not consistent
		// i'm guessing user must activate their account to get an id
		//if ($userId!=-1) {
		//	$result['id'] = $userId;
		//}
		
		return $result;
	}
	
	/************************
	 * Multisite Support
	 ***********************/
	
	
	/**
	 * Multisite uses code from wp-signup.php
	 */
	public function register_user_and_site() {
		
		if (!get_option('users_can_register')) {
			$error = new WP_Error();
			$error->add('users_cannot_register', __('Registration is not enabled for this site.'));
			 
			return $error;
		}
		
		// support for blog defaults not yet added 
		// may not be necessary or approapriate here
		// from wp-signup.php
		
// 		$signup_blog_defaults = array(
// 				'user_name'  => $user_name,
// 				'user_email' => $user_email,
// 				'blogname'   => $blogname,
// 				'blog_title' => $blog_title,
// 				'errors'     => $errors
// 		);
		
		/**
		 * Filter the default site creation variables for the site sign-up form.
		 *
		 * @since 3.0.0
		 *
		 * @param array $signup_blog_defaults {
		 *     An array of default site creation variables.
		 *
		 *     @type string $user_name  The user username.
		 *     @type string $user_email The user email address.
		 *     @type string $blogname   The blogname.
		 *     @type string $blog_title The title of the site.
		 *     @type array  $errors     An array of possible errors relevant to new site creation variables.
		 * }
		 */
// 		$filtered_results = apply_filters( 'signup_blog_init', $signup_blog_defaults );
		
// 		$user_name = $filtered_results['user_name'];
// 		$user_email = $filtered_results['user_email'];
// 		$blogname = $filtered_results['blogname'];
// 		$blog_title = $filtered_results['blog_title'];
// 		$errors = $filtered_results['errors'];
		
// 		if ( empty($blogname) ) {
// 			$blogname = $user_name;
// 		}

		// end blog defaults

		$newblogname = isset($_POST['blogname']) ? strtolower(preg_replace('/^-|-$|[^-a-zA-Z0-9]/', '', $_POST['blogname'])) : null;
		
		if ( is_array( get_site_option( 'illegal_names' )) && isset( $newblogname ) && in_array( $newblogname, get_site_option( 'illegal_names' ) ) == true ) {
			$error = new WP_Error();
			$error->add('illegal_name', __('This site name is not allowed.'));
			return $error;
		}
		
		if ( empty($_POST['user_name']) || empty($_POST['user_email']) ) {
			$errors = new WP_Error();
		
			if (empty($_POST['user_name'])) {
				$errors->add('username_required', __("A username is required."));
			}
		
			if (empty($_POST['user_email'])) {
				$errors->add('email_required', __("A email is required."));
			}
		
			return $errors;
		}
		
		// user should not be logged in when calling this method
		$result = wpmu_validate_user_signup($_POST['user_name'], $_POST['user_email']);
		extract($result);
	
		if ( $errors->get_error_code() ) {
			return $errors;
		}
			
		$user = '';
			
		if ( is_user_logged_in() ) {
			$user = wp_get_current_user();
		}
		
		$result = wpmu_validate_blog_signup($newblogname, $_POST['blog_title'], $user);
		extract($result);
		
		if ( $errors->get_error_code() ) {
			return $errors;
		}
		
		$public = (int) $_POST['blog_public'];
		$meta = array ('lang_id' => 1, 'public' => $public);
		
		/** This filter is documented in wp-signup.php */
		$meta = apply_filters( 'add_signup_meta', $meta );
		
		wpmu_signup_blog($domain, $path, $blog_title, $user_name, $user_email, $meta);
		
		$blog = get_blog_details(array('domain'=>$domain, 'path'=>$path));
		
		if ( $errors->get_error_code() ) {
			return $errors;
		}
		
		// creates message for user - not necessary
		$message = $this->confirm_blog_signup($domain, $path, $blog_title, $user_name, $user_email, $meta);
		
		$result = array(
				'message'	=>$message,
				'user_name' =>$user_name,
				'user_email'=>$user_email,
				'blogname'	=>$newblogname,
				'blog_title'=>$blog_title,
				'blog' 		=>$blog
		);
		
		$result = array(
				'created'	=> true,
				'site' 		=> $result
		);
		
		return $result;
		
	}
	
	/**
	 * New site signup message
	 *
	 * @since MU
	 *
	 * @param string $domain The domain URL
	 * @param string $path The site root path
	 * @param string $blog_title The new site title
	 * @param string $user_name The user's username
	 * @param string $user_email The user's email address
	 * @param array $meta Any additional meta from the 'add_signup_meta' filter in validate_blog_signup()
	 */
	function confirm_blog_signup( $domain, $path, $blog_title, $user_name = '', $user_email = '', $meta = array() ) {
		$site = "<a href='http://{$domain}{$path}'>{$blog_title}</a>";
		//$site = "<a href='http://{$domain}{$path}'>{$blog_title}</a>";
		$message = __( 'Congratulations! Your new site, '.$blog_title.', is almost ready.' );
		
		//$message .= _e( 'But, before you can start using your site, <strong>you must activate it</strong>.' );
		$message .= __( ' But, before you can start using your site, you must activate it.' );
		$message .= __( ' Check your inbox at '.$user_email.' and click the link given.' );
		$message .= __( ' If you do not activate your site within two days, you will have to sign up again.' );
		$message .= "\n";
		$message .= __( ' Still waiting for your email?' );
		$message .=  __( " If you haven't received your email yet, there are a number of things you can do:" );
		$message .=  __( ' Wait a little longer. Sometimes delivery of email can be delayed by processes outside of our control.' );
		$message .= __( ' Check the junk or spam folder of your email client. Sometime emails wind up there by mistake.' );
		//$message .= __( ' Have you entered your email correctly? You have entered '.$user_email.', if it&#8217;s incorrect, you will not receive your email.' );
		$message .= __( ' Have you entered your email correctly? You have entered '.$user_email.", if it's incorrect, you will not receive your email." );
		
		return $message;
	}

	
	/**
	 * Registers a new blog. User must be logged in to create a new site. 
	 *
	 * @since MU
	 *
	 * @uses wp_get_current_user() to retrieve the current user
	 * @uses wpmu_validate_blog_signup() to validate site availability
	 * @uses wpmu_create_blog() to add a new site
	 * @return bool Object containing site information or errors object if error
	 */
	function register_site() {
		global $wpdb, $blogname, $blog_title, $errors, $domain, $path;
		
		if ( !is_user_logged_in() ) {
			$error = new WP_Error();
			$error->add('user', __('You must be logged in to create a site.'));
			return $error;
		}
		
		if ( is_array( get_site_option( 'illegal_names' )) && isset( $_POST['blogname'] ) && in_array( $_POST['blogname'], get_site_option( 'illegal_names' ) ) == true ) {
			$error = new WP_Error();
			$error->add('illegal_name', __('This site name is not allowed.'));
			return $error;
		}
		
		$newblogname = isset($_POST['blogname']) ? strtolower(preg_replace('/^-|-$|[^-a-zA-Z0-9]/', '', $_POST['blogname'])) : null;
		
		$user = '';
		
		if ( is_user_logged_in() ) {
			$user = wp_get_current_user();
		}
		
		$result = wpmu_validate_blog_signup($newblogname, $_POST['blog_title'], $user);
		extract($result);
	
		if ( $errors->get_error_code() ) {
			return $errors;
		}
	
		$public = (int) $_POST['blog_public'];
	
		$blog_meta_defaults = array(
				'lang_id' => 1,
				'public'  => $public
		);
	
		/**
		 * Filter the new site meta variables.
		 *
		 * @since MU
		 * @deprecated 3.0.0 Use the 'add_signup_meta' filter instead.
		 *
		 * @param array $blog_meta_defaults An array of default blog meta variables.
		 */
		$meta = apply_filters( 'signup_create_blog_meta', $blog_meta_defaults );
		
		/**
		 * Filter the new default site meta variables.
		 *
		 * @since 3.0.0
		 *
		 * @param array $meta {
		 *     An array of default site meta variables.
		 *
		 *     @type int $lang_id     The language ID.
		 *     @type int $blog_public Whether search engines should be discouraged from indexing the site. 1 for true, 0 for false.
		 * }
		 */
		$meta = apply_filters( 'add_signup_meta', $meta );
	
		$result = wpmu_create_blog( $domain, $path, $blog_title, $current_user->ID, $meta, $wpdb->siteid );
		
		if ( $errors->get_error_code() ) {
			return $errors;
		}
		
		$result = array(
				'blogname'	=>$newblogname,
				'blog_title'=>$blog_title,
		);
		
		$result = array(
				'status'	=> 'ok',
				'created'	=> true,
				'site' 		=> $result
		);
		
		return $result;
	}
	
	/**
	 * Returns the current site info
	 */
	public function get_current_site() {
		
		return get_current_site();
	}
	
	/**
	 * Returns if site is multisite
	 */
	public function is_multisite() {
		$result = array(
				'status'=>'ok',
				'multisite'=>is_multisite()
				);
		
		return $result;
	}
	
	/**
	 * Returns if the user is on the main site. 
	 */
	public function is_mainsite() {
		
		$result = array(
				'status'=>'ok',
				'mainsite'=>is_main_site()
		);
		 
		return $result;
	}
	
	/**
	 * Returns if multisite is using sub domain or sub folder.  
	 */
	public function is_subdomain_install() {
		
		$result = array(
				'subdomain'=>is_subdomain_install(),
				'subfolder'=>!is_subdomain_install()
		);
		
		return $result;
	}

	/**
	 * Template for creating a new user for a blog, adding an existing user to a blog, 
	 * removing a user from a blog, and promoting a user. 
	 * NOT IMPLEMENTED
	 * Code is from site-users.php
	 */
	private function addAction($action) {
		
		/*
		switch ( $action ) {
			case 'newuser':
				check_admin_referer( 'add-user', '_wpnonce_add-new-user' );
				$user = $_POST['user'];
				if ( ! is_array( $_POST['user'] ) || empty( $user['username'] ) || empty( $user['email'] ) ) {
					$update = 'err_new';
				} else {
					$password = wp_generate_password( 12, false);
					$user_id = wpmu_create_user( esc_html( strtolower( $user['username'] ) ), $password, esc_html( $user['email'] ) );
		
					if ( false == $user_id ) {
						$update = 'err_new_dup';
					} else {
						wp_new_user_notification( $user_id, $password );
						add_user_to_blog( $id, $user_id, $_POST['new_role'] );
						$update = 'newuser';
					}
				}
				break;
		
			case 'adduser':
				check_admin_referer( 'add-user', '_wpnonce_add-user' );
				if ( !empty( $_POST['newuser'] ) ) {
					$update = 'adduser';
					$newuser = $_POST['newuser'];
					$user = get_user_by( 'login', $newuser );
					if ( $user && $user->exists() ) {
						if ( ! is_user_member_of_blog( $user->ID, $id ) )
							add_user_to_blog( $id, $user->ID, $_POST['new_role'] );
						else
							$update = 'err_add_member';
					} else {
						$update = 'err_add_notfound';
					}
				} else {
					$update = 'err_add_notfound';
				}
				break;
		
			case 'remove':
				if ( ! current_user_can( 'remove_users' )  )
					die(__('You can&#8217;t remove users.'));
				check_admin_referer( 'bulk-users' );
		
				$update = 'remove';
				if ( isset( $_REQUEST['users'] ) ) {
					$userids = $_REQUEST['users'];
		
					foreach ( $userids as $user_id ) {
						$user_id = (int) $user_id;
						remove_user_from_blog( $user_id, $id );
					}
				} elseif ( isset( $_GET['user'] ) ) {
					remove_user_from_blog( $_GET['user'] );
				} else {
					$update = 'err_remove';
				}
				break;
		
			case 'promote':
				check_admin_referer( 'bulk-users' );
				$editable_roles = get_editable_roles();
				if ( empty( $editable_roles[$_REQUEST['new_role']] ) )
					wp_die(__('You can&#8217;t give users that role.'));
		
				if ( isset( $_REQUEST['users'] ) ) {
					$userids = $_REQUEST['users'];
					$update = 'promote';
					foreach ( $userids as $user_id ) {
						$user_id = (int) $user_id;
		
						// If the user doesn't already belong to the blog, bail.
						if ( !is_user_member_of_blog( $user_id ) )
							wp_die(__('Cheatin&#8217; uh?'));
		
						$user = get_userdata( $user_id );
						$user->set_role( $_REQUEST['new_role'] );
					}
				} else {
					$update = 'err_promote';
				}
				break;
				
			//reset( $editblog_roles );
			//foreach ( $editblog_roles as $role => $role_assoc ) {
			//	$name = translate_user_role( $role_assoc['name'] );
			//	echo '<option ' . selected( $default_role, $role, false ) . ' value="' . esc_attr( $role ) . '">' . esc_html( $name ) . '</option>';
			//}
		}
		

		restore_current_blog();

		*/
	}
	
	/**
	 * Get blog details 
	 */
	public function get_blog() {
		$fields = array();
		
		if ( isset( $_REQUEST['domain'] ) ) {
			$fields['domain'] = $_REQUEST['domain'];
		}
		
		if ( isset( $_REQUEST['path'] ) ) {
			$fields['path'] = $_REQUEST['path'];
		}
		
		if ( isset( $_REQUEST['blogname'] ) ) {
			$fields['blogname'] = $_REQUEST['blogname'];
		}
		
		if ( isset( $_REQUEST['blog_id'] ) ) {
			$fields['blog_id'] = $_REQUEST['blog_id'];
		}
		
		$blog = get_blog_details($fields);
		
		return $blog;
	}
	
	/**
	 * Get a list of users 
	 * NOT IMPLEMENTED
	 */
	private function get_users() {
		
	}
	
	/**
	 * Promote user
	 * NOT IMPLEMENTED
	 */
	private function promote_user() {
		
	}
	
	/**
	 * Remove user
	 * NOT IMPLEMENTED
	 */
	private function remove_user() {
		
	}
	
	/**
	 * Add new user to blog
	 * NOT IMPLEMENTED
	 */
	private function add_new_user() {
		
	}
	
	/**
	 * Add existing user to blog
	 * NOT IMPLEMENTED
	 */
	private function add_existing_user() {
		
	}
}

?>