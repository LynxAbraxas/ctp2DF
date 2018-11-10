try:
    import org.sikuli.script.SikulixForJython
    from sikuli.Sikuli import *
    import inspect
    import os.path
    addImagePath(os.path.dirname(os.path.abspath(inspect.getsourcefile(lambda:0))))
except ImportError:
    print("No run by sikuli jython")

import shutil

def main():
    m= wait("ctp2progress-bar.png", 100)
    waitVanish("ctp2progress-bar.png", 100)
    wait(10)
    click(m.getCenter())
    wait("ctp2start-scr.png", 100)
    click("ctp2new-game-btn.png")
    click("ctp2launch-btn.png")
    if exists("ctp2ctr-bar.png", 100):
        waitVanish("ctp2progress-bar.png", 100) # control bar appears before progressbar vanishes
        file = capture(SCREEN.getBounds())
        print("Saved screen as "+file)
        shutil.move(file, 'ctp2new-game.png')
        exit(0)
    else:
        exit(10)

if __name__ == "__main__":
    main()
