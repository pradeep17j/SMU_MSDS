#setwd('./AppliedStats_Proj2')
kobe_data <- read.csv('./model_KobeData.csv')

library('ggplot2')
attach(kobe_data)
qplot(shot_distance, shot_id, color=shot_made_flag, shape=kobe_data$shot_type)

qplot(shot_distance, shot_id,  color=kobe_data$shot_type)



qplot(kobe_data$shot_zone_range, kobe_data$minutes_remaining, color=kobe_data$shot_made_flag)

qplot(kobe_data$shot_distance,)


