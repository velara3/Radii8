/**
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

//TODO: Refactor this into a StoreLogin class 

// removed code until license is found
var DocumentManager; // basically this gets an element by id and adds or removes elements
var EventManager; // this adds event listeners to elements

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