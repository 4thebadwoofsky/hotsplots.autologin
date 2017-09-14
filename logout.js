#/usr/bin/phantomjs
"use strict";
var page = require('webpage').create();
var closeFunc = function(){
    phantom.exit();
}
function hotsplotsEvent(mode){
    console.log("Hotsplots.Mode is now '" + mode + "'");
    if(mode == "logoff"){
	console.log("Logged off.");
	return true;
    }
    return false;
}
function uampEvent(mode){
    console.log("Hotsplots.UMAP is now '" + mode + "'");
}

page.onResourceRequested = function(args) {
    var url = args.url;
    if (url.indexOf("login.php") > 0 || url.indexOf("192.168") > -1){
	if (url.indexOf("login.php") > 0){
	    var mode = url.substring(url.indexOf("res=") + 4);
	    mode = mode.substring(0,mode.indexOf("&"));
	    var eventResult = hotsplotsEvent(mode);
	    if (eventResult == true){
		setTimeout(closeFunc,100);

	    }
	}else{
	    uampEvent(url);
	}
    }
}

page.open("http://192.168.44.1/logoff", function(status) {
    if (status === "success") {
	page.evaluate(function(){
	    console.log(document.location.href);
	    console.log(document.title);
	});
    } else {
	console.log("status = " + status);
	phantom.exit(1);
    }
});
