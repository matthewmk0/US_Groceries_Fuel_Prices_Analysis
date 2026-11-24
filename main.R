library('tidyverse')
library('ggplot2')
library('readxl')
library('rstatix')

#raw datasets
df_price <- read.csv(file.choose(),header=T)
df_wide <- read.csv(file.choose(),header=T)

###################################
####### 1: data exploration #######
###################################

#checking if each item has exactly one unit
df_price %>%
  distinct(item,unit) %>%
  count(item) %>%
  filter(n>1)
# result: 0 rows, it's what we want

df_price %>%
  count(item, date) %>%
  filter(n>1)
# result: 0 rows, it's what we want

# items with short history or gaps, also tail
df_price %>%
  count(item) %>%
  arrange(n) %>%
  {rbind(head(., 10), tail(., 10))}
#lambda to use both tail and head
# result: pears, chuck roast, corn & more have lower
#         obs counts, maybe removing them would avoid issues.

# looking at price data to see if there are any invalid entries
prices <- df_price %>%
  get_summary_stats(price, type='full')
prices
#results: no issues, ready for log transformation

# notes:
# fix anything these turn up before moving on;
# gaps matter because lag() would difference across a missing month.

#########################################
######## data fixing and prepping #######
#########################################

# fix coffee category, new df is good practice
price_monthly <- df_price |>
  mutate(
    category = if_else(
      item == "Coffee, 100%, ground roast, all sizes" & category == "Beef",
      "Drinks",
      category
    )
  )

##################################################
####### 2: Log differences and wide matrix #######
##################################################

log_diffs <- price_monthly %>%
  arrange(item, date) %>%
  group_by(item) %>%
  mutate(log_diff = log(price) - log(lag(price))) %>%
  ungroup() %>%
  filter(!is.na(log_diff))

wide <- log_diffs %>%
  select(date, item, log_diff) %>%
  pivot_wider(names_from = item, values_from = log_diff)


# items sorted by category so the heatmap shows blocks,
# will be used later for testing
item_info <- price_monthly %>%
  distinct(item, category) %>%
  arrange(category, item)

# spearman method bc of error chance
cor_mat <- cor(wide[, item_info$item],
               method = "spearman",
               use = "pairwise.complete.obs")

#####################################
####### 3: data visualization #######
#####################################

df_price1 |>
  filter(category == 'Drinks') |>
  group_by(year) |>
  summarise(avg_p = mean(price)) |>
    ggplot(aes(x = year, y=avg_p))+
    geom_point()+
    geom_line()+
    theme_classic()

df_price1 |>
  group_by(year) |>
  summarise(price_mean = mean(price)) |>
  ggplot(aes(x=year,y=price_mean,fill=year))+
  geom_bar(stat='identity')+
  theme_classic()+
  scale_x_continuous(limits = c(2014,2027))

cor_long <- as.data.frame(as.table(cor_mat)) %>%
  rename(item1 = Var1, item2 = Var2, r = Freq) %>%
  mutate(item1 = factor(item1, levels = item_info$item),
         item2 = factor(item2, levels = item_info$item))

# heatmap for spearman correlation
# hard to read maybe do half/half
# or change labels into index and then have a list?
ggplot(cor_long, aes(item1, item2, fill=r))+
  geom_tile()+
  scale_fill_gradient2(low="#0006BD",
                       mid="white",
                       high="#BD0000",
                       midpoint=0, limits=c(-1, 1))+
  labs(x='',
       y='',
       fill="Spearman")+
  theme_minimal()+
  theme(axis.text.x=element_text(angle=90, hjust=1, size=5),
        axis.text.y=element_text(size=5))

######################################
####### 4: inferential testing #######
######################################

#h_null: category labels carry no information about how correlated two items are.
# Category labels carry no information about correlation.
# The mean within-category correlation equals the mean between-category correlation.

#h_a: The mean within-category correlation is greater than the between-category correlation.
#test stat: mean correlation for same-category pairs
#           minus mean correlation for different-category pairs.

upper <- upper.tri(cor_mat)

stat <- function(cats) {
  same <- outer(cats, cats, "==")
  mean(cor_mat[upper & same]) - mean(cor_mat[upper & !same])
}

obs <- stat(item_info$category)

set.seed(42)
perm <- replicate(5000, stat(sample(item_info$category)))  # shuffle labels

p_value <- (sum(perm >= obs) + 1) / (5000 + 1)
p_value

ggplot(tibble(perm), aes(perm)) +
  geom_histogram(bins = 50, fill = "grey70") +
  geom_vline(xintercept = obs, color = "firebrick", linewidth = 1) +
  labs(x = "Within minus between correlation", y = "Count")
