import customtkinter 
from tkinter import *
from tkinter import filedialog

def button_callback():
    print("button clicked")

#write input to terminal
def submit():
    usr = entry.get()
    print(usr)

#delete input from gui
def clear():
    entry.delete(0,END)
    
def select_dir():
    directory = filedialog.askdirectory()  # Open a dialog to select a directory
    if directory:
        libchoice.config(text=directory) 

app = customtkinter.CTk()
app.geometry("400x150")

entry = customtkinter.CTkEntry(app, placeholder_text="CTkEntry")
entry.pack(padx=20, pady=20)


#upload buton
button = customtkinter.CTkButton(app, text="CLEAR", command=clear)
button.pack(padx=20, pady=20)



app.mainloop()