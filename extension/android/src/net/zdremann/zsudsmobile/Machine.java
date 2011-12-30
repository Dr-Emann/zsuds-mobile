package net.zdremann.zsudsmobile;

public class Machine {
	public Machine()
	{
		
	}
	public Machine(int id, int num, CharSequence status)
	{
		this.id = id;
		this.num = num;
		this.status = status;
	}
	public int id;
	public int num;
	public CharSequence status;
	public int timeRemaining;
	
	@Override
	public String toString()
	{
		return this.num + " "+this.status+ " " + timeRemaining;
	}
}
