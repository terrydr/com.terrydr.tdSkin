var jrCamera = {
    
jrTakePhotos: function(successCallback, errorCallback) {
    console.log("invoked");
	cordova.exec(
            successCallback,
            errorCallback,
            "JRCamera",
            "jrTakePhotos",
	    []
        );

}
}


module.exports = jrCamera;
