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
    usr1 = clicked.get()
    #usr2 = dir.get()
    with open("input.txt" , "w") as file:
        file.write(usr + "\n")
        file.write(usr1 + "\n")
        #file.write(usr2,'\n')
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


# Dropdown menu options 
options = [ 
    "x86", 
    "ARM", 
    "MIPS", 
    "PowerPc", 
    "x64"
]


#initialise gui window
window = Tk()
window.geometry("350x350")
window.title("DesertEMU"
)

##DIRECTORY SELECTION SECTION
reside_dir = Label(window, text="Select residing directory", wraplength=400, justify="left")
reside_dir.pack(pady=5)
dir = Button(window, text="Open Folder", command=select_dir)
dir.pack(pady=5)

libchoice = Label(window, text="No directory selected", wraplength=400, justify="left")
libchoice.pack(pady=5)





##ARCHITECTURE SELECTION
arch_label = Label(window, text="Select your required architecture")
arch_label.pack(pady=5)


# Create Dropdown menu 
# initial menu text 
# datatype of menu text 
clicked = StringVar() 
clicked.set("") 
arch = OptionMenu( window , clicked , *options ) 
arch.pack() 

#CONTAINER NAMING CONVENTIONS
con_name = Label(window, text="Whats the prefix names of the container", wraplength=400, justify="left")
con_name.pack(pady=5)
entry = Entry()
entry.pack(pady=5)


#upload buton
upload_button = Button(window, text="Upload config file", command=upload)
upload_button.pack(side=BOTTOM,pady=5)


##SUBMIT BUTTON SECTION
submit = Button(window, text="Create config file", command=save_input)
submit.pack(side=BOTTOM, pady=5) 


#persistence
window.mainloop()
