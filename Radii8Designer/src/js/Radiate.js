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

Radiate = function () {};

Radiate.prototype.aceEditor		= null;
Radiate.prototype.instance		= null;
Radiate.prototype.postFrame 	= null;
Radiate.prototype.wpPath 		= "/blog/wp-admin/";
Radiate.prototype.flashInstance = null;

Radiate.getInstance = function() {
	if (this.instance==null) {
		this.instance = new Radiate();
	}
	return this.instance;
}

Radiate.prototype.initialize = function () {
	
}

Radiate.prototype.setFlashInstance = function (flashID) {
	var flash = document.getElementById(flashID);
	this.flashInstance = flash;
	//console.log ("Flash instance: " + flash);
} 

///////////////////////////////////
// POST CODE 
///////////////////////////////////

Radiate.prototype.createPostIFrame = function () {

	if (document.getElementById("wordpressthing")==null) {
	    var iframe = document.createElement('iframe');
	    iframe.id="wordpressthing";
	    iframe.width = "100%";
		iframe.src = "http://www.radii8.com/blog/wp-admin/post.php?post=212&action=edit";
		iframe.style="display:none";
		document.body.appendChild(iframe);
		this.postFrame = iframe;
	}
}

Radiate.prototype.addPost = function () {
	console.log("add post");
	
	if (this.postFrame) {
		this.postFrame.onready = this.newPostReadyCallBack;
		this.postFrame.onload  = this.newPostReadyCallBack;
		this.postFrame.src = "http://www.radii8.com/blog/wp-admin/post-new.php";
	}
}

Radiate.prototype.newPostReadyCallBack = function (event) {
	var postFrame = Radiate.instance.postFrame;
	var el = postFrame.contentDocument ? postFrame.contentDocument.getElementById('post_ID') : null;
	var postID = el ? el.value : null;
	
	if (postID==null) {
	
		if (postFrame.contentDocument==null) {
			console.log("Could not access frame content. Must be on the same server.");
			Radiate.instance.flashInstance.notOnServer();
		}
		else if (postFrame.contentWindow.location.href.indexOf("wp-login.php")!=-1) {
			console.log("Not logged in");
			Radiate.instance.flashInstance.notLoggedIn();
		}
	}
	else {
		Radiate.instance.flashInstance.addPostCallback(postID);
		console.log("New post added");
	}
}

Radiate.prototype.isPostFrameCreated = function () {

	if (this.postFrame) {
		return true;
	}
	
	return false;
}

Radiate.prototype.editPost = function (postID) {

	if (this.postFrame) {
		this.postFrame.onReady = this.editPostReadyCallBack;
		this.postFrame.src = "http://www.radii8.com/blog/wp-admin/post.php?post=" + postID + "&action=edit";
	}
}

Radiate.prototype.editPostReadyCallBack = function () {
	console.log("Edit Post Ready: " + this.postFrame.src);
}

Radiate.prototype.savePostDraft = function () {
	if (this.postFrame) {
		this.postFrame.contentDocument.getElementById('save-post').click();
		console.log("Draft saved.");
	}
}

Radiate.prototype.previewPost = function () {
	if (this.postFrame) {
		this.postFrame.contentDocument.getElementById('post-preview').click();
		console.log("Preview post");
	}
}

Radiate.prototype.publishPost = function () {
	if (this.postFrame) {
		this.postFrame.contentDocument.getElementById('publish').click();
		console.log("Published");
	}
}

Radiate.prototype.getPostTitle = function () {
	if (this.postFrame) {
		var value = this.postFrame.contentDocument.getElementById('title').value;
		console.log("Title: " + value);
		return value;
	}
	
	return null;
}

Radiate.prototype.getPostContent = function () {
	if (this.postFrame) {
		var value = this.postFrame.contentDocument.getElementById('content').value;
		console.log("Content: " + value);
		return value;
	}
	
	return null;
}

Radiate.prototype.getPostId = function () {
	if (this.postFrame) {
		var value = this.postFrame.contentDocument.getElementById('post_ID').value;
		console.log("Post ID: " + value);
		return value;
	}
	
	return null;
}


Radiate.prototype.setPostTitle = function (value) {
	if (this.postFrame) {
		this.postFrame.contentDocument.getElementById('title').value = value;
		console.log("Title set to: " + value);
		return true;
	}
	
	return false;
}


Radiate.prototype.setPostContent = function () {
	if (this.postFrame) {
		this.postFrame.contentDocument.getElementById('content').value = value;
		console.log("Content set to: " + value);
		return true;
	}
	
	return false;
}

Radiate.prototype.showHidePostFrame = function () {
	if (this.postFrame) {
		this.postFrame.style.display = this.postFrame.style.display=='none' ? 'block' : 'none';
		console.log("Post frame display: " + postFrame.style.display);
	}
}



///////////////////////////////////
// ASK BEFORE NAVIGATION
///////////////////////////////////

Radiate.prototype.beforeUnloadHandler = function () {
	var testing = window.location.search.substr(1).indexOf("debug=true");
	
	if (testing==-1) {
		return "Are you sure you want to navigate away?";
	}
	else {
		//return false;
	}
}
	
Radiate.prototype.onloadHandler = function () {
	window.onbeforeunload = beforeUnloadHandler;
}




