var jrCamera = {
    
jrTakePhotos: function(urlScheme, successCallback, errorCallback) {
    
    cordova.exec(successCallback,errorCallback,'JRCamera','jrTakePhotos',[urlScheme]);
}
}


module.exports = jrCamera;