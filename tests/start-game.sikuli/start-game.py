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
        print("Saved screen as "+file)
        shutil.move(file, 'ctp2start.png')
        exit(0)
    else:
        exit(10)

if __name__ == "__main__":
    main()
