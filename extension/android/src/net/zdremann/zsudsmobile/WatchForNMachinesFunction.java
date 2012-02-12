package net.zdremann.zsudsmobile;

import net.zdremann.zsudsmobile.model.vo.MachineType;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class WatchForNMachinesFunction implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] passedArgs) {
		if(passedArgs == null || passedArgs.length < 3)
		{
			Log.e("Watch for N machines", "Argument Error: expected roomId, type, and numOfMachines");
		}
		try
		{
			final int roomId = passedArgs[0].getAsInt();
			final MachineType type = (passedArgs[1].getAsString().toLowerCase().contains("washer"))?(MachineType.WASHER):(MachineType.DRYER);
			final int numOfMachines = passedArgs[2].getAsInt();
			Context appContext = context.getActivity().getApplicationContext();
			Intent intent = new Intent(appContext, CheckMultiMachineAvailableService.class);
			intent.putExtra("roomId", roomId);
			intent.putExtra("type", type.toString());
			intent.putExtra("numOfMachines", numOfMachines);
			context.getActivity().startService(intent);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return null;
	}

}
