package net.zdremann.zsudsmobile.model.vo;

public class Machine {
	public Machine()
	{
		this.status = MachineStatus.UNKNOWN;
	}
	public Machine(int id, int num, MachineStatus status)
	{
		this.id = id;
		this.num = num;
		this.status = status;
	}
	public int id;
	public int num;
	public MachineStatus status;
	public MachineType type;
	public int timeRemaining;
	
	@Override
	public String toString()
	{
		return this.type + ": " +this.num + " "+this.status.toString()+ " " + timeRemaining;
	}
}
