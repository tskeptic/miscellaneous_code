
'''
last updated: 2018-10-10
this script send connection requests to random people for target position
fill your info at the personalized_info session and run
'''

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time
import sys

# personalized info
YOUR_EMAIL = 'YOUR-EMAIL'
YOUR_PASSWORD = 'PASSWORD'
TARGET_POSITION = 'TITLE-NAME'

REQUESTS_MADE = 0
ERRORS_GOTTEN = 0
LOGGED = False
JOB_DONE = False


def interact_object(browser, xpath, action, key=None):
    '''
    since this task is very repetitive I made a function
    5 tries with one second interval and scrolls and refreshes at 3 and 4 seconds
    '''
    tries = 0
    while tries < 5:
        try:
            obj = browser.find_element_by_xpath(xpath)
            if action == 'click':
                obj.click()
            elif action == 'send':
                obj.send_keys(key)
            return 0
        except:
            tries += 1
            time.sleep(1)
            if tries == 2: browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            if tries == 3: browser.refresh()
    print('COULDNT FIND OBJECT {}'.format(xpath))
    raise Exception('ops')


def log_in(driver, email, pwd):
    # logging in
    interact_object(browser=driver, xpath="//input[@id='login-email']", action='send', key=email)
    interact_object(browser=driver, xpath="//input[@id='login-password']", action='send', key=pwd)
    interact_object(browser=driver, xpath="//input[@id='login-submit']", action='click')
    time.sleep(1)
    return True


def search_2conn_by_title(driver, title_position):
    # going to search page
    driver.get('https://www.linkedin.com/search/results/all/')
    # the first button is People
    interact_object(browser=driver, xpath="//button[@class='search-vertical-filter__filter-item-button button-tertiary-medium-muted']", action='click')
    time.sleep(2)
    # expanding filter options
    interact_object(browser=driver, xpath="//button[@data-control-name='all_filters']", action='click')
    time.sleep(2)
    # selecting 2nd degree
    interact_object(browser=driver, xpath="//label[@for='sf-network-S']", action='click')
    time.sleep(2)
    # filling position
    interact_object(browser=driver, xpath="//input[@id='search-advanced-title']", action='send', key=title_position)
    time.sleep(2)
    interact_object(browser=driver, xpath="//button[@data-control-name='all_filters_apply']", action='click')
    time.sleep(1)


def get_people_from_results(driver):
    # making sure all results are showed
    p_s = [0, 1]
    while p_s[0] != p_s[1]:
        # scrolling page hoping all info appears
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(1)
        p_s[0] = p_s[1]
        people_found = driver.find_elements_by_class_name("search-result__actions--primary")
        p_s[1] = len(people_found)
    return people_found


def detect_email_request(driver):
    email_request = driver.find_elements_by_xpath("//input[@name='email']")
    if len(email_request) > 0:
        interact_object(browser=driver, xpath="//button[@class='send-invite__cancel-btn']", action='click')
        return True
    else:
        return False


def add_all_people_from_page(driver, target_people):
    global REQUESTS_MADE
    for person in target_people:
        if person.text == 'Connect' or person.text == 'Conectar':
            person.click()  # connect button
            time.sleep(1)
            # email asking handling
            if detect_email_request(driver): continue
            # send now button
            send_now_button = driver.find_element_by_xpath("//button[@class='button-primary-large ml1']")
            send_now_button.click()
            time.sleep(1)
            REQUESTS_MADE += 1  # for counting how many people


def detect_end_of_results(driver):
    button_next = driver.find_elements_by_xpath("//div[@class='next-text']")
    if len(button_next) > 0:
        return False
    else:
        return True


def main():
    try:
        # TODO after this script runs smoothly implement in a headless browser
        global LOGGED
        global YOUR_EMAIL
        global YOUR_PASSWORD
        global TARGET_POSITION
        # starting browser with no cache settings
        profile = webdriver.FirefoxProfile()
        profile.set_preference("browser.cache.disk.enable", False)
        profile.set_preference("browser.cache.memory.enable", False)
        profile.set_preference("browser.cache.offline.enable", False)
        profile.set_preference("network.http.use-cache", False)
        driver = webdriver.Firefox(profile)
        # accessing linkedin
        driver.get('https://www.linkedin.com/')
        if not LOGGED: LOGGED = log_in(driver=driver, email=YOUR_EMAIL, pwd=YOUR_PASSWORD)
        search_2conn_by_title(driver=driver, title_position=TARGET_POSITION)
        # iterating over results pages
        while True:
            # iterating over people
            people = get_people_from_results(driver=driver)
            add_all_people_from_page(driver=driver, target_people=people)
            # going to next page
            if detect_end_of_results(driver):
                driver.close()
                global JOB_DONE
                JOB_DONE = True
                break
            interact_object(browser=driver, xpath="//div[@class='next-text']", action='click')
            time.sleep(1)
    except:
        print("Unexpected error:", sys.exc_info()[0])
        global ERRORS_GOTTEN
        ERRORS_GOTTEN += 1
        LOGGED = False
        driver.delete_all_cookies()
        driver.close()


if __name__ == '__main__':
    while not JOB_DONE:
        main()
    print('adds: {}'.format(str(REQUESTS_MADE)))
    print('erros: {}'.format(str(ERRORS_GOTTEN)))
