<?php
/*
Controller name: User
Controller description: Methods for user management

Code is based on code from wp-login.php.
Uses methods from wp-includes/user.php
*/
class JSON_API_User_Controller {

    public function is_user_logged_in() {
        $result = $this->get_logged_in_user();
		
		return $result;
    }
    
    public function get_logged_in_user() {
        global $user_ID;
    	
		if (is_user_logged_in()) {
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
		}
		
		return $result;
    }
    
    public function logout() {
    	/*
    	// from wp-login.php: 
    	check_admin_referer('log-out');
		wp_logout();
    	*/
    
        wp_logout();
        
        $results = $this->get_logged_in_user();
        
	    return $results;
    }
    
    public function login() {
        global $json_api;
    	
		$secure_cookie = '';
		$interim_login = isset($_REQUEST['interim-login']);
	
		// If the user wants ssl but the session is not ssl, force a secure cookie.
		if ( !empty($_POST['log']) && !force_ssl_admin() ) {
			$user_name = sanitize_user($_POST['log']);
			if ( $user = get_user_by('login', $user_name) ) {
				if ( get_user_option('use_ssl', $user->ID) ) {
					$secure_cookie = true;
					//force_ssl_admin(true);
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
		
	
		//$reauth = empty($_REQUEST['reauth']) ? false : true;
	
		
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
			
			// Clear errors if loggedout is set.
			if ( !empty($_GET['loggedout']) || $reauth ) {
				$errors = new WP_Error();
			}
		
			// If cookies are disabled we can't log in even with a valid user+pass
			if ( isset($_POST['testcookie']) && empty($_COOKIE[TEST_COOKIE]) )
				$errors->add('test_cookie', __("<strong>ERROR</strong>: Cookies are blocked or not supported by your browser. You must <a href='http://www.google.com/cookies.html'>enable cookies</a> to use WordPress."));
		
			// Some parts of this script use the main login form to display a message
			if		( isset($_GET['loggedout']) && TRUE == $_GET['loggedout'] )
				$errors->add('loggedout', __('You are now logged out.'), 'message');
			elseif	( isset($_GET['registration']) && 'disabled' == $_GET['registration'] )
				$errors->add('registerdisabled', __('User registration is currently not allowed.'));
			elseif	( isset($_GET['checkemail']) && 'confirm' == $_GET['checkemail'] )
				$errors->add('confirm', __('Check your e-mail for the confirmation link.'), 'message');
			elseif	( isset($_GET['checkemail']) && 'newpass' == $_GET['checkemail'] )
				$errors->add('newpass', __('Check your e-mail for your new password.'), 'message');
			elseif	( isset($_GET['checkemail']) && 'registered' == $_GET['checkemail'] )
				$errors->add('registered', __('Registration complete. Please check your e-mail.'), 'message');
			elseif	( $interim_login )
				$errors->add('expired', __('Your session has expired. Please log-in again.'), 'message');
		
			// Clear any stale cookies.
			if ( $reauth ) {
				wp_clear_auth_cookie();
			}
			
			return $errors;
		}
	
		//if (!$reauth) {
			if ( $interim_login ) {
				$message = "Login successful interim";
			}
			else {
				$message = "Login successful";
			}
	
			if ( ( empty( $redirect_to ) || $redirect_to == 'wp-admin/' || $redirect_to == admin_url() ) ) {
				// If the user doesn't belong to a blog, send them to user admin. If the user can't edit posts, send them to their profile.
				if ( is_multisite() && !get_active_blog_for_user($user->ID) && !is_super_admin( $user->ID ) )
					$redirect_to = user_admin_url();
				elseif ( is_multisite() && !$user->has_cap('read') )
					$redirect_to = get_dashboard_url( $user->ID );
				elseif ( !$user->has_cap('edit_posts') )
					$redirect_to = admin_url('profile.php');
			}
			//wp_safe_redirect($redirect_to);
			
			$user = $this->get_logged_in_user();
			
			return $user;
		//}
		
    }
    
    public function register() {
    	
    	if ( is_multisite() ) {
			// Multisite uses wp-signup.php
			//wp_redirect( apply_filters( 'wp_signup_location', site_url('wp-signup.php') ) );
			//exit;
			
			$error = new WP_Error();
			$error->add('multisite_not_supported', __('<strong>ERROR</strong>: Multisite is not supported at this time.'));
			
			return $error;
		}

		if (!get_option('users_can_register')) {
			$error = new WP_Error();
			$error->add('users_cannot_register', __('<strong>ERROR</strong>: Registration is not enabled for this site.'));
			
			return $error;
		}

		$user_login = '';
		$user_email = '';
		
		
		if ( empty($_POST['username']) || empty($_POST['email']) ) {
			$errors = new WP_Error();
			
			if (empty($_POST['username'])) {
				$errors->add('username_required', __("<strong>ERROR</strong>: A username is required."));
			}
			
			if (empty($_POST['email'])) {
				$errors->add('email_required', __("<strong>ERROR</strong>: A email is required."));
			}
		
			return $errors;
		}
		
		$user_login = $_POST['username'];
		$user_email = $_POST['email'];
			
		$result = register_new_user($user_login, $user_email);
		
		if (is_wp_error($result)) {
			return $result;
		}
		
		return array(
			'id' => $result,
			'status' => "ok",
			'created' => (bool) true
		);
		
		return $user_login;
		return $error;

		//$redirect_to = apply_filters( 'registration_redirect', !empty( $_REQUEST['redirect_to'] ) ? $_REQUEST['redirect_to'] : '' );
		//login_header(__('Registration Form'), '<p class="message register">' . __('Register For This Site') . '</p>', $errors);
    
    }
    
    public function lost_password() {
		global $wpdb, $current_site;

		$errors = new WP_Error();

		if ( empty( $_POST['username'] ) ) {
			$errors->add('empty_username', __('<strong>ERROR</strong>: Enter a username or e-mail address.'));
		}
		else if ( strpos( $_POST['username'], '@' ) ) {
			$user_data = get_user_by( 'email', trim( $_POST['username'] ) );
			
			if ( empty( $user_data ) ) {
				$errors->add('invalid_email', __('<strong>ERROR</strong>: There is no user registered with that email address.'));
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
			$errors->add('invalidcombo', __('<strong>ERROR</strong>: Invalid username or e-mail.'));
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
		$message .= sprintf(__('Username: %s'), $user_login) . "\r\n\r\n";
		$message .= __('If this was a mistake, just ignore this email and nothing will happen.') . "\r\n\r\n";
		$message .= __('To reset your password, visit the following address:') . "\r\n\r\n";
		$message .= '<' . network_site_url("wp-login.php?action=rp&key=$key&login=" . rawurlencode($user_login), 'login') . ">\r\n";

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

		if ( $message && !wp_mail($user_email, $title, $message) ) {
			$errors->add('email_not_sent', __('<strong>ERROR</strong>: The e-mail could not be sent. Possible reason: your host may have disabled the mail() function.'));
		}
		
		$result = array(
			'message' => $message,
			'status' => "ok",
			'sent' => (bool) true
		);
		
		//$result->message = $message;
		
		return $result;
    }
    
    public function reset_password() {
    	global $wpdb;
		
		$key = $_GET['key'];
		$login = $_GET['login'];
		$pass1 = $_POST['pass1'];

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

		$errors = $wpdb->get_row($wpdb->prepare("SELECT * FROM $wpdb->users WHERE user_activation_key = %s AND user_login = %s", $key, $login));

		if ( empty( $errors ) ) {
			$errors = new WP_Error('invalid_key', __('Invalid key'));
			return $errors;
		}
	
		if (is_wp_error($errors)) {
			return $errors;
		}
	
		$errors = '';
	
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
}

?>