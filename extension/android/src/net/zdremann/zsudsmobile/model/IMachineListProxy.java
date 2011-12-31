package net.zdremann.zsudsmobile.model;

import java.io.IOException;
import java.util.Vector;

import net.zdremann.zsudsmobile.model.vo.Machine;

public interface IMachineListProxy
{
	public void load(final int room) throws IOException;
	public Vector<Machine> getList();
	public Machine getMachine(final int machineNum);
}
