package net.zdremann.zsudsmobile.model;

import java.util.Vector;

import android.util.Log;

import net.zdremann.zsudsmobile.model.vo.Machine;
import net.zdremann.zsudsmobile.model.vo.MachineStatus;
import net.zdremann.zsudsmobile.model.vo.MachineType;

public class LocalTestMachineListProxy implements IMachineListProxy
{
	final private Vector<Machine> _machineList = new Vector<Machine>(10, 10);
	@Override
	public void load(final int room)
	{
		_machineList.clear();
		Machine curr;
		final int arrlen = _machineList.capacity();
		for(int i=0;i<arrlen;i++)
		{
			curr = new Machine();
			curr.id = (int)(Math.random()*500);
			curr.num = i+1;
			Log.v("bitshift", (arrlen>>1)+"");
			curr.type = (i<(arrlen>>1))?MachineType.WASHER:MachineType.DRYER;
			int rand = (int)(Math.random()*3);
			switch(rand)
			{
			case 0:
				curr.status = MachineStatus.AVAILABLE;
				break;
			case 1:
				curr.status = MachineStatus.IN_USE;
				break;
			case 2:
				curr.status = MachineStatus.CYCLE_COMPLETE;
				break;
			default:
				curr.status = MachineStatus.CYCLE_COMPLETE;
			}
			if(curr.status.equals(MachineStatus.IN_USE))
				curr.timeRemaining = 1;
			_machineList.add(curr);
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
		for(Machine curr : _machineList)
		{
			if(curr.num == machineNum)
				return curr;
		}
		// If no machines are the correct number
		return null;
	}

	@Override
	public Vector<Machine> getListOfType(MachineType type) {
		Vector<Machine> returnList = new Vector<Machine>(_machineList.capacity());
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
