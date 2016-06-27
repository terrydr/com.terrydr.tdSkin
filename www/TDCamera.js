var tdCamera = {
tdTakePhotos: function(successCallback, errorCallback) {
    console.log("invoked");
    cordova.exec(
                 successCallback,
                 errorCallback,
                 "TDCamera",
                 "tdTakePhotos",
                 []
                 );
    
}
    ,
    
tdCleanWithPath: function(filePath,successCallback, errorCallback) {
    console.log("tdCleanWithPath");
    cordova.exec(
                 successCallback,
                 errorCallback,
                 "TDCamera",
                 "tdCleanDataWithPath",
                 [filePath]
                 );
    
}
    ,
    
tdCleanAllData: function(successCallback, errorCallback) {
    console.log("tdCleanAllData");
    cordova.exec(
                 successCallback,
                 errorCallback,
                 "TDCamera",
                 "tdCleanAllData",
                 []
                 );
    
}
    
}


module.exports = tdCamera;
