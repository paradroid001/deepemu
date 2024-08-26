from tkinter import *

#write input to terminal
def submit():
    usr = entry.get()
    print(usr)

#write input from gui
def clear():
    entry.delete(0,END)



window = Tk()
window.geometry("150x150")
window.title("DesertEMU")
entry = Entry()
entry.pack()

submit = Button(window, text="submit", command=submit)
submit.pack(side=BOTTOM)

clear = Button(window, text="clear", command=clear)
clear.pack(side=BOTTOM)

window.mainloop()
