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

def Click(pattern, delay= 1, timeout= None, modifiers= None):
    if not timeout:
        timeout= getAutoWaitTimeout()
    
    wait(pattern)
    if getLastMatch():
        hover(getLastMatch().getTarget())
        wait(delay)
        click(Mouse.at(), modifiers)
        wait(delay)
    else:
        exit(200)

def main():
    spriteFName= bsfn + ".txt"
    wait("ctp2start-scr.png", 100) # still works with sprite button shown
    Click("ctp2sprite-test-btn.png")
    wait(10) # progress bar does not appear at once
    if waitVanish(Pattern("ctp2progress-bar.png").similar(0.95), 100): # wait until progressbar vanishes
        wait(10) # some more time
        Click(Pattern("ctp2sprite-sprite-name-field.png").similar(0.95).targetOffset(0, -10)) # text field needs click to get focus
        Settings.TypeDelay = 0.1; # ctp2-SDL needs some more time
        type(spriteFName)
        Click("ctp2sprite-save-btn.png")
        wait(10)
        file = capture(SCREEN.getBounds())
        if file:
            shutil.move(file, bsfn + '.png')
            exit(0)
    else:
        exit(20)
    exit(99)

if __name__ == "__main__":
    main()
