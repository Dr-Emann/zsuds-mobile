package net.zdremann.zsudsmobile;

import java.io.IOException;
import java.util.Vector;

import net.zdremann.zsudsmobile.model.IMachineListProxy;
import net.zdremann.zsudsmobile.model.LocalTestMachineListProxy;
import net.zdremann.zsudsmobile.model.RemoteMachineListProxy;
import net.zdremann.zsudsmobile.model.vo.Machine;
import net.zdremann.zsudsmobile.model.vo.MachineStatus;
import net.zdremann.zsudsmobile.model.vo.MachineType;
import android.app.AlarmManager;
import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.util.Log;

public class CheckMultiMachineAvailableService extends IntentService {
	private static final int ONE_MIN = 60000;
	private static final int NOTIF_ID = 3;
	
	public CheckMultiMachineAvailableService()
	{
		super("CheckMultiMachineAvailableService");
	}
	@Override
	protected void onHandleIntent(Intent intent) {
		final AlarmManager am = (AlarmManager)getSystemService(ALARM_SERVICE);
		final NotificationManager notifMan = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

		final int roomId = intent.getIntExtra("roomId", -1);
		final int numOfMachines = intent.getIntExtra("numOfMachines", 0);
		final MachineType type = (intent.getStringExtra("type").toLowerCase().contains("washer"))?MachineType.WASHER:MachineType.DRYER;
		IMachineListProxy machineProxy = new RemoteMachineListProxy(getApplicationContext());
		try
		{
			machineProxy.load(roomId);
		}
		catch (IOException ioe)
		{
			Log.d("Connection","No Connection");
			final long triggerAtTime = System.currentTimeMillis() + 5 * ONE_MIN;
			final Intent machineIntent = new Intent(this, CheckMachineAvailableService.class);
			machineIntent.putExtra("roomId", roomId);
			machineIntent.putExtra("type", type.toString());
			machineIntent.putExtra("numOfMachines", numOfMachines);
			final PendingIntent operation = PendingIntent.getService(getApplicationContext(), 0, machineIntent, 0);
			am.set(AlarmManager.RTC_WAKEUP, triggerAtTime, operation);
		}
		Vector<Machine> machineList = machineProxy.getListOfType(type);
		if(numOfMachines > machineList.size())
		{
			am.cancel(PendingIntent.getService(getApplicationContext(), 0, new Intent(), 0));
		}
		int currentlyAvailMachines = 0;
		int currentlyCCMachines = 0;
		Log.d("Machines", machineList.toString());
		for(Machine machine : machineList)
		{
			if(machine.status == (MachineStatus.AVAILABLE))
			{
				currentlyAvailMachines++;
			}
			else if (machine.status.equals(MachineStatus.CYCLE_COMPLETE))
			{
				currentlyCCMachines++;
			}
		}
		// After adding up all available machines, test if there are enough
		Log.v("Multi Machine Check","Found "+currentlyAvailMachines + " avaliable and " + currentlyCCMachines + " cycle complete" );
		if(currentlyAvailMachines<numOfMachines)
		{
			if(currentlyAvailMachines+currentlyCCMachines<numOfMachines)
			{
				final int inUseNeededMachines = numOfMachines-currentlyAvailMachines-currentlyCCMachines;
				Log.v("Multi Machine Check", "Available machines + cycle completes are inadequate, "+ inUseNeededMachines + " in use machines will be needed");
				
				// TODO: Add logic to check the Nth lowest machine in use
				final Intent machineIntent = new Intent(this, CheckMultiMachineAvailableService.class);
				machineIntent.putExtra("roomId", roomId);
				machineIntent.putExtra("type", type.toString());
				machineIntent.putExtra("numOfMachines", numOfMachines);
				final PendingIntent operation = PendingIntent.getService(getApplicationContext(), 0, machineIntent, 0);

				// Convert the number of minutes left into milliseconds, then add to the current time
				final long alarmTime = System.currentTimeMillis() + 3*ONE_MIN;
				am.set(AlarmManager.RTC_WAKEUP, alarmTime, operation);
			}
			else // Available machines + cycle completes are adequate
			{
				Log.v("Multi Machine Check", "Available machines + cycle completes are adequate");
				final Intent machineIntent = new Intent(this, CheckMultiMachineAvailableService.class);
				machineIntent.putExtra("roomId", roomId);
				machineIntent.putExtra("type", type.toString());
				machineIntent.putExtra("numOfMachines", numOfMachines);
				final PendingIntent operation = PendingIntent.getService(getApplicationContext(), 0, machineIntent, 0);

				// Convert the number of minutes left into milliseconds, then add to the current time
				final long alarmTime = System.currentTimeMillis() + 3*ONE_MIN;
				am.set(AlarmManager.RTC_WAKEUP, alarmTime, operation);
			}
		}
		else // Available machines are enough. WOO.
		{
			final CharSequence tickerText = "Machines are Available";
			final long when = System.currentTimeMillis();

			Notification notification = new Notification(R.drawable.ic_stat_notify_general, tickerText, when);

			CharSequence contentText = currentlyAvailMachines + " " + type.toString().toLowerCase() + "s are now available";
			CharSequence contentTitle = "Machines are available";
			Intent notificationIntent = new Intent();
			PendingIntent contentIntent = PendingIntent.getActivity(getApplicationContext(), 0, notificationIntent, 0);

			notification.setLatestEventInfo(getApplicationContext(), contentTitle, contentText, contentIntent);
			notification.flags |= Notification.FLAG_AUTO_CANCEL;
			notification.defaults = Notification.DEFAULT_ALL;
			notifMan.notify(NOTIF_ID,notification);
		}
	}

}
