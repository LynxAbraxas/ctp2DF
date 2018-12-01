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
    spriteFName= "GG100"
    wait("ctp2start-scr.png", 100) # still works with sprite button shown
    click("ctp2sprite-test-btn.png")
    wait(10) # progress bar does not appear at once
    if waitVanish(Pattern("ctp2progress-bar.png").similar(0.95), 100): # wait until progressbar vanishes
        wait(10) # some more time
        click(Pattern("ctp2sprite-sprite-name-field.png").similar(0.95).targetOffset(0, -10), 100) # text field needs click to get focus
        Settings.TypeDelay = 0.1; # ctp2-SDL needs some more time
        type(spriteFName + '.txt') # import from TXT and image series
        click("ctp2sprite-load-btn.png")
        wait(10)
        click(Pattern("ctp2sprite-sprite-name-field.png").similar(0.7).targetOffset(0, -10), 100) # text field needs click to get focus
        hover(getLastMatch().getTarget().offset(0, -100)) # move mouse out of the text field for later matching
        count= 0
        while not exists(Pattern("ctp2sprite-sprite-name-field.png").similar(0.95), 0.01) and count < 100: # high similarity to ensure empty text field
            type(Key.BACKSPACE) # hit backspace until name-field is empty
            count= count + 1
        type(spriteFName + '.spr') # save to SPR
        click("ctp2sprite-save-btn.png")
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
