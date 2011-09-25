package net.zdremann.esuds 
{
	/**
	 * ...
	 * @author Zachary Dremann
	 */
	[Bindable]
	public class ClothesMachine 
	{
		public static const AVAILABLE:int = 1;
		public static const IN_USE:int = 3;
		public static const CYCLE_COMPLETE:int = 2;
		public static const UNAVAILABLE:int = 4;
		
		public static const WASHER:int = 0;
		public static const DRYER:int = 1;
		
		public var id:uint;
		public var number:int;
		public var type:int;
		public var status:int;
		public var timeRemaining:int;
		
		public function ClothesMachine(id:uint = 0, number:int = -1, type:int = -1, status:int = -1, timeRemaining:int = -1) 
		{
			this.id = id;
			this.number = number;
			this.type = type;
			this.status = status;
			this.timeRemaining = timeRemaining;
		}
		public function toString():String
		{
			var sType:String;
			switch(this.type)
			{
			case 0:
				sType = "Washer";
				break;
			case 1:
				sType = "Dryer";
				break;
			default:
				sType = "UNKNOWN";
				break;
			}
			var sStatus:String = statusToString(status);
			return sType + ":{id=" + id + ", number=" + number + ", status=" +sStatus + ", timeRemaining=" + timeRemaining + "}";
		}
		public static function statusToString(status:int):String
		{
			switch (status)
			{
			case ClothesMachine.AVAILABLE:
				return "Available";
				break;
			case ClothesMachine.CYCLE_COMPLETE:
				return "Cycle Complete";
				break;
			case ClothesMachine.IN_USE:
				return "In Use";
				break;
			case ClothesMachine.UNAVAILABLE:
				return "Unavailable";
				break;
			case -2: // is header
				return "";
			default:
				return "Unknown Status";
				break;
			}
		}
	}

}