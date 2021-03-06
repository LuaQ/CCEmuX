package net.clgd.ccemux;

import dan200.computercraft.shared.util.Colour;
import dan200.computercraft.core.terminal.Terminal;

import java.awt.*;
import java.awt.image.BufferedImage;

public class Utils {

	public static final String BASE_16 = "0123456789abcdef";

	public static int base16ToInt(char c) {
		return BASE_16.indexOf(String.valueOf(c).toLowerCase());
	}

	public static Color getCCColourFromInt(Terminal terminal, int i) {
		float[] col = terminal.getPalette().getColour(15 - i);
		return new Color(col[0], col[1], col[2]);
	}

	public static Color getCCColourFromChar(Terminal terminal, char c) {
		return getCCColourFromInt(terminal, base16ToInt(c));
	}

	public static BufferedImage makeTintedCopy(BufferedImage bi, Color tint) {
		GraphicsConfiguration gc = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice()
				.getDefaultConfiguration();

		BufferedImage tinted = gc.createCompatibleImage(bi.getWidth(), bi.getHeight(), Transparency.TRANSLUCENT);

		for (int y = 0; y < bi.getHeight(); y++) {
			for (int x = 0; x < bi.getWidth(); x++) {
				int rgb = bi.getRGB(x, y);

				if (rgb != 0)
					tinted.setRGB(x, y, tint.getRGB());
			}
		}

		return tinted;
	}
}
