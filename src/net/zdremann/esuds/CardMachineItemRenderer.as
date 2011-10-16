package net.zdremann.esuds 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.events.ResizeEvent;
	import mx.events.ValidationResultEvent;
	import mx.formatters.PhoneFormatter;
	import mx.managers.LayoutManager;
	import mx.managers.PopUpManager;
	import mx.validators.EmailValidator;
	import mx.validators.PhoneNumberValidator;
	import spark.components.Button;
	import spark.components.LabelItemRenderer;
	import spark.components.List;
	import spark.components.SkinnablePopUpContainer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.components.TextInput;
	import net.zdremann.esuds.NotifyConformation;
	import spark.events.PopUpEvent;
	import net.zdremann.esuds.ErrorPopup;
	import net.zdremann.esuds.PhoneChooserPopup;
	/**
	 * ...
	 * @author Zachary Dremann
	 */
	public class CardMachineItemRenderer extends LabelItemRenderer 
	{
		private var _status:int;
		protected var statusDisplay:StyleableTextField;
		public function get status():int { return _status; }
		public function set status(value:int):void
		{
			_status = value;
			
			if (statusDisplay)
			{
				var str:String;
				str = ClothesMachine.typeToString(type);
				str += " Status: " + ClothesMachine.statusToString(_status);
				statusDisplay.text = str;
				invalidateSize();
			}
		}
		
		private var _timeRemaining:int;
		protected var timeRemainingDisplay:StyleableTextField;
		public function get timeRemaining():int { return _timeRemaining; }
		public function set timeRemaining(value:int):void
		{
			_timeRemaining = value;
			
			if (timeRemainingDisplay)
			{
				timeRemainingDisplay.text = 
					(_timeRemaining<1)?"":_timeRemaining.toString() + " Min Remaining";
				invalidateSize();
			}
		}
		
		private var _type:int;
		public function get type():int { return _type; }
		public function set type(value:int):void
		{
			_type = value;
			
			var str:String;
			str = ClothesMachine.typeToString(_type);
			label = str + " " + data.number;
			
			invalidateSize();
		}
		
		protected var notifTextDisplay:StyleableTextField;
		
		protected var notifEmailInput:TextInput;
		
		protected var notifSubmitBtn:Button;
		
		protected var emailValidator:EmailValidator = new EmailValidator();
		protected var phoneValidator:PhoneNumberValidator = new PhoneNumberValidator();
		
		public function CardMachineItemRenderer() 
		{
			super();
			
			this.addEventListener(ResizeEvent.RESIZE, onResize);
			
			//this.cacheAsBitmap = true;
			
			this.minHeight = 0;
			
			this.emailValidator.requiredFieldError = "Cannot notify an empty email address";
		}
		
		private function onResize(e:ResizeEvent):void 
		{
			if (this.currentPopup)
			{
				this.currentPopup.maxWidth = this.width;
				this.currentPopup.maxHeight = this.height;
				this.currentPopup.width = 0;
				this.currentPopup.width = NaN;
				PopUpManager.centerPopUp(this.currentPopup);
				
			}
		}
		
		public const paddingTop:Number		= 60;
		public const paddingBottom:Number	= paddingTop;
		public const paddingLeft:Number		= paddingTop;
		public const paddingRight:Number	= paddingTop;
		public const paddingInner:Number 	= 15;
		
		override public function set data(value:Object):void 
		{
			super.data = value;
			
			if (!value)
				return;
			
			notifEmailInput.text = FlexGlobals.topLevelApplication.persistenceManager.getProperty("emailOrPhone");
			
			this.type = value.type as int;
			this.status = value.status as int;
			this.timeRemaining = value.timeRemaining as int;
		}
		override protected function createLabelDisplay():void 
		{
			super.createLabelDisplay();
			
			statusDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			statusDisplay.styleName = this.owner;
			statusDisplay.editable = false;
			statusDisplay.selectable = false;
			statusDisplay.multiline = false;
			statusDisplay.wordWrap = false;
			statusDisplay.cacheAsBitmap = true;
			
			addChild(statusDisplay);
			
			timeRemainingDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			timeRemainingDisplay.styleName = this;
			timeRemainingDisplay.editable = false;
			timeRemainingDisplay.selectable = false;
			timeRemainingDisplay.multiline = false;
			timeRemainingDisplay.wordWrap = false;
			timeRemainingDisplay.cacheAsBitmap = true;
			
			addChild(timeRemainingDisplay);
			
			notifTextDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			notifTextDisplay.styleName = this;
			notifTextDisplay.editable = false;
			notifTextDisplay.selectable = false;
			notifTextDisplay.multiline = false;
			notifTextDisplay.wordWrap = false;
			notifTextDisplay.cacheAsBitmap = true;
			
			notifTextDisplay.text = "Notify me when available: ";
			addChild(notifTextDisplay);
			
			notifEmailInput = new TextInput();
			notifEmailInput.prompt = "Enter email or phone number";
			addChild(notifEmailInput);
			
			notifSubmitBtn = new Button();
			notifSubmitBtn.label = "Notify Me";
			notifSubmitBtn.cacheAsBitmap = true;
			addChild(notifSubmitBtn);
			
			labelDisplay.setStyle("fontSize", 30);
			labelDisplay.setStyle("fontWeight", "bold");
			statusDisplay.setStyle("fontSize", 25);
			timeRemainingDisplay.setStyle("fontSize", 25);
			notifTextDisplay.setStyle("fontSize", 25);
			notifEmailInput.setStyle("fontSize", 25);
			
			notifSubmitBtn.addEventListener(MouseEvent.CLICK, notifSubitBtnClick_Handler);
			
			emailValidator.source = notifEmailInput;
			emailValidator.property = "text";
			emailValidator.required = true;
			
			phoneValidator.source = notifEmailInput;
			phoneValidator.property = "text";
			emailValidator.required = true;
		}
		
		private var currentPopup:SkinnablePopUpContainer;
		
		private function notifSubitBtnClick_Handler(e:MouseEvent):void 
		{
			emailValidator.validate();
			if (!notifEmailInput.errorString)
			{
				var notifyConfirm:NotifyConformation = new NotifyConformation();
				notifyConfirm.message = "Are you sure you want to be notified?";
				notifyConfirm.addEventListener(PopUpEvent.CLOSE, notifyConfirmClose_Handler, false, 0, true);
				notifyConfirm.maxWidth = this.width;
				notifyConfirm.maxHeight = this.height;
				notifyConfirm.open(this.owner, true);
				PopUpManager.centerPopUp(notifyConfirm);
				currentPopup = notifyConfirm;
			}
			else
			{
				var errorPopup:ErrorPopup = new ErrorPopup();
				errorPopup.errorMessage = notifEmailInput.errorString;
				if (phoneValidator.validate().type == ValidationResultEvent.VALID)
				{
					if (FlexGlobals.topLevelApplication.persistenceManager.getProperty("carrierList") is Array)
					{
						var numText:String = (notifEmailInput.text as String).replace("-", "").replace("(", "").replace(")", "").replace(" ","");
						for each(var carrier:Object in (FlexGlobals.topLevelApplication.persistenceManager.getProperty("carrierList") as Array))
						{
							if (carrier.number == numText)
							{
								var notifyPopup:NotifyConformation = new NotifyConformation();
								notifyPopup.message = "Are you sure you want to be notified?";
								notifyPopup.maxWidth = this.width;
								notifyPopup.maxHeight = this.height;
								notifyPopup.addEventListener(PopUpEvent.CLOSE, phoneNotifyClose);
								notifyPopup.open(this.owner, true);
								PopUpManager.centerPopUp(notifyPopup);
								currentPopup = notifyPopup;
								return;
							}
						}
					}
					errorPopup = null;
					var phoneChoser:PhoneChooserPopup = new PhoneChooserPopup();
					phoneChoser.addEventListener(PopUpEvent.CLOSE, phoneChoserClose_Handler);
					phoneChoser.maxWidth = this.width;
					phoneChoser.maxHeight = this.height;
					phoneChoser.open(this.owner, true);
					PopUpManager.centerPopUp(phoneChoser);
					currentPopup = phoneChoser;
					return;
				}
				errorPopup.addEventListener(PopUpEvent.CLOSE, errorPopupClose_Handler, false, 0, true); 
				errorPopup.maxWidth = this.width;
				errorPopup.maxHeight = this.height;
				errorPopup.open(this.owner, true);
				currentPopup = errorPopup;
				PopUpManager.centerPopUp(errorPopup);
			}
		}
		
		private function phoneNotifyClose(e:PopUpEvent):void 
		{
			currentPopup = null;
			if (e.commit)
			{
				var numText:String = (notifEmailInput.text as String).replace("-", "").replace("(", "").replace(")", "").replace(" ", "");
				var carrier:Object;
				for each(var phone:Object in FlexGlobals.topLevelApplication.persistenceManager.getProperty("carrierList") as Array)
				{
					if (phone.number == numText)
					{
						carrier = phone.carrier;
						break;
					}
				}
				sendEmailToPhone(carrier);
			}
		}
		
		private function phoneChoserClose_Handler(e:PopUpEvent):void 
		{
			currentPopup = null;
			if (e.commit)
			{
				sendEmailToPhone(e.data);
				var numText:String = (notifEmailInput.text as String).replace("-", "").replace("(", "").replace(")", "").replace(" ","");
				var currArray:Array = [];
				if (FlexGlobals.topLevelApplication.persistenceManager.getProperty("carrierList") is Array)
					currArray = FlexGlobals.topLevelApplication.persistenceManager.getProperty("carrierList");
				currArray.push( { number:numText, carrier:e.data } );
				FlexGlobals.topLevelApplication.persistenceManager.setProperty("carrierList", currArray)
			}
		}
		
		private function sendEmailToPhone(carrier:Object):void
		{
			var formater:PhoneFormatter = new PhoneFormatter();
			formater.areaCode = -1;
			var numText:String = (notifEmailInput.text as String).replace("-", "").replace("(", "").replace(")", "").replace(" ","");
			notifEmailInput.text = formater.format(numText);
			FlexGlobals.topLevelApplication.persistenceManager.setProperty("emailOrPhone", notifEmailInput.text);
			var email:String = (carrier.email as String).replace("[num]", numText);
			requestNotification(email);
		}
		
		private function errorPopupClose_Handler(e:PopUpEvent):void 
		{
			currentPopup = null;
		}
		
		private function requestNotification(email:String, selectedMachine:uint = 0):void
		{
			trace(email);
			if (!selectedMachine)
				selectedMachine = data.id;
			
			var vars:URLVariables = new URLVariables();
			var req:URLRequest = new URLRequest("http://stevenson.esuds.net/RoomStatus/requestNotification.do");
			vars.roomId = FlexGlobals.topLevelApplication.persistenceManager.getProperty('room').roomId;
			vars.emailAddress = email;
			vars.selectedMachines = selectedMachine;
			req.data = vars;
			req.method = "POST";
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, postloaderCompleate_Handler);
			loader.load(req);
		}
		
		private function notifyConfirmClose_Handler(e:PopUpEvent):void 
		{
			currentPopup = null;
			if (e.commit)
			{
				FlexGlobals.topLevelApplication.persistenceManager.setProperty("emailOrPhone", notifEmailInput.text);
				requestNotification(notifEmailInput.text);
			}
		}
		private function postloaderCompleate_Handler(event:Event):void
		{
			var data:String = event.target.data;
			var errorPopup:ErrorPopup = new ErrorPopup();
			errorPopup.errorMessage = "";
			if ( data.indexOf("errors") != -1)
			{
				var knownError:Boolean = false;
				if (data.indexOf("The email address is not valid.") != -1)
				{
					errorPopup.errorMessage += "The email address is not valid\n";
					knownError = true;
				}
				if (data.indexOf("is not in use") != -1)
				{
					errorPopup.errorMessage += "Selected machine is already in use\n";
					knownError = true;
				}
				if (data.indexOf("You are already registered to receive notification") != -1)
				{
					errorPopup.errorMessage += "You are already registered to receive a notification for this machine\n";
					knownError = true;
				}
				if (!knownError)
				{
					errorPopup.errorMessage = "An unknown error occured";
				}
				
				errorPopup.maxWidth = this.width;
				errorPopup.maxHeight = this.height;
				this.currentPopup = errorPopup;
				errorPopup.open(this.owner, true);
				PopUpManager.centerPopUp(errorPopup);
			}
		}
		
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			this.width = this.owner.width;
			this.height = this.owner.height;
			if (!labelDisplay || !statusDisplay || !timeRemainingDisplay)
				return;
			
			var viewWidth:Number = unscaledWidth - paddingLeft - paddingRight;
			var viewHeight:Number = unscaledHeight - paddingTop - paddingBottom;
			
			var labelWidth:Number = 0;
			var labelHeight:Number = 0;
			
			if (label != "")
			{
				labelDisplay.commitStyles();
				
				if (labelDisplay.isTruncated)
					labelDisplay.text = label;
				
				labelHeight = getElementPreferredHeight(labelDisplay);
			}
			
			var labelY:Number = paddingTop;
			
			labelWidth = viewWidth;
			
			setElementSize(labelDisplay, labelWidth, labelHeight);
			setElementPosition(labelDisplay, paddingLeft, labelY);
			labelDisplay.truncateToFit();
			
			var statusWidth:Number = 0;
			var statusHeight:Number = 0;
			if (status != -1)
			{
				statusDisplay.commitStyles();
				
				if (statusDisplay.isTruncated)
					status = status;
				
				statusHeight = getElementPreferredHeight(statusDisplay);
				//Prefered width could be more than view width, if this is the case, set the width to the max view width
				statusWidth = Math.min(getElementPreferredWidth(statusDisplay),viewWidth);
			}
			
			setElementSize(statusDisplay, statusWidth, statusHeight);
			
			var statusY:Number = paddingTop + paddingInner + labelHeight;
			setElementPosition(statusDisplay, paddingLeft, statusY);
			statusDisplay.truncateToFit();
			
			var timeRemainingWidth:Number = 0;
			var timeRemainingHeight:Number = 0;
			var timeRemainingNextToStatus:Boolean = false;
			if (timeRemaining > 0)
			{
				timeRemainingDisplay.visible = true;
				timeRemainingDisplay.commitStyles();
				
				if (timeRemainingDisplay.isTruncated)
					timeRemaining = _timeRemaining;
				
				//Prefered width could be more than view width, if this is the case, set the width to the max view width
				timeRemainingWidth = Math.min(getElementPreferredWidth(timeRemainingDisplay), viewWidth);
				if (this.width>this.height && timeRemainingWidth < viewWidth - paddingInner - statusWidth)
					timeRemainingNextToStatus = true;
				timeRemainingHeight = getElementPreferredHeight(timeRemainingDisplay);
				setElementSize(timeRemainingDisplay, timeRemainingWidth, timeRemainingHeight);
			
				var timeRemainingY:Number;
				var timeRemainingX:Number;
				if (timeRemainingNextToStatus)
				{
					timeRemainingX = paddingLeft + viewWidth - timeRemainingWidth;
					timeRemainingY = paddingTop + paddingInner + labelHeight;
				}
				else
				{
					timeRemainingX = paddingLeft;
					timeRemainingY = paddingTop + 2 * paddingInner + labelHeight + statusHeight;
				}
				setElementPosition(timeRemainingDisplay, timeRemainingX, timeRemainingY);
				timeRemainingDisplay.truncateToFit();
			}
			else
			{
				timeRemainingDisplay.visible = false;
			}
			
			if (data.id && status!=ClothesMachine.AVAILABLE)
			{
				notifTextDisplay.visible = true;
				notifEmailInput.visible = true;
				notifSubmitBtn.visible = true;
				
				var notifTextHeight:Number = 0;
				var notifTextWidth:Number = 0;
				notifTextDisplay.commitStyles();
				
				if (notifTextDisplay.isTruncated)
					notifTextDisplay.text = "Notify me when available: ";
			
				notifTextWidth = Math.min(getElementPreferredWidth(notifTextDisplay), viewWidth);
				notifTextHeight = getElementPreferredHeight(notifTextDisplay);
				setElementSize(notifTextDisplay, notifTextWidth, notifTextHeight);
			
				var notifTextY:Number = paddingTop + 3 * paddingInner + labelHeight + statusHeight;
				if (timeRemainingDisplay.visible && !timeRemainingNextToStatus)
					notifTextY += timeRemainingHeight + paddingInner;
				setElementPosition(notifTextDisplay, paddingLeft, notifTextY);
				notifTextDisplay.truncateToFit();
				
				var notifEmailWidth:Number = viewWidth;
				var notifEmailHeight:Number = getElementPreferredHeight(notifEmailInput);
				setElementSize(notifEmailInput, notifEmailWidth, notifEmailHeight);
				
				var notifEmailX:Number = paddingLeft;
				var notifEmailY:Number = paddingTop + 4 * paddingInner + labelHeight + statusHeight + notifTextHeight;
				
				if (!timeRemainingNextToStatus)
				{
					notifEmailY += paddingInner + timeRemainingHeight;
				}
				setElementPosition(notifEmailInput, notifEmailX, notifEmailY);
				
				var notifSubmitWidth:Number = viewWidth;
				var notifSubmitHeight:Number = getElementPreferredHeight(notifSubmitBtn);
				setElementSize(notifSubmitBtn, notifSubmitWidth, notifSubmitHeight);
				
				var notifSubmitX:Number = paddingLeft;
				var notifSubmitY:Number = paddingTop + 5 * paddingInner + labelHeight + statusHeight + notifTextHeight + notifEmailHeight;
				if (!timeRemainingNextToStatus)
				{
					notifSubmitY += paddingInner + timeRemainingHeight;
				}
				setElementPosition(notifSubmitBtn, notifSubmitX, notifSubmitY);
			}
			else
			{
				notifTextDisplay.visible = false;
				notifEmailInput.visible = false;
				notifSubmitBtn.visible = false;
			}
		}
		override protected function measure():void
		{
			super.measure();
			
			if (statusDisplay && timeRemainingDisplay)
			{
				if (statusDisplay.isTruncated)
					status = _status;
				if (timeRemainingDisplay.isTruncated)
					timeRemaining = _timeRemaining;
				
				var horizontalPadding:Number = paddingLeft + paddingRight;
				var verticalPadding:Number = paddingTop + paddingBottom + paddingInner *2;
				
				statusDisplay.commitStyles();
				timeRemainingDisplay.commitStyles();
				
				measuredWidth = owner.width;
				
				measuredHeight = owner.height;
			}
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var backgroundColors:Array;
			
			if(status == ClothesMachine.IN_USE)
				backgroundColors = [scaleColor(0xcc2525), 0xcc2525];
			else if (status == ClothesMachine.CYCLE_COMPLETE)
				backgroundColors = [scaleColor(0xbC480A), 0xbC480A];
			else if (status == ClothesMachine.AVAILABLE)
				backgroundColors = [scaleColor(0x24850c), 0x24850c];
			else// if (status == ClothesMachine.UNAVAILABLE)
				backgroundColors = [scaleColor(0x666666), 0x666666];
			
			var matrix2:Matrix = new Matrix();
			matrix2.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2);
			graphics.beginGradientFill(GradientType.LINEAR, backgroundColors, [1, 1], [0, 255], matrix2);
			graphics.drawRoundRect(20, 20, unscaledWidth - 20 - 20, unscaledHeight - 20 - 20, 100, 100);
			graphics.endFill();
		}
		private static function scaleColor(color:uint, scale:Number=.25):uint
		{
			var r:int = (color & 0xFF0000) >> 16;
			var g:int = (color & 0x00FF00) >> 8;
			var b:int = color & 0x0000FF;
			r += (255 * scale)*(r/(r+g+b)); r = (r > 255) ? 255 : r; r = (r < 0) ? 0 : r;
			g += (255 * scale)*(g/(r+g+b)); g = (g > 255) ? 255 : g; g = (g < 0) ? 0 : g;
			b += (255 * scale)*(b/(r+g+b)); b = (b > 255) ? 255 : b; b = (b < 0) ? 0 : b;
			return (r << 16 & 0xff0000) + (g << 8 & 0x00ff00) + (b & 0x0000ff);
		}
		
	}

}