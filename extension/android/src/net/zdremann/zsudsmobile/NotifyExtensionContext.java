package net.zdremann.zsudsmobile;

import java.util.HashMap;
import java.util.Map;

import android.app.AlarmManager;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

public class NotifyExtensionContext extends FREContext {

	public AlarmManager am;
	@Override
	public void dispose() {
		// TODO Auto-generated method stub

	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String,FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("isSupported", new NotificationAvailableFunction());
		functionMap.put("initMe", new NotifyInitFunction());
		functionMap.put("watchForMachine", new OneMachineWatcherFunction());
		functionMap.put("watchForNMachines", new WatchForNMachinesFunction());
		//functionMap.put("cancelMe", new NotifyCancelFunction());
		return functionMap;
	}

}
