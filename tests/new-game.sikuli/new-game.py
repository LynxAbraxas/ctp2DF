wait("ctp2start-scr.png", 100)
click("ctp2new-game-btn.png")
click("ctp2launch-btn.png")
if exists("ctp2new_res.png"):
    exit(0)
else:
    exit(1)
