import customtkinter 
from tkinter import *
from tkinter import filedialog, StringVar
import json
import os

data_file_path = os.path.join(os.getcwd(), 'data.json')

#write input to terminal
def save_config():
    with open(data_file_path, "r") as jsonFile:
        data = json.load(jsonFile)

    data["Architecture"] = clicked.get()
    data["Build tools"] = click_tools.get()
    data["Directory"] = libchoice.cget("text")
    data["Container prefix"] = entry.get()
    data["libc"] = click_lib.get()


    with open(data_file_path, "w") as jsonFile:
        json.dump(data, jsonFile)

    confirm()
    
def load_config():
    jason = filedialog.askopenfile(filetypes=[("Json files", "*.json")])  # Open a dialog to select a directory
    if jason:
        data = json.load(jason)
        config_map = {
            'Architecture': clicked,
            'Build tools': click_tools,
            'libc': click_lib
        }

        for key, var in config_map.items():
            value = data.get(key,'')
            if value:
                var.set(value)

        directory = data.get("Directory", "")
        if directory:
            libchoice.config(text=directory)

        
        con_prefix = data.get("Container prefix", "")
        if con_prefix:
            entry.delete(0, END)  # Clear the entry first
            entry.insert(0, con_prefix)

        jason.close
    

    
def select_dir():
    directory = filedialog.askdirectory()  # Open a dialog to select a directory
    if directory:
        libchoice.configure(text=directory) 

def confirm():
    con_label = Label(app, text="Saved!", fg="green")
    con_label.pack()

    app.after(2000, con_label.destroy)

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
app.geometry("400x550")
app.configure(bg_color="#000000")

##ARCHITECTURE SELECTION
building = customtkinter.CTkLabel(app, text="Select build tools ", text_color=("black"), fg_color=("white"),corner_radius=8)
building.pack(pady=5)


# Create Dropdown menu submit
# initial menu text 
# datatype of menu text 
click_tools = StringVar() 
click_tools.set("") 
build = OptionMenu( app , click_tools , *build_tools ) 
build.pack() 

##ARCHITECTURE SELECTION
library = customtkinter.CTkLabel(app, text="Choose your libc", text_color="black", fg_color="white", corner_radius=8)
library.pack(pady=5)


# Create Dropdown menu 
# initial menu text 
# datatype of menu text 
click_lib = StringVar() 
click_lib.set("") 
build_lib = OptionMenu( app , click_lib , *libc_build ) 
build_lib.pack() 

##ARCHITECTURE SELECTION
prefix = customtkinter.CTkLabel(app, text="Enter container prefix",text_color="black", fg_color="white", corner_radius=8)
prefix.pack(pady=5)

entry = customtkinter.CTkEntry(app, placeholder_text="Enter here")
entry.pack(padx=20, pady=20)


##ARCHITECTURE SELECTION
arch_label = customtkinter.CTkLabel(app, text="Select your required architecture",text_color="black", fg_color="white", corner_radius=8)
prefix.pack(pady=5)
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

libchoice = customtkinter.CTkLabel(app, text="No directory selected", wraplength=400, justify="left")
libchoice.pack(pady=5)


##BUTTON location styling
buttons_frame = customtkinter.CTkFrame(app)
buttons_frame.pack(pady=20)

#load configc buton
button = customtkinter.CTkButton(buttons_frame, text="load config", command=load_config)
button.pack(side=customtkinter.RIGHT,padx=20, pady=20)

#load config buton

button = customtkinter.CTkButton(buttons_frame, text="save config", command=save_config)
button.pack(side=customtkinter.RIGHT,padx=20, pady=20)



app.mainloop()