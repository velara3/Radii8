
//refactor this into a class 

				var DocumentManager = {
					get: function(el) {
						if (typeof el === 'string') {
							return document.getElementById(el);
						} else {
							return el;
						}
					},
					add: function(el, dest) {
						var el = this.get(el);
						var dest = this.get(dest);
						if (!dest) dest = document.body;
						dest.appendChild(el);
					},
					remove: function(el) {
						var el = this.get(el);
						el.parentNode.removeChild(el);
					}
				};
			
				var EventManager = {
					add: function() {
						if (window.addEventListener) {
							return function(el, type, fn) {
								DocumentManager.get(el).addEventListener(type, fn, false);
							};
						} else if (window.attachEvent) {
							return function(el, type, fn) {
								var f = function() {
									fn.call(DocumentManager.get(el), window.event);
								};
								DocumentManager.get(el).attachEvent('on' + type, f);
							};
						}
					}()
				};
			
				function resizeApplication(id, value) {
					var el = DocumentManager.get(id);
					el.style.height = value;
					return true;
				}
				
				function insertForm(id) {
					var form 		= document.createElement('form');
					var textinput 	= document.createElement('input');
					var password 	= document.createElement('input');
			
					form.id 		= id;
					textinput.id 	= "username";
					password.id 	= "password";
					password.type 	= "password";
			
					form.appendChild(textinput);
					form.appendChild(password);
					DocumentManager.add(form);
			
					return true;
				}
				
				function setFormValues(username, password) {
					var usernameInput = DocumentManager.get('username');
					var passwordInput = DocumentManager.get('password');
					usernameInput.value = username;
					passwordInput.value = password;
					return true;
				}
				
				function getFormValues() {
					var usernameInput = DocumentManager.get('username');
					var passwordInput = DocumentManager.get('password');
					return [usernameInput.value, passwordInput.value];
				}
				
				function clearFormValues() {
					var usernameInput = DocumentManager.get('username');
					var passwordInput = DocumentManager.get('password');
					usernameInput.value = "";
					passwordInput.value = "";
					return true;
				}
			
				function getUsername() {
					var usernameInput = DocumentManager.get('username');
					return usernameInput.value;
				}
				
				function getPassword() {
					var passwordInput = DocumentManager.get('password');
					return passwordInput.value;
				}
				
				function submitForm(id) {
					var form = DocumentManager.get(id);
					//form.action = window.location.href;
					form.submit();
					form.submit();// chrome
					return true;
				}
			
				function noDirectLogin(){
					return false;
				}

				function checkForPassword(username) {
					var usernameInput = DocumentManager.get('username');
					var passwordInput = DocumentManager.get('password');
					usernameInput.value = username;
					if (username!="") {
						usernameInput.focus();
						usernameInput.blur();
					}
					else {
						passwordInput.value = "";
					}
					//passwordInput.focus();
					return passwordInput.value;
				}
				
				function setFocusOnFlash(id) {
					var application = DocumentManager.get(id);
					application.tabIndex = 0;
					application.focus();
					return true;
				}
			
				function formExists(id) {
					var form = DocumentManager.get(id);
					return form!=null;
				}
				
				function showForm(id) {
					var form = DocumentManager.get(id);
					form.style.display = "block";
					return true;
				}
				
				function hideForm(id) {
					var form = DocumentManager.get(id);
					form.style.display = "none";
					return true;
				}
			
				function scriptConfirmation() {
					return true;
				}