library(XML)
library(plyr)
library(rvest)

#Setting an empty data frame
output <- {}

#see how many iterations are needed
url <- "http://www.playdb.co.kr/artistdb/list_iframe.asp?Page=1&code=013003&NameSort=Y&Country=Y"
web_data <- readLines(url, warn=FALSE)
web_data <- paste(web_data, collapse = ' ')
pages <- as.numeric(substr(web_data, regexpr("total 1/", web_data)[[1]]+8, regexpr("]</span>", web_data)[[1]]-1))

#main scraper
for (page in 1:pages)
{
	url <- paste0("http://www.playdb.co.kr/artistdb/list_iframe.asp?Page=", page, "&code=013003&NameSort=Y&Country=Y")
	web_data <- readLines(url, warn=FALSE)
	web_data <- paste(web_data, collapse = ' ')
	id_starting_indices <- as.vector(gregexpr("./detail.asp?", web_data)[[1]])+19 #even only
	id_ending_indices <- as.vector(gregexpr("&part=013003", web_data)[[1]])-1 #even only
	name_starting_indices <- as.vector(gregexpr("top\">", web_data)[[1]])+5 #even only
	name_ending_indices <- name_starting_indices+10 #even only

	for (i in 1: (length(id_starting_indices)/2))
	{
		#get id
		id <- substr(web_data, id_starting_indices[i*2], id_ending_indices[i*2])
		
		#get name
		name <- substr(web_data, name_starting_indices[i*2], name_ending_indices[i*2])
		name <- substr(name, 1, regexpr("<", name)-1)
		
		#get works
		url <- paste0("http://www.playdb.co.kr/artistdb/Detail_Content_new.asp?TabKind=3&ManNo=", id)
		history <- iconv(paste0(readLines(url, encoding="CP949"), collapse="\n"), to="UTF-8")
		musicals <- xpathSApply(htmlParse(history, isHTML=T, asText=T, encoding="UTF-8"), "//td[@class='ptitle']", xmlValue)
		dates <- xpathSApply(htmlParse(history, isHTML=T, asText=T, encoding="UTF-8"), "//td[@class='time']", xmlValue)

		#format data
		block <- cbind(id, name, musicals, dates)
		
		#append
		output <- rbind.fill(as.data.frame(output), as.data.frame(block))
	}
}

#scraping playNo (musical id)
codes <- {}
ids <- unique(output$id)
for (persons in 1:length(ids))
{
	#get workcodes
	scores <- {}
	url <- paste0("http://www.playdb.co.kr/artistdb/Detail_Content_new.asp?TabKind=3&ManNo=", ids[persons])
	web_data <- readLines(url, warn=FALSE)
	web_data <- paste(web_data, collapse = ' ')
	code_starting_indices <- as.vector(gregexpr("dbDetail.asp?", web_data)[[1]])+24 #even only
	code_ending_indices <- as.vector(gregexpr("target=\"_parent\"><", web_data)[[1]])-3
	for (k in 1: (length(code_starting_indices)/2))
	{
		code <- substr(web_data, code_starting_indices[k*2-1], code_ending_indices[k])
		codes <- append(codes, code)
	}
}
codes[which(codes=="")] <- NA

#scraping scores (out of 10) by audience
scores <- {}
for (cd in codes)
{
	#get scores
	url <- paste0("http://www.playdb.co.kr/playdb/playdbDetail.asp?sReqPlayno=", cd)
	url_html <-  read_html(url, encoding="CP949")
	score_node <- html_node(url_html, "dd.score")
	score <- as.character(html_text(score_node))
	scores <- append(scores, as.character(score))
}

#replace empty cells with NA
scores[which(scores=="")] <- NA

#combine and omit all rows with NA
output_final <- cbind(output, codes, scores)
output_final <- na.omit(output_final)

#strsplit dates column into two (start & end)
time_i <- {}
time_f <- {}
for (date in output_final$dates)
{
    time_i <- append(time_i, strsplit(date, " ~ ")[[1]][1])
    time_f <- append(time_f, strsplit(date, " ~ ")[[1]][2])
}
output_final <- cbind(output_final, time_i, time_f)

#save the output
write.csv(output_final, "data.csv")
