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
