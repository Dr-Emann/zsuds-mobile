package net.zdremann.zsudsmobile.model;

import java.io.IOException;
import java.util.Vector;

import net.zdremann.zsudsmobile.model.vo.Machine;
import net.zdremann.zsudsmobile.model.vo.MachineType;

public interface IMachineListProxy
{
	public void load(final int room) throws IOException;
	public Vector<Machine> getList();
	public Vector<Machine> getListOfType(MachineType type);
	public Machine getMachine(final int machineNum);
}
