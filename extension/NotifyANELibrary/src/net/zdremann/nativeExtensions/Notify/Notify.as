package net.zdremann.nativeExtensions.Notify
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExtensionContext;
	
	public class Notify extends EventDispatcher
	{
		private static var extContext:ExtensionContext = null;
		public static const MACHINETYPE_WASHER:String = "washer";
		public static const MACHINETYPE_DRYER:String = "dryer";
		public function Notify(target:IEventDispatcher=null)
		{
			super(target);
			if(!extContext)
			{
				extContext = ExtensionContext.createExtensionContext("net.zdremann.Notify", "Notify");
				extContext.call("initMe");
			}
		}
		public static function get isSupported():Boolean
		{
			var supported:Boolean = false;
			if(!extContext)
			{
				extContext = ExtensionContext.createExtensionContext("net.zdremann.Notify", "Notify");
				extContext.call("initMe");
			}
			supported = extContext.call("isSupported") as Boolean;
			return supported;
		}
		public function watchForMachine(roomId:int, machineNum:int):void
		{
			extContext.call("watchForMachine", roomId, machineNum);
		}
		public function watchForNMachines(roomId:int, type:String, numOfMachines:int):void
		{
			extContext.call("watchForNMachines", roomId, type, numOfMachines);
		}
	}
}