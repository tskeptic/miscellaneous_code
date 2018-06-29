
'''
last updated: 2018-03-13
this script send connection requests to random people for target position
fill your info at the personalized_info session and run
'''

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time
import sys


def interact_object(xpath, action, key=None):
    '''
    since this task is very repetitive I made a function
    5 tries with one second interval and scrolls and refreshes at 3 and 4 seconds
    '''
    tries = 0
    while tries < 5:
        try:
            obj = driver.find_element_by_xpath(xpath)
            if action == 'click':
                obj.click()
            elif action == 'send':
                obj.send_keys(key)
            return 0
        except:
            time.sleep(1)
            tries += 1
            if tries == 2: driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            if tries == 3: driver.refresh()
    print('COULDNT FIND OBJECT {}'.format(xpath))
    raise Exception('ops')

# personalized info
YOUR_EMAIL = 'YOUR EMAIL'
YOUR_PASSWORD = 'YOUR PASSWORD'
TARGET_POSITION = 'data scientist'

# starting browser
#TODO after this script runs smoothly implement in a headless browser
driver = webdriver.Firefox()

# accessing linkedin
driver.get('https://www.linkedin.com/')

# logging in
interact_object(xpath="//input[@id='login-email']", action='send', key=YOUR_EMAIL)
interact_object(xpath="//input[@id='login-password']", action='send', key=YOUR_PASSWORD)
interact_object(xpath="//input[@id='login-submit']", action='click')

# getting into the search page
# the search button is hidden, so we click on the text box first
interact_object(xpath="//div[@class='nav-search-typeahead']", action='click')
interact_object(xpath="//button[@class='search-typeahead-v2__button typeahead-icon']", action='click')

# executing search
interact_object(xpath="//button[@class='search-vertical-filter__filter-item-button button-tertiary-medium-muted']", action='click')  # the first button is People
interact_object(xpath="//button[@data-control-name='all_filters']", action='click')  # expanding filter options
interact_object(xpath="//label[@for='sf-facetNetwork-S']", action='click')  # selecting 2nd degree
interact_object(xpath="//input[@id='search-advanced-title']", action='send', key=TARGET_POSITION)  # filling position
interact_object(xpath="//button[@data-control-name='all_filters_apply']", action='click')

# starting counters
adds = 0
erros = 0

while True:
    # making sure all results are showed
    p_s = [0, 1]
    while p_s[0] != p_s[1]:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")  # scrolling page hoping all info appears
        time.sleep(1)
        p_s[0] = p_s[1]
        people = driver.find_elements_by_class_name("search-result__actions--primary")
        p_s[1] = len(people)
    # iterating over people
    for person in people:
        if person.text == 'Connect':
            person.click()  # connect button
            time.sleep(1)
            #TODO email asking handling
            # SOMETIMES PERSON ASKS FOR EMAIL TO VERIFY YOU KNOW HIM/HER, I AM TRYING TO FIND EXAMPLES TO DEAL WITH HERE
            send_now_button = driver.find_element_by_xpath("//button[@class='button-primary-large ml1']")  # send now button
            send_now_button.click()
            time.sleep(1)
            adds += 1  # for counting how many people
    # going to next page
    #TODO verify if there is no next button and conclude the while loop 
    interact_object(xpath="//div[@class='next-text']", action='click')
#TODO: something to restart entire process in case of errors

print('adds: {}'.format(str(adds)))
print('erros: {}'.format(str(erros)))
