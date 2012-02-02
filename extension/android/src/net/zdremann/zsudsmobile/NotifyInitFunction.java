package net.zdremann.zsudsmobile;

import android.app.Activity;
import android.app.AlarmManager;
import android.content.Context;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class NotifyInitFunction implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] passedArgs) {
		final NotifyExtensionContext notifyContext = (NotifyExtensionContext)context;
		Activity activity = notifyContext.getActivity();
		notifyContext.am = (AlarmManager)activity.getSystemService(Context.ALARM_SERVICE);
		return null;
	}

}
