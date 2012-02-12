package net.zdremann.zsudsmobile;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class NotifyExtension implements FREExtension {

	@Override
	public FREContext createContext(String contextType) {
		return new NotifyExtensionContext();
	}

	@Override
	public void dispose() {
		// TODO Auto-generated method stub

	}

	@Override
	public void initialize() {
		// TODO Auto-generated method stub

	}

}
