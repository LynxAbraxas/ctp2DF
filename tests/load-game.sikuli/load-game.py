import shutil

wait("ctp2start-scr.png", 100)
click("ctp2load-game-btn.png")
click("ctp2Julius-folder.png")
click("ctp2Julius-Roma-4000BC-file.png")
click("ctp2OK-btn.png")
if exists("ctp2ctr-bar.png", 100):
    waitVanish("ctp2progress-bar.png", 100) # control bar appears before progressbar vanishes
    file = capture(SCREEN.getBounds())
    print("Saved screen as "+file)
    shutil.move(file, 'ctp2load-game.png')
    exit(0)
else:
    exit(10)
