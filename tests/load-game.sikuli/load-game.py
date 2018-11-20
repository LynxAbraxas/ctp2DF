try:
    import org.sikuli.script.SikulixForJython
    from sikuli import *
    addImagePath(os.path.dirname(os.path.abspath(inspect.getsourcefile(lambda:0))))
except ImportError:
    print("No run by sikuli jython")

import shutil

def main():
    wait("ctp2start-scr.png", 100)
    click("ctp2load-game-btn.png")
    click("ctp2Julius-folder.png")
    click("ctp2Julius-Roma-file.png")
    click(Pattern("ctp2OK-btn.png").similar(0.99))
    if exists("ctp2ctr-bar.png", 100):
        if waitVanish("ctp2progress-bar.png", 100): # control bar appears before progressbar vanishes
            file = capture(SCREEN.getBounds())
            if file:
                f= Finder(file) # http://doc.sikuli.org/finder.html
                f.find("ctp2ctr-bar.png")
                if not f.hasNext():
                    print("Pattern not found in screen shot: " + file)
                    exit(30)
                shutil.move(file, 'ctp2load-game.png')
                exit(0)
        else:
            exit(20)
    else:
        exit(10)
    exit(99)

if __name__ == "__main__":
    main()
