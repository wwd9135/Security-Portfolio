# This is a basic script from first year of univeristy, I created a GUI to practice web design/ UX skills.
# Create a virtual enviroment and add pywebio as an interpreter, I've only done this in pycharm I am not aware if vis studio also has this package.


from pywebio.input import *
from pywebio.output import *
import webbrowser

class User:
    def __init__(self, username, password):
        self.username = username
        self.password = password #simpple user password self class so args can be passed to other functions later


database = [["", ""]]  # open with blank str


def login():
    username = input("enter username ")
    password = input("enter password")
    will = User(username, password)

    for row in database:  # loop through db
        if (will.username, will.password) == (row[0], row[1]):
            print("Login successful")  # response
            return  # get out of the if question / return results
    print("Invalid username or password.")  # print a response
    create_account()  # skip to create acc


def create_account():
    global database
    username = input("Create new username: ")
    password = input("Create new password: ")  # simple input requests
    new_account = [username, password]  # combine username and password
    database.append(new_account)  # add new account variale to db
    print("Account created successfully!")
    print(database)  # print contents of list
    login()  # call login function again after acc created


login()  #runs the code

def contents(user):
    clear()
    if user == "Home":
        toast("You picked home page!")
        home_page1()
    elif user == "Search":
        toast("You picked search page!")
        search_page3()
    elif user == "Cart":
        toast("You picked Cart!")
        cart()
    elif user == "Settings":
        toast("You picked settings page!")
        settings8()


dbs = []
def like_items(liked):
    if liked == "Jordan 1":
        toast("Successfully added to cart!")  # display a successful message
        dbs.append('https://th.bing.com/th?id=OIP.vw4EDltntGRmslr1474NXAHaHa&w=124&h=104&c=7&o=6&dpr=1.3&pid=13.1')  # Add image URL to the list
    elif liked == "Lenovo laptop":
        toast("Successfully added to cart!")
        dbs.append('data:image/jpeg;base64,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')



def home_page1():
    clear()  # clear scope so pages arent merging
    put_button(' Search on price checker', onclick=lambda: search_page3()),  # first button on screen whoop

    put_table([
        [put_text(" Price changes below "), put_image(
            'https://www.bing.com/th?id=OIP.qSjnlRPNHRMWfykdn7kZiAHaHa&w=150&h=150&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
            width='50px')]
    ])
    put_text("Press the following buttons to add the product to cart")
    put_buttons(["Jordan 1", "Lenovo laptop"], onclick=like_items)
    put_table([
        [put_image(
            'https://th.bing.com/th?id=OIP.vw4EDltntGRmslr1474NXAHaHa&w=124&h=104&c=7&o=6&dpr=1.3&pid=13.1',
            width='40px'), put_html("<p>Jordan 1 high top, £185-180</p>").style('color: green'),
         put_button('click to puchase', onclick=lambda: item_page2())],
        [put_image(
            'data:image/jpeg;base64,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',

            width='20px'), put_html("<p>Lenovo V14 G4 AMN/AMD £329.99- 319.99</p>").style('color: green')],
        # ABOVE/BELOW is making an interface to show of the products effectivly
        [put_image('https://media.currys.biz/i/currysprod/M10207224_black?$l-large$&fmt=auto', width='40px'),
         put_html("<p>Apple air pod max, £499.99-500</p>").style('color:red'),
         put_button('click to purchase', onclick=lambda: item_page3())],
        [put_image(
            'data:image/jpeg;base64,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',
            width='20px'), put_html("<p>Promotional pen £2.34-2.60</p>").style('color: red')],
        [put_image(
            'https://images.asos-media.com/products/the-north-face-jester-backpack-in-black/204512394-1-black?$n_750w$&wid=750&fit=constrain',
            width='40px'), put_html("<p>North face Jester backpack, £69.99-65.99</p>").style('color:green')],
        # in one box each instead of 4 per row
        [put_image(
            'data:image/jpeg;base64,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',
            width='40px'), put_html("<p>Adidas samba £69.99- 70.50</p>").style('color:red')]
    ])  # creating buttons and text to match
    put_text("Choose a page:")
    put_table([
        [put_image(
            'https://th.bing.com/th?id=OIP.Pw3Av1lYJIH3uPqX3axEzAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
            width='58px'),
            put_image(' https://th.bing.com/th/id/OIP.rsZB5iKwX6totSXcV94swQHaHN?rs=1&pid=ImgDetMain',
                      width='58px'),
            put_image(
                'https://th.bing.com/th?id=OIP.CUp_ZAgqa7D87MgVjZCKRAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                width='58px'),
            put_image( #images for navigatioon icons
                'https://th.bing.com/th/id/OIP.kc38xqXNsN6wZRq6_cFNUAHaHa?w=174&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                width='58px')]
    ])

    put_buttons(["Home", "Search", "Cart", "Settings"], onclick=contents) #important code, the 'contents' calls the function+ buttons fill its arguments

home_page1() #initialise

def search_page3():
    clear()  # clear scope so pages arent merging
    put_table([
        [put_image('https://th.bing.com/th/id/OIP.rsZB5iKwX6totSXcV94swQHaHN?rs=1&pid=ImgDetMain', width='78px')
            , put_button("Begin typing", onclick=lambda: typable_search_page4())]
    ])

    put_table([
        [put_image(
            'https://th.bing.com/th?id=OIP.vw4EDltntGRmslr1474NXAHaHa&w=124&h=104&c=7&o=6&dpr=1.3&pid=13.1'),
         put_markdown("# Gorge green air max jordan 1 highs"), #product descriptions
         put_button('click to search it', onclick=lambda: item_page2())],
        [put_image('https://media.currys.biz/i/currysprod/M10207224_black?$l-large$&fmt=auto', width='175px'),
         put_markdown(" # Apple air pod max edition 1"),
         put_button('click to search it', onclick=lambda: item_page3())]
    ])

    put_text("Choose a page:")
    put_table([
        [put_image(
            'https://th.bing.com/th?id=OIP.Pw3Av1lYJIH3uPqX3axEzAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
            width='58px'),
            put_image(' https://th.bing.com/th/id/OIP.rsZB5iKwX6totSXcV94swQHaHN?rs=1&pid=ImgDetMain',
                      width='58px'),
            put_image(
                'https://th.bing.com/th?id=OIP.CUp_ZAgqa7D87MgVjZCKRAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                width='58px'),
            put_image(
                'https://th.bing.com/th/id/OIP.kc38xqXNsN6wZRq6_cFNUAHaHa?w=174&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                width='58px')]
    ])

    put_buttons(["Home", "Search", "Cart", "Settings"], onclick=contents)

    def typable_search_page4():
        clear()  # clear scope so pages arent merging

        edge = input("search")
        webbrowser.open('https://www.bing.com/search?q=' + edge) # utilises webbrowser libary to access actual edge, just a simple example search engine really
        put_button("Back", onclick=lambda :search_page3()) #simple return to previous page

def item_page3():
    clear()  # clear scope so pages arent merging
    put_table([
        [put_image('https://media.currys.biz/i/currysprod/M10207224_black?$l-large$&fmt=auto', width='240px'),
         put_markdown("""# Apple air pox max matt black
 Price increased from £500 to £549 """)],
        [put_text("Available in low stock"), put_image(
            "data:image/jpeg;base64,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",
            height='100px')],
        [put_html("https://www.jdwilliams.co.uk/shop/apple-airpods-max/HW228/product"),
         put_html(
             "https://www.bing.com/aclick?ld=e8GQy09fHPUZ2QYmJctw1y4zVUCUwtnoBCyXV043VjhmX4fs5ryhOmKU9lNLoSXwfjomKi4xXI2_bclqlZ79HNIyUaKlHzVuI3Yjhabrto1GcV6v1y2_Ik2B6NE2pZkZEScvTp9GySfCCgalkUNqSnxLvkMezLADlvduGbTuGSuiEjDSClg_hxE6Ep1VLMMZ9XTK0sSQ&u=aHR0cHMlM2ElMmYlMmZ3d3cuYmFja21hcmtldC5jby51ayUyZmVuLWdiJTJmcCUyZmFpcnBvZHMtbWF4LXNwYWNlLWdyYXklMmZjMTFhY2QwZi02ZDI2LTQwMDAtOGUxMC1iOTY1NTdlMTUzYzUlM2ZzaG9wcGluZyUzZGdtYyUyNm1zY2xraWQlM2QxYWM5NGNkNmFkZmIxMmNiODQwOTJhZmQ3NjJiNTFhYyUyNnV0bV9zb3VyY2UlM2RiaW5nJTI2dXRtX21lZGl1bSUzZGNwYyUyNnV0bV9jYW1wYWlnbiUzZEdCX1NBX1NIT1BfTV9HRU5fQXBwbGUlMjUyME90aGVyX1JTQyUyNnV0bV90ZXJtJTNkNDU4MzE3NjgzMTc5NDEzOSUyNnV0bV9jb250ZW50JTNkQWlyUG9kcyUyM2wlM2QxMA&rlid=1ac94cd6adfb12cb84092afd762b51ac")]
    ])

    put_table([
        [put_image(
            'https://th.bing.com/th?id=OIP.Pw3Av1lYJIH3uPqX3axEzAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
            width='78px'),
            put_image(' https://th.bing.com/th/id/OIP.rsZB5iKwX6totSXcV94swQHaHN?rs=1&pid=ImgDetMain',
                      width='78px'),
            put_image(
                'https://th.bing.com/th?id=OIP.CUp_ZAgqa7D87MgVjZCKRAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                width='78px'),
            put_image(
                'https://th.bing.com/th/id/OIP.kc38xqXNsN6wZRq6_cFNUAHaHa?w=174&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                width='78px')]
    ])
    put_buttons(["Home", "Search", "Cart", "Settings"], onclick=contents)


def item_page2():
    clear()  # clear scope so pages arent merging
    put_table([
        [put_image( #more indepth descriptions of the product
            'https://th.bing.com/th?id=OIP.vw4EDltntGRmslr1474NXAHaHa&w=124&h=104&c=7&o=6&dpr=1.3&pid=13.1',
            width='240px', height='240px'), put_markdown("""# Jordan 1 high top, Gorge green
Price decreased from £200 to £195 within last week""")],
        [put_text("Available sizes: 6, 6.5, 8.5, 9, 10, 13.5"),
         put_image(
             "https://th.bing.com/th/id/OIP.p26e5nVhSmiKd4u2JJe_DQHaBu?w=322&h=81&c=7&r=0&o=5&dpr=1.3&pid=1.7",
             width='300px')]
    ])
    put_text("Choose a page:")
    put_table([
        [put_image(
            'https://th.bing.com/th?id=OIP.Pw3Av1lYJIH3uPqX3axEzAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
            width='58px'),
            put_image(' https://th.bing.com/th/id/OIP.rsZB5iKwX6totSXcV94swQHaHN?rs=1&pid=ImgDetMain',
                      width='58px'),
            put_image(
                'https://th.bing.com/th?id=OIP.CUp_ZAgqa7D87MgVjZCKRAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                width='58px'),
            put_image(
                'https://th.bing.com/th/id/OIP.kc38xqXNsN6wZRq6_cFNUAHaHa?w=174&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                width='58px')]
    ])

    put_buttons(["Home", "Search", "Cart", "Settings"], onclick=contents)

def call():
    put_table([  # this code creates icons to show what the button does
        [put_image(
            'https://th.bing.com/th?id=OIP.Pw3Av1lYJIH3uPqX3axEzAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
            width='78px'),
            put_image(' https://th.bing.com/th/id/OIP.rsZB5iKwX6totSXcV94swQHaHN?rs=1&pid=ImgDetMain',
                      width='78px'),
            put_image(
                'https://th.bing.com/th?id=OIP.CUp_ZAgqa7D87MgVjZCKRAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                width='78px'),
            put_image(
                'https://th.bing.com/th/id/OIP.kc38xqXNsN6wZRq6_cFNUAHaHa?w=174&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                width='78px')]
    ])
    put_table([  # code makes buttons using pwebio
        [put_button('Home', onclick=lambda: home_page1()),
         put_button('Search', onclick=lambda: search_page3()),
         put_button('Cart', onclick=lambda: cart()),
         put_button('Settings', onclick=lambda: settings8())]
    ])  # creates buttons for easier navigation


def cart():
    clear()  # Clear the current scope to prevent page merging
    put_markdown("## Shopping Cart")
    put_markdown('# add items on the home page')
    global dbs #pull it up
    for url in dbs: #loop
        if url:  # check its not eptyy
            put_image(url)
    call() #buttons to navigate

def signout():
    toast("You are signed out")
    login() # jump to login to resign in after signed out
    # the sign-out is only called when a button is pressed so this doesnt conflict

def settings8():
    # clear scope to stop page merging
    clear()
    put_markdown("# Settings")

    put_table([
        [put_button("Privacy policy/ terms and conditions", onclick=lambda: terms())],
        [put_button("Notifications", onclick=lambda: notification_page9())],  # buttons to navigate
        [put_button("general settings", onclick=lambda: general())]
    ])

    put_text("Choose a page:")
    put_table([
        [put_image(
            'https://th.bing.com/th?id=OIP.Pw3Av1lYJIH3uPqX3axEzAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
            width='58px'),
            put_image(' https://th.bing.com/th/id/OIP.rsZB5iKwX6totSXcV94swQHaHN?rs=1&pid=ImgDetMain',
                      width='58px'),
            put_image(
                'https://th.bing.com/th?id=OIP.CUp_ZAgqa7D87MgVjZCKRAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                width='58px'),
            put_image(
                'https://th.bing.com/th/id/OIP.kc38xqXNsN6wZRq6_cFNUAHaHa?w=174&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                width='58px')]
    ]) #images to represent my buttons
    # utilising pywebios button system I can navigate the web page effortlessly

    put_buttons(["Home", "Search", "Cart", "Settings"], onclick=contents)

    def general():
        clear()
        put_button("Back", onclick=lambda: settings8())
        put_markdown("# General settings")
        login()
        toast("login successful")
        put_button("Sign out", onclick=signout)
 # these functions are nested as they only exist to further advance the settings page
    #serving no value outside the settings page, therefor they also arent reachable outside settings
    # call()

    def terms():
        clear()
        put_button("Back", onclick=lambda: settings8())
        put_markdown("# Terms and conditions")
        put_markdown("""# Right to export personal cookies-
Our policy gives us the legal right to freely process and use all users cookies for the strict purpose of assisting in marketting, this right is taken away when the user denies this upon downloading the application.""")

        put_markdown("""# Password policy-
We have strict regulations in place such as users being required to make complex passwords and change them every 2 weeks, failure to follow these procedures holds the victim accountable if a beach occurs not our organization.""")
        put_markdown("""# Operator guidance for processing clients data-
We as an organization are in line with GDPR regulations with data handlers trained in the correct methods, however clients must assist our operators in keeping their data safe by not visitng suspcious links etc while utilising our browser.""")

    def notification_page9():#coyld pass descision arg here
        clear()
        put_button("Back", onclick=lambda: settings8())
        put_markdown("# Notifications")
        put_table([
            [put_text("Push notifications"), put_buttons(["Enable", "disable"], onclick=put_text())],
            # buttons to activate certain settings
            [put_text("Discount notifications"), put_buttons(["Enable", "disable"], onclick=put_text())],
            [put_text("Attempted login notifications"), put_buttons(["Enable", "disable"], onclick=put_text())],
            [put_text("Trending products notifications"),put_buttons(["Enable", "disable"], onclick=put_text())],
            [put_text("Offers notifications"), put_buttons(["Enable", "disable"], onclick=put_text())]
        ])


        put_button('save preferences',onclick=notification_page9)
