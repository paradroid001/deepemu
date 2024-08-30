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
    if file:
        with open(file, 'r') as f:
            content = f.read()
        entry.delete(0, END)
        entry.insert(0, content.strip())
        print("selected:", file)

def select_dir():
    directory = filedialog.askdirectory()  # Open a dialog to select a directory
    if directory:
        libchoice.config(text=directory) 


#initialise gui window
window = Tk()
window.geometry("250x350")
window.title("DesertEMU")

#upload buton
upload_button = Button(window, text="Upload config file", command=upload)
upload_button.pack(pady=5)

#entry field
entry = Entry()
entry.pack(pady=5)

##ARCHITECTURE SELECTION
arch = Comb


##DIRECTORY SELECTION SECTION
dir = Button(window, text="Select dir", command=select_dir)
dir.pack(pady=5)

libchoice = Label(window, text="No directory selected", wraplength=400, justify="left")
libchoice.pack(pady=5)



##SUBMIT BUTTON SECTION
submit = Button(window, text="submit", command=save_input)
submit.pack(side=BOTTOM)


#persistence
window.mainloop()
