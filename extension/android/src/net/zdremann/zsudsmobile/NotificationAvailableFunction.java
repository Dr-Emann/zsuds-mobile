package net.zdremann.zsudsmobile;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

public class NotificationAvailableFunction implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] passedArgs) {
		FREObject result = null;
		final NotifyExtensionContext notifyContext = (NotifyExtensionContext)context;
		try
		{
			if(notifyContext.am == null)
			{
				result = FREObject.newObject(false);
			}
			else
			{
				result = FREObject.newObject(true);
			}
		}
		catch (FREWrongThreadException fwte)
		{
			fwte.printStackTrace();
		}
		return result;
	}

}
