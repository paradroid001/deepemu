from tkinter import *
from tkinter import filedialog

#write input to terminal
def submit():
    usr = entry.get()
    print(usr)

#delete input from gui
def clear():
    entry.delete(0,END)

# write input from gui to a txt file
def save_input():
    usr = entry.get()
    with open("input.txt", "w") as file:
        file.write(usr)
    clear()

#recieve file upload from user
def upload():
    file = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
    if not file.endswith('.txt'):
        return
    print("selected:", file)

#initialise gui window
window = Tk()
window.geometry("250x250")
window.title("DesertEMU")

#upload buton
upload_button = Button(window, text="Upload", command=upload)
upload_button.pack(pady=5)

#entry field
entry = Entry()
entry.pack(pady=5)

#submit button
submit = Button(window, text="submit", command=save_input)
submit.pack(side=BOTTOM)


#persistence
window.mainloop()
