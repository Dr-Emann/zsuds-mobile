package net.zdremann.zsudsmobile;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class OneMachineWatcherFunction implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] passedArgs) {
		FREObject result = null;
		try
		{
			if(passedArgs == null || passedArgs.length < 2)
			{
				Log.e("Machine Watcher", "Did not pass enough arguments. Wanted: roomId and washerNum");
				return null;
			}
			final int roomId = passedArgs[0].getAsInt();
			final int machineNum = passedArgs[1].getAsInt();
			Context appContext = context.getActivity().getApplicationContext();
			Intent intent = new Intent(appContext, CheckMachineAvailableService.class);
			intent.putExtra("machineNum", machineNum);
			intent.putExtra("roomId", roomId);
			context.getActivity().startService(intent);
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		return result;
	}

}
