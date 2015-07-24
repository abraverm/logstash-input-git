from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.action_chains import ActionChains
import time
from urllib2 import URLError


def set_time_period(driver, wait, period):
    print "Selecting 'Last 5 years' option"
    driver.find_element_by_partial_link_text(period).click()

    driver.set_window_size(1920, 1080)
    try:
        print 'Waiting for results'
        css_selector = 'div.visualize-chart'
        wait.until(EC.presence_of_element_located(
            (By.CSS_SELECTOR, css_selector)))
    except TimeoutException:
        print "no results found?"
        driver.save_screenshot('kibana_time_pick_fail.png')
        raise


def open_timemenu(driver, wait, actions):
    timeout = time.time() + 300
    while time.time() < timeout:
        try:
            print "Opening time menu (top right corner)"
            time_picker = "li[ng-show=\"timefilter.enabled\"]"
            wait.until(EC.presence_of_element_located(
                (By.CSS_SELECTOR, time_picker)))
            timemenu = driver.find_element_by_css_selector(time_picker)
            actions.move_to_element(timemenu)
            actions.click(timemenu)
            actions.perform()
            driver.save_screenshot('kibana_time_pick_open.png')
            break
        except (TimeoutException, URLError):
            print "Faild to open time menu"
            driver.save_screenshot('kibana_time_pick_fail.png')
            continue


def wait_for_kibana(driver, wait):
    timeout = time.time() + 300
    while time.time() < timeout:
        try:
            print "Looking for '_source' field in left bar: "
            field_css = "li[field=\"_source\"]"
            wait.until(EC.visibility_of_element_located(
                (By.CSS_SELECTOR, field_css)))
            print "Found field - continue"
            driver.save_screenshot('kibana_time_pick_start.png')
            break
        except TimeoutException:
            driver.save_screenshot('kibana_time_pick_fail.png')
            print "Field not found - try again"
            continue


def open_kibana(driver, wait):
    try:
        driver.get("http://kibana:5601/")
        print "Opening Kibana: "+driver.current_url
        wait.until(EC.title_contains("Discover"))
        url = "http://kibana:5601/#/discover?_g=()&_a=(" \
            "columns:!(_source)," \
            "index:'logstash-*'," \
            "interval:auto," \
            "query:(query_string:(analyze_wildcard:!t,query:'*'))," \
            "sort:!('@timestamp',desc))"
        driver.get_cookies()
        timeout = time.time() + 300
        while '_source' not in driver.current_url and time.time() < timeout:
            print "Opening Kibana: "+driver.current_url
            driver.get(url)
            wait.until(EC.title_contains("Discover"))
            time.sleep(100)
    except TimeoutException:
        print "Can't connect to Kibana"
        driver.save_screenshot('kibana_time_pick_fail.png')


def terminate_driver(driver):
    driver.close()
    driver.quit()


def init_driver():
    driver = webdriver.PhantomJS(executable_path='/usr/bin/phantomjs')
    wait = WebDriverWait(driver, 100)
    actions = ActionChains(driver)
    return (driver, wait, actions)


def print_title(title):
    print "-------------------"
    print title
    print "-------------------"


def main():
    print_title("Kibana Discover")
    driver, wait, actions = init_driver()
    open_kibana(driver, wait)
    terminate_driver(driver)
    driver, wait, actions = init_driver()
    url = "http://kibana:5601/#/discover?_g=()&_a=(" \
        "columns:!(_source)," \
        "index:'logstash-*'," \
        "interval:auto," \
        "query:(query_string:(analyze_wildcard:!t,query:'*'))," \
        "sort:!('@timestamp',desc))"
    driver.get(url)
    wait_for_kibana(driver, wait)

    driver.set_window_size(1920, 1080)
    open_timemenu(driver, wait, actions)
    set_time_period(driver, wait, '5 years')

    driver.save_screenshot('kibana_results.png')
    terminate_driver(driver)

if __name__ == "__main__":
    main()
