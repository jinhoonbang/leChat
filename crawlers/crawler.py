from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException

PAGE_URL_FORMAT_STRING = "http://www.playdb.co.kr/artistdb/list_iframe.asp?code=013003&sub_code=&ImportantSelect=&ClickCnt=Y&NameSort=&Country=Y&page={}"
MUSICALS_URL_FORMAT_STRING = "http://www.playdb.co.kr/artistdb/Detail_Content_new.asp?TabKind=3&ManNo={}"
def get_detail_links(driver):
  links = driver.find_elements_by_tag_name("a")
  detail_links = list(filter(lambda x: "detail" in x.get_attribute("href"), links))
  # remove duplicates in detail_links
  detail_links_map = {}
  for l in detail_links:
    detail_links_map[l.get_attribute("href")] = l
  # return all url strings
  return detail_links_map.keys()

# 'http://www.playdb.co.kr/artistdb/detail.asp?ManNo=23592&part=013003' => 23592
def parse_id(link):
  try:
    return link.split("ManNo=")[1].split("&part")[0]
  except ValueError:
    print("unable to parse {}".format(link))

def get_musicals(driver, id):
  driver.get(MUSICALS_URL_FORMAT_STRING.format(id))
  musical_tds = driver.find_elements_by_class_name("ptitle")
  # return list of all musical titles
  return list(map(lambda x: x.find_element_by_tag_name("a").text, musical_tds))

curr_page = 1
driver = webdriver.Chrome()
detail_links = []
# only run for 2 pages for now
while curr_page < 3:
  driver.get(PAGE_URL_FORMAT_STRING.format(curr_page))
  detail_links += get_detail_links(driver)
  print("scanned page #{}".format(curr_page))
  curr_page += 1

# parse ids from URLs
ids = list(map(lambda x: parse_id(x), detail_links))

# build a list of maps where each map has information about one actor
# [
#   {
#     "id" : 3452,
#     "musicals": ["nameOfMusical"],
#   }
# ]
data = []
for id in ids:
  actor_info = {}
  actor_info["ID"] = id
  actor_info["Musicals"] = get_musicals(driver, id)
  data.append(actor_info)

print(data)



