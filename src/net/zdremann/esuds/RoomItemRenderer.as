package net.zdremann.esuds 
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import spark.components.LabelItemRenderer;
	
	/**
	 * ...
	 * @author j
	 */
	public class RoomItemRenderer extends LabelItemRenderer 
	{
		public var isHeading:Boolean;
		public var isSubHeading:Boolean;
		
		override public function get data():Object 
		{
			return super.data;
		}
		
		override public function set data(value:Object):void 
		{
			if (value.header)
			{
				isHeading = true;
				isSubHeading = false;
				if (labelDisplay)
				{
					labelDisplay.setStyle("size", 23);
					labelDisplay.setStyle("fontWeight", "bold");
				}
			}
			else if (value.subHeader)
			{
				isSubHeading = true;
				isHeading = false;
				
				if (labelDisplay)
				{
					labelDisplay.setStyle("size", 21);
					labelDisplay.setStyle("fontWeight", "normal");
				}
			}
			else
			{
				isHeading = false;
				isSubHeading = false;
				if (labelDisplay)
				{
					labelDisplay.setStyle("size", 18);
					labelDisplay.setStyle("fontWeight", "normal");
				}
			}
			
			super.data = value;
		}
		
		public const paddingTop:int = 10;
		public const paddingLeft:int = 15;
		public const paddingRight:int = 15;
		public const paddingBottom:int = 10;
		
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			if (!labelDisplay)
				return;
			
			labelDisplay.commitStyles();
			if (isHeading || !data.hasHall)
			{	
				setElementSize(labelDisplay, unscaledWidth - paddingLeft - paddingRight, getElementPreferredHeight(labelDisplay));
				setElementPosition(labelDisplay, paddingLeft, unscaledHeight-getElementPreferredHeight(labelDisplay)-paddingBottom-paddingTop/2);
				
			}
			else if (isSubHeading)
			{
				setElementSize(labelDisplay, unscaledWidth - 2 * paddingLeft - paddingRight, getElementPreferredHeight(labelDisplay));
				setElementPosition(labelDisplay, 2 * paddingLeft, unscaledHeight - getElementPreferredHeight(labelDisplay) - paddingBottom - paddingTop / 2);
			}
			else
			{
				setElementSize(labelDisplay, unscaledWidth - 3 * paddingLeft - paddingRight, getElementPreferredHeight(labelDisplay));
				setElementPosition(labelDisplay, 3 * paddingLeft, unscaledHeight-getElementPreferredHeight(labelDisplay)-paddingBottom-paddingTop/2);
			}
			
			labelDisplay.truncateToFit();
		}
		
		override protected function measure():void 
		{
			super.measure();
			
			if (labelDisplay.isTruncated)
				labelDisplay.text = label;
				
			var horizontalPadding:Number = 0;
			var verticalPadding:Number = paddingTop + paddingBottom;
			
			if(data.hasHall)
			{
				horizontalPadding = 3 * paddingLeft + paddingRight;
			}
			else
			{
				horizontalPadding = paddingLeft + paddingRight;
			}
			
			labelDisplay.commitStyles();
			
			measuredWidth = horizontalPadding + getElementPreferredWidth(labelDisplay);
			measuredHeight = verticalPadding + getElementPreferredHeight(labelDisplay);
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			var backgroundColors:Array = [0xffffff, 0xffffff];
			var colors:Array = [0x8E949D, 0xd3d5dE];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix();
			if (isHeading)
			{
				matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
				graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
				graphics.drawRoundRectComplex(0, 0, unscaledWidth, unscaledHeight, Math.min(paddingTop, paddingLeft)-5, Math.min(paddingTop, paddingLeft)-5, 0, 0);
				//graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			else if (isSubHeading)
			{
				matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
				graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
				//graphics.drawRoundRectComplex(0, 0, unscaledWidth, unscaledHeight, Math.min(paddingTop, paddingLeft)-5, Math.min(paddingTop, paddingLeft)-5, 0, 0);
				graphics.drawRect(0, 1, unscaledWidth, unscaledHeight);
			}
			else
			{
				super.drawBackground(unscaledWidth, unscaledHeight);
			}
		}
		
	}

}