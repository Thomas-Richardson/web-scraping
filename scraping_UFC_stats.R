# scraping UFC.com

library(rvest)
library(tidyverse)
library(magrittr)

data = data.frame() # make a blank dataframe to store data in

for (letter in letters){ # go through each letter of the alphabet
  print(letter) # print out the letter so we know how far along we are
  link = paste0('http://ufcstats.com/statistics/fighters?char=',letter,'&page=all') # the link is ufcstats.com/statistics..etc PLUS the letter of the alphabet. So we paste our letter onto the end of it
  link %>% 
    read_html() %>% # read the HTML at the link
    html_nodes('.b-statistics__table') %>% # extract the elements that make up the table and nothing else
    html_table(fill=T) %>% # use html table function to convert the table on the website into a format we can convert to dataframe. fill = T means fill in empty table elements with NAs
    data.frame-> # turn it into a dataframe
    temp_data # save it as temp_data
  temp_data= temp_data[2:nrow(temp_data),] # get rid of first row with seem to be all NAs for some reason
  data = rbind(data, temp_data) # add temp_data to our overall dataframe
}

data %>% View()

# Facile!

#===================== Now data cleaning =======================================

# this column doesn't have any info
data %<>% select(-Belt)

# rename columns to be easier to work with and be more informative
colnames(data) = c('first_name','last_name','nickname','height_inches','weight_lb','armspan_inches','stance','wins','losses','draws')

data$weight_lb %<>% parse_number() # parse weight
data$weight_lb %>% hist(main = 'UFC fighter weight (lbs)') # well someone has a strange weight.

data$weight_lb %>% table(useNA = 'always') # someone is clocking in at 770lbs?!
data %>% filter(weight_lb==770) # google this geezer he actually exists!

data$armspan_inches %<>%  parse_number() # clean armspan
data$armspan_inches %>% hist # all looks fine

# now let's sort out height
data$height_inches %>% str_split('\' ',simplify = T) %>% data.frame -> data_height # split height into 2 columns, feet and inches. 
data_height$X1 %<>% parse_number() # parse feet into a number
data_height$X2 %<>% parse_number() # parse inches into a number
data$height_inches = (data_height$X1*12)+data_height$X2 # height in inches is height_feet multiplied by 12 + height_inches

data$height_inches %>% hist # looks good to me!

# make some new useful variables. Or as datascientists call it 'feature engineering'

data$total_fights = data %>% select(wins, losses, draws) %>% rowSums()
data$win_percentage = (data$wins +(0.5*data$draws)) / data$total_fights

data$stance %>% table(useNA = 'always') # important to tick useNA as always so it shows us how many NAs we have
data$stance[data$stance==''] = NA

data$stance2 = data$stance # let's make a new stance variable collapsing open stance, sideways and switch together into a single 'mixed' stance
data$stance2[data$stance2 %in% c('Open Stance','Sideways','Switch')]='Mixed'
data$stance2 %>% table(useNA = 'always')

# save clean data as csv.
name = paste0('UFC_data_cleaned_', Sys.Date(),'.csv') # we want to name our datafile with today's date on it so that if you scrape multiple times you know when you did this one!

write_csv(data,name)
