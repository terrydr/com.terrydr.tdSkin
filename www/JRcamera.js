//Cordova.define可以理解是在Cordova框架中定义个TestPlugin名称的类。

　　　　cordova.define("com.junruihealthcare.plugins.TestMyPlugin.TestPlugin", function(require, exports, module) {
                   
                   　　 　 cordova.define("com.liki.plugins.testMyPlugin.TestPlugin", function(require, exports, module) {
                                       
                                       　　　　　//可以理解为Java中的构造方法，用于创建类的对象。
                                       
                                       　　　　function TestPlugin() {}
                                       
                                       　　　　　　//在类的prototype(原型)中定义一个函数。
                                       
                                       　　　　 TestPlugin.prototype.getDeviceMore  = function(onSuccessCallBack,errorCallBack,【其他参数可选】){
                                       
                                       　　　　　　//使用Cordova创建调用原生代码，最终会将下面参数拼接成URL，然后在原生中截获,后面的param1---3参数是可选，必须是以数组方式传入。
                                       
                                       　　  cordova.exec(onSuccessCallBack,errorCallBack,"CustomPlugin","getSystemVersionByParms",[param1,param2,param3]);
                                       
                                       　　} 
                                       
                                       //Cordova框架加载时初始化该类的对象。
                                       
                                       　　module.exports = new TestPlugin();});});