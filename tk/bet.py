import customtkinter 
from tkinter import *
from tkinter import filedialog, StringVar
import json

def button_callback():
    print("button clicked")

#write input to terminal
def save_config():
    usr = entry.get()
    print(usr)

    
def select_dir():
    directory = filedialog.askdirectory()  # Open a dialog to select a directory
    if directory:
        libchoice.config(text=directory) 

# Dropdown menu options 
options = [ 
    "x86", 
    "ARM", 
    "MIPS", 
    "PowerPc", 
    "x64"
]


# build tools
build_tools = [ 
    "Build Tools", 
    "Emualtion", 
    "Both"
]

# libc choice
libc_build = [ 
    "glibc", 
    "musl", 
    "uclibc"
]

app = customtkinter.CTk()
app.geometry("400x450")

##ARCHITECTURE SELECTION
building = Label(app, text="Select build tools ")
building.pack(pady=5)


# Create Dropdown menu 
# initial menu text 
# datatype of menu text 
click_tools = StringVar() 
click_tools.set("") 
build = OptionMenu( app , click_tools , *build_tools ) 
build.pack() 

##ARCHITECTURE SELECTION
library = Label(app, text="Choose your libc")
library.pack(pady=5)


# Create Dropdown menu 
# initial menu text 
# datatype of menu text 
click_lib = StringVar() 
click_lib.set("") 
build_lib = OptionMenu( app , click_lib , *libc_build ) 
build_lib.pack() 

##ARCHITECTURE SELECTION
prefix = Label(app, text="Enter container prefix")
prefix.pack(pady=5)

entry = customtkinter.CTkEntry(app, placeholder_text="Enter here")
entry.pack(padx=20, pady=20)


##ARCHITECTURE SELECTION
arch_label = Label(app, text="Select your required architecture")
arch_label.pack(pady=5)


# Create Dropdown menu 
# initial menu text 
# datatype of menu text 
clicked = StringVar() 
clicked.set("") 
arch = OptionMenu( app , clicked , *options ) 
arch.pack() 


#select directory
button = customtkinter.CTkButton(app, text="select directory", command=select_dir)
button.pack(padx=20, pady=20)

libchoice = Label(app, text="No directory selected", wraplength=400, justify="left")
libchoice.pack(pady=5)


##BUTTON location styling
buttons_frame = customtkinter.CTkFrame(app)
buttons_frame.pack(pady=20)

#save configc buton
button = customtkinter.CTkButton(buttons_frame, text="load config", command=save_config)
button.pack(side=customtkinter.RIGHT,padx=20, pady=20)

#load config buton
button = customtkinter.CTkButton(buttons_frame, text="save config", command=submit)
button.pack(side=customtkinter.RIGHT,padx=20, pady=20)



app.mainloop()