library('dplyr')
library('ggplot2')

avg_price_monthly <- read.csv(file.choose(),header=T)

avg_price_mo <- avg_price_monthly |>
  mutate(category = factor(category,c(
    "Meat, broad category",
    "Pork and deli",
    "Beef",
    "Drinks",
    "Dairy and fats",
    "Energy",
    "Fruit",
    "Vegetables",
    "Bakery and grains",
    "Poultry",
    "Eggs",
    "Pantry and snacks")),
    year <- as.integer(year)
  )

avg_price_mo |>
  View()

# Coffee is its own category
avg_price_mo1 <- avg_price_mo |>
  mutate(
    category = if_else(
      item == "Coffee, 100%, ground roast, all sizes" & category == "Beef",
      "Coffee",
      category
    )
  )

# Coffee is in the Drink category
avg_price_mo2 <- avg_price_mo |>
  mutate(
    category = if_else(
      item == "Coffee, 100%, ground roast, all sizes" & category == "Beef",
      "Drinks",
      category
    )
  )

avg_price_mo1 |>
  filter(category == 'Coffee') |>
  group_by(year) |>
  summarise(avg_p = mean(price)) |>
    ggplot(aes(x = year, y=avg_p))+
    geom_point()+
    geom_line()+
    theme_classic()
  
glimpse(avg_price_mo1)

avg_price_mo |>
  group_by(year) |>
  summarise(price_mean = mean(price)) |>
  ggplot(aes(x=year,y=price_mean,fill=year))+
  geom_bar(stat='identity')+
  theme_classic()+
  scale_x_continuous(limits = c(2014,2027))
