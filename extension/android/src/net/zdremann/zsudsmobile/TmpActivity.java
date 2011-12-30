package net.zdremann.zsudsmobile;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Bundle;

public class TmpActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		Intent intent = new Intent(getApplicationContext(),CheckMachineAvailableService.class);
		intent.putExtra("machineNum", 4);
		intent.putExtra("roomId", 1040368);
		PendingIntent operation = PendingIntent.getService(getApplicationContext(), 0, intent,0);
		AlarmManager am = (AlarmManager)getSystemService(ALARM_SERVICE);
		long time = System.currentTimeMillis() + 10000;
		am.set(AlarmManager.RTC, time, operation);
	}
}