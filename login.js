#!/usr/bin/phantomjs
"use strict";
var page = require('webpage').create();
var closeFunc = function(){
    phantom.exit();
}
function hotsplotsEvent(mode){
    console.log("Hotsplots.Mode is now '" + mode + "'");
    if (mode == "already") {
	console.log("You are already logged in.");
	return true;
    }
    if (mode == "success") {
	console.log("Login successfull.");
	return true;
    }
    if (mode == "notyet") {
	console.log("Logging in...");
	return false;
    }
    if (mode == "logoff") {
	console.log("Logged off.");
	return false;
    }
}
function uampEvent(mode) {
    console.log("Hotsplots.UMAP is now '" + mode + "'");
}
page.onUrlChanged = function(url){
    if (url.indexOf("login.php") > 0 || url.indexOf("192.168") > -1){
	if (url.indexOf("login.php") > 0){
	    var mode = url.substring(url.indexOf("res=") + 4);
	    mode = mode.substring(0,mode.indexOf("&"));
	    var eventResult = hotsplotsEvent(mode);
	    if (eventResult == true){
		setTimeout(closeFunc,100);
	    }
	} else {
	    uampEvent(url);
	}
    }
}

page.open("http://192.168.44.1/", function(status) {
    if (status === "success") {
	page.evaluate(function(){
	    console.log(document.location.href);
	    console.log(document.title);
	    if(document.getElementById("checkAGB") != undefined){
		document.getElementById("checkAGB").checked = true;
		document.getElementById("tFreeloginBtn").click();
	    }
	});
    } else {
	phantom.exit();
    }
});
