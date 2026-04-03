library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(stringr)

trace <- read_csv(system.file("performance", "newtrace.csv", package="exploreCEHR")) |>
    rename(
        gpu_util    = `utilization.gpu [%]`,
        mem_util    = `utilization.memory [%]`,
        mem_used    = `memory.used [MiB]`,
        mem_free    = `memory.free [MiB]`,
        mem_total   = `memory.total [MiB]`,
        power       = `power.draw [W]`,
        temp        = `temperature.gpu`
    ) |>
    mutate(
        timestamp = ymd_hms(timestamp),
        mem_used  = as.numeric(str_remove(mem_used,  " MiB")),
        gpu_util  = as.numeric(str_remove(gpu_util,  " %")),
        power     = as.numeric(str_remove(power,     " W"))
    )

manifest <- read_csv(system.file("performance", "newmanifest.csv", package="exploreCEHR")) |>
    mutate(
        start_time = ymd_hms(start_time),
        end_time   = ymd_hms(end_time),
        config     = paste0("embd=", n_embd, " heads=", n_heads)
    )

manifest = manifest[-4,]

p = lubridate::hms(c("4:0:0")) 

# Tag each trace row with the configuration that was running at that time
trace_tagged <- trace |>
    rowwise() |>
    mutate(config = {
        match <- manifest |>
            filter((timestamp+p) >= start_time, (timestamp+p) <= end_time)
        if (nrow(match) == 1) match$config else NA_character_
    }) |>
    ungroup() |>
    filter(!is.na(config))

# Peak VRAM per configuration
peak_mem <- trace_tagged |>
    group_by(config) |>
    summarise(
        peak_mem_mib  = max(mem_used),
        mean_gpu_util = mean(gpu_util),
        mean_power_w  = mean(power),
        duration_s    = as.numeric(difftime(max(timestamp),
                                            min(timestamp), units="secs"))
    )

print(peak_mem)

# Plot VRAM over time, coloured by configuration
vramplot <- ggplot(trace_tagged, aes(x=timestamp, y=mem_used, colour=config)) +
    geom_line(linewidth=0.6) +
    labs(x=NULL, y="VRAM used (MiB)", colour="Config") +
    theme_minimal() +
    theme(legend.position="bottom")

utilplot <- ggplot(trace_tagged, aes(x=timestamp, y=gpu_util, colour=config)) +
    geom_line(linewidth=0.6) +
    labs(x=NULL, y="GPU usage (%)", colour="Config") +
    theme_minimal() +
    theme(legend.position="bottom")

