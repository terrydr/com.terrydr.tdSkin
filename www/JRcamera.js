var jrCamera = {
    
jrTakePhotos: function(urlScheme, successCallback, errorCallback) {
    console.log("invoked");
	cordova.exec(
            successCallback,
            errorCallback,
            "JRCamera",
            "jrTakePhotos",
            [urlScheme]
        );

}
}


module.exports = jrCamera;