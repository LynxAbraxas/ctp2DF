import shutil

try:
    import org.sikuli.script.SikulixForJython
    from sikuli import *
except ImportError:
    print("No run by sikuli jython")

fn= inspect.getsourcefile(lambda:0)
path= os.path.dirname(os.path.abspath(fn))
bsfn= os.path.splitext(os.path.basename(fn))[0]
addImagePath(path)

def main():
    leaderName= "Leemur"
    wait("ctp2start-scr.png", 100)
    click("ctp2new-game-btn.png")
    wait("ctp2launch-btn.png", 100) # wait until load game window is visible
    while not exists(Pattern("ctp2empty-leader-name-field.png").similar(0.90), 0.01):
        type(Key.BACKSPACE) # hit backspace until name-field is empty
    type(leaderName)
    click("ctp2launch-btn.png")
    if exists("ctp2ctr-bar.png", 100):
        if waitVanish("ctp2progress-bar.png", 100): # control bar appears before progressbar vanishes
            file = capture(SCREEN.getBounds())
            if file:
                f= Finder(file) # http://doc.sikuli.org/finder.html
                f.find("ctp2ctr-bar.png")
                if not f.hasNext():
                    print("Pattern not found in screen shot: " + file)
                    exit(30)
                shutil.move(file, bsfn + '.png')
                exit(0)
        else:
            exit(20)
    else:
        exit(10)
    exit(99)

if __name__ == "__main__":
    main()
