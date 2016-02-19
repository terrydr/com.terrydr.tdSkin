var cordova=require('cordova');

var  JRCamera =function(){
    
    JRCamera.prototype.jrTakePhotos=function(success,error,str){
        
        cordova.exec(sucess,error,'JRCamera','jrTakePhotos',str)//'Echo'对应我们在java文件中定义的类名，echo对应我们在这个类中调用的自定义方法，str是我们客户端传递给这个方法的参数，是个数组
        
    }
    
}
var  jrCamera=new JRCamera();

module.exports=jrCamera;