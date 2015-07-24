from selenium import webdriver
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException


def main():
    print "==================="
    print "Initializing Kibana"
    print "==================="
    driver = webdriver.PhantomJS(executable_path='/usr/bin/phantomjs')
    wait = WebDriverWait(driver, 100)

    try:
        driver.get("http://kibana:5601/")
        print "Opening Kibana: "+driver.current_url
        wait.until(EC.presence_of_element_located(
            (By.CLASS_NAME, 'content')))
        driver.save_screenshot('kibana_open.png')
    except TimeoutException:
        print "Can't connect to Kibana"
        driver.save_screenshot('kibana_fail_open.png')
        raise

    try:
        wait.until(EC.title_contains('Settings'))
        print "Opened Settings Page"
    except TimeoutException:
        print "It's not Settings page"
        driver.save_screenshot('kibana_close.png')
        driver.quit()
        return

    try:
        print driver.current_url
        print "Set Time-field name to '@timestamp'"
        timefield_css = "select[ng-model=\"index.timeField\"]"
        wait.until(EC.presence_of_element_located(
            (By.CSS_SELECTOR, timefield_css)))
        timefield = driver.find_element_by_css_selector(timefield_css)
        select = Select(timefield)
        select.select_by_value("0")

        print "Creating Index Pattern 'logstash-*'"
        button_css = "button[type=\"submit\"]"
        wait.until(EC.element_to_be_clickable(
            (By.CSS_SELECTOR, button_css)))
        driver.find_element_by_css_selector(button_css).click()
        indice_css = "a[href=\"#/settings/indices/logstash-*\"]"
        wait.until(EC.presence_of_element_located(
            (By.CSS_SELECTOR, indice_css)))
        driver.save_screenshot('kibana_create.png')
    except TimeoutException:
        print "Can't change Kibana settings"
        driver.save_screenshot('kibana_fail_change.png')
        driver.quit()
        raise

    driver.close()
    driver.quit()


if __name__ == "__main__":
    main()
