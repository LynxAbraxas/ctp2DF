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
    if exists("ctp2start-scr.png", 100):
        file = capture(SCREEN.getBounds())
        if file:
            f= Finder(file) # http://doc.sikuli.org/finder.html
            f.find("ctp2start-scr.png")
            if not f.hasNext():
                print("Pattern not found in screen shot: " + file)
                exit(30)
            shutil.move(file, 'ctp2start.png')
            exit(0)
    else:
        exit(10)
    exit(99)

if __name__ == "__main__":
    main()
