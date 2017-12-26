from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException

PAGE_URL_FORMAT_STRING = "http://www.playdb.co.kr/artistdb/list_iframe.asp?code=013003&sub_code=&ImportantSelect=&ClickCnt=Y&NameSort=&Country=Y&page={}"

def get_detail_links(driver):
  links = driver.find_elements_by_tag_name("a")
  detail_links = list(filter(lambda x: "detail" in x.get_attribute("href"), links))
  # remove duplicates in detail_links
  detail_links_map = {}
  for l in detail_links:
    detail_links_map[l.get_attribute("href")] = l
  # return all url strings
  return detail_links_map.keys()

curr_page = 1
driver = webdriver.Chrome()
detail_links = []
while True:
  driver.get(PAGE_URL_FORMAT_STRING.format(curr_page))
  detail_links += get_detail_links(driver)
  print("scanned page #{}".format(curr_page))
  curr_page += 1

print(detail_links)



