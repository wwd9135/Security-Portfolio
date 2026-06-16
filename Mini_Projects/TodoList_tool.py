# Basic CLI to-do list tool created to practice Python fluency.
# Functional but not optimized; error handling and structure need improvement.
# Future plans include revisiting and adding advanced features.

# Initialize global (declared outside local func) loop variable as False, change when user inputs an integer to leave home page successfully.
UserBackout = False
Dictcount = 1
def Taking_input(Input = None): 
    if Input is not None:
        print(f"\033[1;91m{Input}\033[0m") # Prints out error message if Argument is filled during an try/except error catch.
    global UserBackout 
    Option = 0
    # Try to take integer input, catch error and inform user to keep the app alive without breaking it.
    try:
        Option = (int(input("Select one of the following options by entering the number eg.1/2/3/4\n1: Add tasks\n2: View tasks \n3: Remove tasks\n4: Save & exit\n")))
    except:
        Taking_input("Enter a number 1-4!!!")
    
    if Option != None:
        UserBackout = True
        return Option
    else:
        Taking_input()
def welcome():
    print("********************************************************\n Welcome to Todool, your personal planner and todo list app!\n ********************************************************")
    # Before the User has successfully inputted a value this will keep looping.
    while UserBackout == False:
        Option = Taking_input()
        if Option == 1:
            add()
        elif Option == 2:
            view_tasks()
        elif Option == 3:
            remove()
        
        elif Option == 4:
            Save_exit()
        else: 
            Save_exit()  #Ensures the users progress is saved. 
Dict_collection = [{"id":0,
                    "Contents": "",
                    "Status": ""}]
def add():
    global UserBackout
    UserBackout = False
    Dictcount = 0
    # Go to home page if exit not reached prior (To save or view contents.)
    try:
        contentsInput = input("Please enter a note contents eg. fry eggs- Crack open eggs, heat up the grill, fill pan with oil... etc")
        StatusInput = input("Please enter a status for this (either Done/In progress/ On hold)")
        Dictcount += 1
        dictInput = {"id": Dictcount,
                                "title": contentsInput,
                                "done": StatusInput}
        Dict_collection.append(dictInput)
        # add the functionality to get the 3 variables into one dict following the designated structure outlines in my commented notes at the top

    except Exception as e:
        print(e)
       # print("Error collecting new note info, please retry.")
        add()
        

    try: 
        UserInput = (int(input("\nEnter a number 1/2/3 for the following options:\n1: Save data and exit app\n2: Remove an entry\n3: View contents\n")))
        if UserInput == 1:
            Save_exit()
        elif UserInput == 2:
            remove()
        elif UserInput == 3:
            view_tasks()
    except:
        print(view_tasks)
        welcome()


# Set this up so it appends 
def remove():
    global UserBackout
    global Dict_collection
    UserBackout = False
    print(Dict_collection)
    Choice = int(input("Enter the number corresponding to the journal item you'd like to remove (Check from printed list above), enter -1 to skip this and not remove any"))
    if Choice == -1:
        return #Not sure if using pass works here, just need to skip to the else statement.
    else: 
        for listt in Dict_collection:
            try:
                if Choice == listt["id"]:
                    Dict_collection.remove(listt) # Not sure if the syntax is right here, it should work well, as the user has control over exactly which entry is removed. 
                    print(f"{listt}\n has been removed from the database as requested.")
                    print(f"The remaining contents of the list are as follows: {Dict_collection}")
                    break
                else:
                    print("no match")
            except Exception as e:
                print(f"{Choice} isn't in list.")
    try: 
        UserInput = (int(input("\nEnter a number 1/2/3 for the following options:\n1: Save data and exit app\n2: Add an entry\n3: View contents\n")))
        if UserInput == 1:
            Save_exit()
        elif UserInput == 2:
            add()
        elif UserInput == 3:
            view_tasks()
    except:
        print(view_tasks)
        welcome()
    

def Save_exit():
    global Dict_collection
    New = str(Dict_collection)
    with open(r"C:\Users\theri\Downloads\Testing\Output.txt", "a") as file:
        file.write(New)
    print(f"Successfully appended the following data to Output.txt:{Dict_collection}")

# Shows data from current session, gives option to save data or return to home page
def view_tasks():
    UserInput = 0
    global UserBackout

    # This will show whats saved from this session before user appends to permenant saved document. 
    global Dict_collection
    print(f"\nThis is the current list of tasks associated to your account:{Dict_collection}")
    try: 
        UserInput = (int(input("\nEnter a number 1/2/3 for the following options:\n1: Save data and exit app\n2: Add an entry\n3: Remove an entry\n")))
        if UserInput == 1:
            Save_exit()
        elif UserInput == 2:
            add()
        elif UserInput == 3:
            remove()
    except:
        print(view_tasks)
        welcome()

# Launch home page
welcome()
