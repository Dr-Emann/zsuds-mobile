package net.zdremann.esuds 
{
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import spark.components.Label;
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.events.ListEvent;
	import spark.layouts.HorizontalLayout;
	
	/**
	 * ...
	 * @author Zachary Dremann
	 */
	public class ClothesMachineItemRenderer extends LabelItemRenderer 
	{
		private var _status:int;
		protected var statusDisplay:StyleableTextField;
		public function get status():int { return _status; }
		public function set status(value:int):void
		{
			if (value == _status)
				return;
			
			_status = value;
			
			if (statusDisplay)
			{
				statusDisplay.text = ClothesMachine.statusToString(_status);
				invalidateSize();
			}
		}
		
		private var _timeRemaining:int;
		protected var timeRemainingDisplay:StyleableTextField;
		public function get timeRemaining():int { return _timeRemaining; }
		public function set timeRemaining(value:int):void
		{
			if (value == _timeRemaining)
				return;
			
			_timeRemaining = value;
			
			if (timeRemainingDisplay)
			{
				timeRemainingDisplay.text = 
					(_timeRemaining<1)?"":_timeRemaining.toString() + " Min";
				invalidateSize();
			}
		}
		
		public function ClothesMachineItemRenderer() 
		{
			super();
			//Set Styles
			
			this.minHeight = 0;
		}
		
		public var paddingTop:Number	= 25;
		public var paddingBottom:Number	= 25;
		public var paddingLeft:Number	= 30;
		public var paddingRight:Number	= 30;
		public var paddingInner:Number 	= 5;
		
		private var isHeading:Boolean = false;
		
		override public function set data(value:Object):void 
		{
			super.data = value;
			
			if (!data)
				return;
			
			var number:int = data.number as int;
			var status:int = data.status as int;
			var timeRemaining:int = data.timeRemaining as int;
			
			if (data.hasOwnProperty("header") && data.header == true)
			{
				isHeading = true;
				this.status = -2;
				this.timeRemaining = -1;
				labelDisplay.setStyle("color", "0x000000");
				labelDisplay.setStyle("fontSize", 30);
				label = data.label;
				return;
			}
			else
			{
				isHeading = false;
				this.status = status;
				this.timeRemaining = timeRemaining;
				labelDisplay.setStyle("color", "0x000000");
				labelDisplay.setStyle("fontSize", 25);
				label = number.toString();
			}
			
		}
		override protected function createLabelDisplay():void 
		{
			super.createLabelDisplay();
			
			statusDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			statusDisplay.styleName = this;
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
			
			labelDisplay.setStyle("fontWeight", "bold");
			statusDisplay.setStyle("textAlign", "center");
			statusDisplay.setStyle("fontSize", 20);
			timeRemainingDisplay.setStyle("textAlign", "right");
			timeRemainingDisplay.setStyle("fontSize", 20);
			
		}
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			if (!labelDisplay || !statusDisplay || !timeRemainingDisplay)
				return;
			
			var viewWidth:Number = unscaledWidth - paddingLeft - paddingRight;
			var viewHeight:Number = unscaledHeight - paddingTop - paddingBottom;
			
			const labelPercent:Number = 1 / 11;
			const statusPercent:Number = 7 / 11;
			const timeRemainingPercent:Number = 3 / 11;
			
			var labelWidth:Number = 0;
			var labelHeight:Number = 0;
			
			if (label != "")
			{
				labelDisplay.commitStyles();
				
				if (labelDisplay.isTruncated)
					labelDisplay.text = label;
				
				labelHeight = getElementPreferredHeight(labelDisplay);
			}
			
			var labelY:Number = (viewHeight - labelHeight) + paddingTop;
			
			if (this.isHeading)
			{
				labelWidth = viewWidth;
				labelHeight = viewHeight;
				setElementSize(labelDisplay, labelWidth, labelHeight);
				setElementPosition(labelDisplay, paddingLeft, labelY);
				
				setElementSize(statusDisplay, 0, 0);
				setElementPosition(statusDisplay, 0, 0);
				statusDisplay.visible = false;
				
				setElementSize(timeRemainingDisplay, 0, 0);
				setElementPosition(timeRemainingDisplay, 0, 0);
				timeRemainingDisplay.visible = false;
				
				return;
			}
			else
			{
				labelWidth = Math.floor(Math.max(viewWidth * labelPercent - paddingInner, 0));
				statusDisplay.visible = true;
				timeRemainingDisplay.visible = true;
			}
			
			setElementSize(labelDisplay, labelWidth, labelHeight);
			
			setElementPosition(labelDisplay, paddingLeft, labelY);
			labelDisplay.truncateToFit();
			
			var statusWidth:Number = Math.floor(Math.max(statusPercent * viewWidth-paddingInner, 0));
			var statusHeight:Number = 0;
			if (status != -1)
			{
				statusDisplay.commitStyles();
				
				if (statusDisplay.isTruncated)
					statusDisplay.text = ClothesMachine.statusToString(status);
				
				statusHeight = getElementPreferredHeight(statusDisplay);
			}
			
			setElementSize(statusDisplay, statusWidth, statusHeight);
			
			var statusY:Number = (viewHeight -statusHeight) + paddingTop;
			setElementPosition(statusDisplay, paddingLeft + labelWidth + 2*paddingInner, statusY);
			statusDisplay.truncateToFit();
			
			var timeRemainingWidth:Number = Math.floor(Math.max(timeRemainingPercent * viewWidth-paddingInner, 0));
			var timeRemainingHeight:Number = 0;
			if (timeRemaining != -1)
			{
				timeRemainingDisplay.commitStyles();
				
				if (timeRemainingDisplay.isTruncated)
					timeRemainingDisplay.text = timeRemaining.toString();
				
				timeRemainingHeight = getElementPreferredHeight(timeRemainingDisplay);
			}
			
			setElementSize(timeRemainingDisplay, timeRemainingWidth, timeRemainingHeight);
			
			var timeRemainingY:Number = (viewHeight -timeRemainingHeight) + paddingTop;
			setElementPosition(timeRemainingDisplay, paddingLeft + labelWidth + statusWidth + 4*paddingInner, timeRemainingY);
			timeRemainingDisplay.truncateToFit();
			
		}
		override protected function measure():void
		{
			super.measure();
			
			if (statusDisplay && timeRemainingDisplay)
			{
				if (statusDisplay.isTruncated)
					statusDisplay.text = ClothesMachine.statusToString(status);
				if (timeRemainingDisplay.isTruncated)
					timeRemainingDisplay.text =
						(timeRemaining < 1)?"":timeRemaining.toString()+ " Min";
				
				var horizontalPadding:Number = paddingLeft + paddingRight;
				var verticalPadding:Number = paddingTop + paddingBottom;
				
				statusDisplay.commitStyles();
				timeRemainingDisplay.commitStyles();
				measuredWidth =
					horizontalPadding + getElementPreferredWidth(labelDisplay)
					+ getElementPreferredWidth(statusDisplay)
					+ getElementPreferredWidth(timeRemainingDisplay) + 4 * paddingInner;
				
				measuredHeight = Math.max(
					getElementPreferredHeight(labelDisplay) + verticalPadding,
					getElementPreferredHeight(statusDisplay) + verticalPadding,
					getElementPreferredHeight(timeRemainingDisplay) + verticalPadding);
			}
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			//super.drawBackground(unscaledWidth, unscaledHeight);
			
			var backgroundColors:Array = [0xffffff, 0xffffff];
			var downColor:* = getStyle("downColor");
			var selectionColor:* = getStyle("selectionColor");
			
			if (isHeading)
			{
				var colors:Array = [0x8E949D, 0xd3d5dE];
				var alphas:Array = [1, 1];
				var ratios:Array = [0, 255];
				var matrix:Matrix = new Matrix();
				
				matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
				graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
				//graphics.drawRoundRectComplex(0, 0, unscaledWidth, unscaledHeight, Math.min(paddingTop, paddingLeft)-5, Math.min(paddingTop, paddingLeft)-5, 0, 0);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			else
			{
				if (down)
				{
					
					if (status == ClothesMachine.CYCLE_COMPLETE)
						backgroundColors = [scaleColor(0x9C2800), 0x9C2800];
					else if (status == ClothesMachine.AVAILABLE)
						backgroundColors = [scaleColor(0x04650c), 0x04650c];
					else if(status == ClothesMachine.IN_USE)
						backgroundColors = [scaleColor(0xac0505), 0xac0505];
					else// if (status == ClothesMachine.UNAVAILABLE)
						backgroundColors = [scaleColor(0x444444), 0x444444];
				}
				else if (selected)
				{
					if(status == ClothesMachine.IN_USE)
						backgroundColors = [scaleColor(0x8c0505), 0x8c0505];
					else if (status == ClothesMachine.CYCLE_COMPLETE)
						backgroundColors = [scaleColor(0x7C0800), 0x7C0800];
					else if (status == ClothesMachine.AVAILABLE)
						backgroundColors = [scaleColor(0x044500), 0x044500];
					else// if (status == ClothesMachine.UNAVAILABLE)
						backgroundColors = [scaleColor(0x333333), 0x333333];
				}
				else
				{
					if(status == ClothesMachine.IN_USE)
						backgroundColors = [scaleColor(0xcc2525), 0xcc2525];
					else if (status == ClothesMachine.CYCLE_COMPLETE)
						backgroundColors = [scaleColor(0xbC480A), 0xbC480A];
					else if (status == ClothesMachine.AVAILABLE)
						backgroundColors = [scaleColor(0x24850c), 0x24850c];
					else// if (status == ClothesMachine.UNAVAILABLE)
						backgroundColors = [scaleColor(0x666666), 0x666666];
				}
				
				var matrix2:Matrix = new Matrix();
				matrix2.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2);
				graphics.beginGradientFill(GradientType.LINEAR, backgroundColors, [1, 1], [0, 255], matrix2);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			}
		}
		private function scaleColor(color:uint, scale:Number=.25):uint
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