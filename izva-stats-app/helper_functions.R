# I'll have here the helper functions for the app.

actor.data <- readRDS("data/actor_data.rds")

histogram.all <- ggplot(actor.data, aes(x=Age_group, fill=Dialect)) +
geom_histogram(alpha=0.4)

actor.data.izva <- actor.data %>% filter(Dialect == "Iźva Dialect")
histogram.izva <- ggplot(actor.data.izva, aes(x=Age_group, fill=Sex)) +
        geom_histogram(alpha=0.4)

actor.data.udo <- actor.data %>% filter(Dialect == "Udora Dialect")
histogram.udo <- ggplot(actor.data.udo, aes(x=Age_group, fill=Sex)) +
        geom_histogram(alpha=0.4)
