package net.zdremann.zsudsmobile;

import java.io.IOException;

import net.zdremann.zsudsmobile.model.IMachineListProxy;
import net.zdremann.zsudsmobile.model.LocalTestMachineListProxy;
import net.zdremann.zsudsmobile.model.RemoteMachineListProxy;
import net.zdremann.zsudsmobile.model.vo.Machine;
import net.zdremann.zsudsmobile.model.vo.MachineStatus;
import android.app.AlarmManager;
import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.util.Log;

public class CheckMachineAvailableService extends IntentService {
	private static final int ONE_MIN = 60000;
	public CheckMachineAvailableService(){
		super ("MachineCheckService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		final AlarmManager am = (AlarmManager)getSystemService(ALARM_SERVICE);
		final NotificationManager notifMan = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

		final int machineNum = intent.getIntExtra("machineNum", -1);
		final int roomId = intent.getIntExtra("roomId", -1);

		IMachineListProxy machines = new LocalTestMachineListProxy();
		try
		{
			machines.load(roomId);
		}
		catch (IOException ioe)
		{
			Log.d("Connection","No Connection");
			final long triggerAtTime = System.currentTimeMillis() + 5 * ONE_MIN;
			final Intent machineIntent = new Intent(this, CheckMachineAvailableService.class);
			machineIntent.putExtra("machineNum", machineNum);
			machineIntent.putExtra("roomId", roomId);
			final PendingIntent operation = PendingIntent.getService(getApplicationContext(), 0, machineIntent, 0);
			am.set(AlarmManager.RTC_WAKEUP, triggerAtTime, operation);
		}

		final Machine machine = machines.getMachine(machineNum);
		if(machine==null)
		{
			am.cancel(PendingIntent.getService(getApplicationContext(), 0, new Intent(), 0));
		}
		else
		{
			Log.i("Status", machine.status.toString());
			if(machine.status.equals(MachineStatus.AVAILABLE))
			{
				final CharSequence tickerText = "Machine "+ machineNum + " Available";
				final long when = System.currentTimeMillis();

				Notification notification = new Notification(R.drawable.ic_stat_notify_general, tickerText, when);

				CharSequence contentTitle = "Machine Available:";
				CharSequence contentText = "Machine Number " + machineNum + " is available";
				Intent notificationIntent = new Intent();
				PendingIntent contentIntent = PendingIntent.getActivity(getApplicationContext(), 0, notificationIntent, 0);

				notification.setLatestEventInfo(getApplicationContext(), contentTitle, contentText, contentIntent);
				notification.flags |= Notification.FLAG_AUTO_CANCEL;
				notification.defaults = Notification.DEFAULT_ALL;
				final int NOTIF_ID = Integer.parseInt(roomId+""+machineNum);
				notifMan.notify(NOTIF_ID,notification);
			}
			else
			{
				final long additionalTime;
				if(machine.status.equals(MachineStatus.UNAVAILABLE))
					additionalTime = 600 * ONE_MIN;
				else if(machine.timeRemaining>0)
					additionalTime = machine.timeRemaining * ONE_MIN;
				else
					additionalTime = 3 * ONE_MIN;

				final Intent machineIntent = new Intent(this, CheckMachineAvailableService.class);
				machineIntent.putExtra("machineNum", machineNum);
				machineIntent.putExtra("roomId", roomId);
				final PendingIntent operation = PendingIntent.getService(getApplicationContext(), 0, machineIntent, 0);

				// Convert the number of minutes left into milliseconds, then add to the current time
				final long alarmTime = System.currentTimeMillis() + additionalTime;
				am.set(AlarmManager.RTC_WAKEUP, alarmTime, operation);
			}
		}
	}

}
