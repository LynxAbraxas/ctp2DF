import shutil

wait("ctp2start-scr.png", 100)
click("ctp2new-game-btn.png")
click("ctp2launch-btn.png")
if exists("ctp2new_res.png", 100):
    wait(5) # control bar appears before progressbar vanishes
    file = capture(SCREEN.getBounds())
    print("Saved screen as "+file)
    shutil.move(file, 'ctp2new-game.png')
    exit(0)
else:
    exit(10)
