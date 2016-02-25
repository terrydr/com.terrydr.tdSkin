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
    ,
    
jrCleanWithPath: function(filePath,successCallback, errorCallback) {
    console.log("jrCleanWithPath");
    cordova.exec(
                 successCallback,
                 errorCallback,
                 "JRCamera",
                 "jrCleanDataWithPath",
                 [filePath]
                 );
    
}
    ,
    
jrCleanAllData: function(successCallback, errorCallback) {
    console.log("jrCleanAllData");
    cordova.exec(
                 successCallback,
                 errorCallback,
                 "JRCamera",
                 "jrCleanAllData",
                 []
                 );
    
}
    
}


module.exports = jrCamera;
