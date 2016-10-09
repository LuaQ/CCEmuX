package net.clgd.ccemux.rendering.swing

import dan200.computercraft.ComputerCraft
import dan200.computercraft.core.terminal.Terminal
import java.awt.Canvas
import java.awt.Dimension
import java.awt.Graphics
import java.awt.Point
import java.awt.image.BufferedImage
import javax.imageio.ImageIO
import net.clgd.ccemux.Utils
import net.clgd.ccemux.emulation.CCEmuX
import org.eclipse.xtend.lib.annotations.Accessors

package class TerminalComponent extends Canvas {
	static val CC_FONT_PATH = "/assets/computercraft/textures/gui/termFont.png"
	
	@Accessors(PUBLIC_GETTER) Terminal terminal
	@Accessors(PUBLIC_GETTER) int pixelWidth
	@Accessors(PUBLIC_GETTER) int pixelHeight
	
	@Accessors char cursorChar = '_'
	
	@Accessors boolean blinkLocked = false
	
	BufferedImage[] fontImages
	
	new(Terminal terminal, int pixelWidth, int pixelHeight) {	
		this.pixelWidth = pixelWidth
		this.pixelHeight = pixelHeight
		
		this.terminal = terminal
		
		fontImages = newArrayOfSize(16)
		
		val baseImage = ImageIO.read(ComputerCraft.getResource(CC_FONT_PATH))
		
		for (var i = 0; i < fontImages.length; i++) {
			fontImages.set(i, Utils.makeTintedCopy(baseImage, Utils.getCCColourFromInt(i)))
		}
	
		val termDimensions = new Dimension(terminal.width * pixelWidth, terminal.height * pixelHeight) 
		size = termDimensions
		preferredSize = termDimensions
	}

	@Pure
	private static def getCharLocation(char c, int charWidth, int charHeight, int fontWidth, int fontHeight) {
		val columns = fontWidth / charWidth
		val rows = fontHeight / charHeight
		
		val charCode = c as int
		
		return new Point(
			(charCode % columns) * charWidth,
			(charCode / rows) * charHeight
		)
	}
	
	private def drawChar(Graphics it, char c, int x, int y, int colour) {
		if (c as int == 0) {
			// Nothing to do here.
			return
		}
		
		// TODO: These are width & height of a character in the font bitmap.
		// Replace these with something non-magical.
		val charWidth = 6
		val charHeight = 9
		
		// TODO: Newer CC versions pad the font texture with empty space to make it POT.
		// Therefore, we need the actual space occupied by the texture.
		// Replace these with something non-magical.
		val fontWidth = 96
		val fontHeight = 144
		
		val charLocation = getCharLocation(
			c,
			charWidth, charHeight,
			fontWidth, fontHeight
		)
		
		drawImage(
			fontImages.get(colour),
			
			// Destination
			x, y,
			x + pixelWidth, y + pixelHeight,
			
			// Source
			charLocation.x, charLocation.y,
			charLocation.x + charWidth, charLocation.y + charHeight,
			
			null
		)
	}
	
	private def renderTerminal(float dt) {
		val g = bufferStrategy.drawGraphics
		
		for (var y = 0; y < terminal.height; y++) {
			val textLine = terminal.getLine(y)
			val bgLine = terminal.getBackgroundColourLine(y)
			val fgLine = terminal.getTextColourLine(y)
			
			for (var x = 0; x < terminal.width; x++) {
				g.color = Utils.getCCColourFromChar(bgLine.charAt(x))
				g.fillRect(x * pixelWidth, y * pixelHeight, pixelWidth, pixelHeight)
				
				val character = textLine.charAt(x)
				drawChar(g, character, x * pixelWidth, y * pixelHeight, Utils.base16ToInt(fgLine.charAt(x)))
			}
		}
		
		val blink = terminal.cursorBlink && (blinkLocked || CCEmuX.globalCursorBlink)
		
		if (blink) {
			drawChar(
				g, cursorChar,
				terminal.cursorX * pixelWidth, terminal.cursorY * pixelHeight,
				terminal.textColour
			)
		}
		
		g.dispose
	}
	
	def render(float dt) {
		if (bufferStrategy == null) {
			createBufferStrategy(2)
		}
		
		do {
			do {
				renderTerminal(dt)
			} while (bufferStrategy.contentsRestored)
		
			bufferStrategy.show
		} while (bufferStrategy.contentsLost)
	}
	
}