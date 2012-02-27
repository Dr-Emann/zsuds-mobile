package net.zdremann.zsudsmobile;

import java.util.Vector;



import net.zdremann.zsudsmobile.model.vo.Machine;
import net.zdremann.zsudsmobile.model.vo.MachineStatus;
import net.zdremann.zsudsmobile.model.vo.MachineType;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;



public class MyMachineContentHandler extends DefaultHandler {
	private Boolean _lastClassName;
	private boolean _inRow;
	private int _col;
	private String lastContent;
	private Vector<Machine> machines;

	/**
	 * Calling when we're within an element. Here we're checking to see if there
	 * is any content in the tags that we're interested in and populating it in
	 * the Config object.
	 * 
	 * @param ch
	 * @param start
	 * @param length
	 */
	@Override
	public void characters(char ch[], int start, int length)
			throws SAXException {
		super.characters(ch, start, length);
		String chars = new String(ch, start, length);
		chars = chars.trim();
		lastContent = chars;
	}

	/**
	 * Called at the end of the element. Setting the booleans to false, so we
	 * know that we've just left that tag.
	 * 
	 * @param namespaceURI
	 * @param localName
	 * @param qName
	 * @throws SAXException
	 */
	@Override
	public void endElement(String namespaceURI, String localName, String qName)
			throws SAXException {
		super.endElement(namespaceURI, localName, qName);
		if (_inRow) {
			if (localName.equals("tr")) {
				_inRow = false;
				lastContent = "";
				return;
			}
			if(_lastClassName)
			{
				final Machine machine = machines.lastElement();
				// Log.i("Col: "+_col+" , "+((_lastClassName)?"true":"false"),
				// lastContent);
				if (localName.equals("td")) {
					
					switch (_col) {
					case 0:
						if (!lastContent.equals("BLECK"))
						{
							try
							{
								machine.id = Integer.parseInt(lastContent);
							}
							catch(NumberFormatException e)
							{
								machine.id = 0;
							}
						}
						break;
					case 1:
						try{
							machine.num = Integer.parseInt(lastContent);
						}
						catch(NumberFormatException e)
						{
							machine.num = 0;
						}
						break;
					case 2:
						if(lastContent.toLowerCase().contains("washer"))
							machine.type = MachineType.WASHER;
						else if(lastContent.toLowerCase().contains("dryer"))
							machine.type = MachineType.DRYER;
						else
							machine.type = MachineType.UNKNOWN;
					case 4:
						if (!lastContent.equals("BLECK"))
						{
							try{
								machine.timeRemaining = Integer.parseInt(lastContent);
							}
							catch (NumberFormatException e)
							{
								machine.timeRemaining = 0;
							}
						}
						else
							machine.timeRemaining = 0;
						break;
					default:
						lastContent = "";
						break;
					}
					_col++;
				} else if (localName.equals("font")) {
					if(lastContent.equalsIgnoreCase("available"))
						machine.status = MachineStatus.AVAILABLE;
					else if (lastContent.equalsIgnoreCase("cycle complete"))
						machine.status = MachineStatus.CYCLE_COMPLETE;
					else if (lastContent.equalsIgnoreCase("in use"))
						machine.status = MachineStatus.IN_USE;
					else if (lastContent.equalsIgnoreCase("unavailable"))
						machine.status = MachineStatus.UNAVAILABLE;
					else
						machine.status = MachineStatus.UNKNOWN;
				}
			}
		}
	}

	public Machine getMachineAt(int machineNum) {
		for (final Machine curr : machines) {
			if (curr.num == machineNum)
				return curr;
		}
		// If no machines have the chosen number
		return null;
	}
	public Vector<Machine> getMachines()
	{
		return machines;
	}

	@Override
	public void startDocument() throws SAXException {
		super.startDocument();
		machines = new Vector<Machine>(10, 5);
		lastContent = "";
		_col = 0;
	}

	@Override
	public void startElement(String namespaceURI, String localName,
			String qName, Attributes atts) throws SAXException {
		super.startElement(namespaceURI, localName, qName, atts);

		if (localName.equals("tr")) {
			final String name = atts.getValue("class");
			if (name != null)
				_lastClassName = (name.contains("even") || name.contains("odd"));
			else
				_lastClassName = false;
			_inRow = true;
			_col = 0;
			if(_lastClassName)
				machines.add(new Machine());
		}
	}
}
