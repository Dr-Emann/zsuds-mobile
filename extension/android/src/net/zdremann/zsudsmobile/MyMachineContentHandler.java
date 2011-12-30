package net.zdremann.zsudsmobile;

import java.util.Vector;

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
			final Machine machine = machines.lastElement();
			// Log.i("Col: "+_col+" , "+((_lastClassName)?"true":"false"),
			// lastContent);
			if (localName.equals("td") && _lastClassName) {

				switch (_col) {
				case 0:
					if (!lastContent.equals("BLECK"))
						machine.id = Integer.parseInt(lastContent);
					break;
				case 1:
					machine.num = Integer.parseInt(lastContent);
					break;
				case 3:
					machine.status = lastContent;
					break;
				case 4:
					if (!lastContent.equals("BLECK"))
						machine.timeRemaining = Integer.parseInt(lastContent);
					else
						machine.timeRemaining = 0;
					break;
				default:
					lastContent = "";
					break;
				}
				_col++;
			} else if (localName.equals("font")) {
				machine.status = lastContent;
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
			machines.add(new Machine());
		}
	}
}
