package net.zdremann.zsudsmobile.model;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Vector;

import net.zdremann.zsudsmobile.MyMachineContentHandler;
import net.zdremann.zsudsmobile.model.vo.Machine;
import net.zdremann.zsudsmobile.model.vo.MachineType;

import org.xml.sax.SAXException;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;
import android.util.Xml;

public class RemoteMachineListProxy implements IMachineListProxy
{
	private static final String BASE_URL = "http://stevenson.esuds.net/RoomStatus/machineStatus.i?bottomLocationId=";
	private final Context context;
	private final Vector<Machine> _machineList; 
	
	public RemoteMachineListProxy(Context context)
	{
		_machineList = new Vector<Machine>(10,5);
		this.context = context;
	}
	
	@Override
	public void load(final int room) throws IOException
	{
		ConnectivityManager cm = (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
		Boolean connectedNetwork = false;
		for(NetworkInfo info : cm.getAllNetworkInfo())
		{
			if(info.getState()==NetworkInfo.State.CONNECTED || info.getState()==NetworkInfo.State.CONNECTING)
			{
				connectedNetwork = true;
				break;
			}
		}
		if(!connectedNetwork)
		{
			_machineList.clear();
			IOException e = new IOException("Not Connected to Internet");
			throw(e);
		}
		
		final String urlString = BASE_URL + room;
		final URL url;
		InputStream is = null;
		final DataInputStream dis;
		
		String xml = "";
		try
		{
			url = new URL(urlString);
			is = url.openStream();
			dis = new DataInputStream(new BufferedInputStream(is));
			
			
			String nextLine = "";
			do
			{
				xml += nextLine;
				nextLine = dis.readLine();
			}
			while(nextLine != null);
		}
		catch(MalformedURLException mue)
		{
			mue.printStackTrace();
		}
		catch(IOException ioe)
		{
			ioe.printStackTrace();
		}
		catch(Exception e)
		{
			Log.e("Error", e.getMessage());
			xml = "<bob></bob>";
		}
		finally
		{
			try
			{
				is.close();
			}
			catch(Exception e)
			{
				
			}
		}
		// After xml is downloaded, parse
		xml = xml.replace("xmlns=\"http://www.w3.org/1999/xhtml\"", "");
		xml = xml.replace("&nbsp;","BLECK");
		xml = xml.replace('#', 'f');
		xml = xml.replaceAll("<script.*/script>", "");
		
		MyMachineContentHandler handler = new MyMachineContentHandler();
		try
		{
			Xml.parse(xml, handler);
			_machineList.clear();
			_machineList.addAll(handler.getMachines());
			handler = null;
		}
		catch(SAXException sae)
		{
			_machineList.clear();
		}
		
	}
	
	@Override
	public Vector<Machine> getList()
	{
		return _machineList;
	}

	@Override
	public Machine getMachine(final int machineNum)
	{
		for(Machine cur : _machineList)
		{
			if(cur.num == machineNum)
				return cur;
		}
		// If no machines match:
		return null;
	}

	@Override
	public Vector<Machine> getListOfType(MachineType type) {
		Vector<Machine> returnList = new Vector<Machine>();
		for(Machine machine : _machineList)
		{
			if(machine.type.equals(type))
			{
				returnList.add(machine);
			}
		}
		return returnList;
	}

}
