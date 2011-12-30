package net.zdremann.zsudsmobile;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import android.app.AlarmManager;
import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.util.Log;
import android.util.Xml;

public class CheckMachineAvailableService extends IntentService {
	public CheckMachineAvailableService(){
		super ("MachineCheckService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		final int machineNum = intent.getIntExtra("machineNum", -1);
		final int roomId = intent.getIntExtra("roomId", -1);
		
		InputStream is = null;
		DataInputStream dis;
		String xml = "";
		String urlString = "http://stevenson.esuds.net/RoomStatus/machineStatus.i?bottomLocationId="+roomId;
		try
		{
			final URL url = new URL(urlString);
			is = url.openStream();
			dis = new DataInputStream(new BufferedInputStream(is));
			
			String nextLine = "";
			do
			{
				xml += nextLine;
				nextLine = dis.readLine();
			}
			while(nextLine!= null);
			
			xml = xml.replace("xmlns=\"http://www.w3.org/1999/xhtml\"", "");
			xml = xml.replace("&nbsp;","BLECK");
			xml = xml.replace('#', 'f');
			xml = xml.replaceAll("<script.*/script>", "");
			
			MyMachineContentHandler handler = new MyMachineContentHandler();
			Xml.parse(xml, handler);
			
			Machine machine = handler.getMachineAt(machineNum);
			if(machine==null)
			{
				throw new Error("No Machine with that number");
			}
			else
			{
				if(machine.status.toString().toLowerCase().equals("available"))
				{
					final NotificationManager notifMan = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
					CharSequence tickerText = "Machine "+ machineNum + " Available";
					long when = System.currentTimeMillis();

					Notification notification = new Notification(R.drawable.ic_stat_notify_general, tickerText, when);
					
					CharSequence contentTitle = "Machine Available:";
					CharSequence contentText = "Machine Number " + machineNum + " is available";
					Intent notificationIntent = new Intent();
					PendingIntent contentIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
					
					notification.setLatestEventInfo(getApplicationContext(), contentTitle, contentText, contentIntent);
					notification.flags |= Notification.FLAG_AUTO_CANCEL;
					final int NOTIF_ID = Integer.parseInt(roomId+""+machineNum);
					notifMan.notify(NOTIF_ID,notification);
					stopSelf();
				}
				else
				{
					long additionalTime;
					if(machine.timeRemaining>0)
						additionalTime = machine.timeRemaining * 60000;
					else
						additionalTime = 5 * 60000;
					AlarmManager am = (AlarmManager)getSystemService(ALARM_SERVICE);
					Intent machineIntent = new Intent(this, CheckMachineAvailableService.class);
					machineIntent.putExtra("machineNum", machineNum);
					machineIntent.putExtra("roomId", roomId);
					PendingIntent operation = PendingIntent.getService(getApplicationContext(), 0, machineIntent, 0);
					
					// Convert the number of minutes left into milliseconds, then add to the current time
					final long alarmTime = System.currentTimeMillis() + additionalTime;
					am.set(AlarmManager.RTC_WAKEUP, alarmTime, operation);
				}
			}
		}
		catch(Exception e)
		{
			Log.e("Error", e.getMessage());
		}
		/*
		catch(MalformedURLException mue)
		{
			mue.printStackTrace();
		}
		catch(IOException ioe)
		{
			ioe.printStackTrace();
		}
		catch(SAXException sae)
		{
			
		}
		*/
		finally
		{
			try {
				is.close();
			}
			catch (IOException ioe)
			{
				// Ignore
			}
		}
	}

}
