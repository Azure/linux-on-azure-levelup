# Obtaining Performance metrics from a Linux system

Credits: [DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-obtain-performance-metrics-from-a-linux-server)

There are several commands that can be used to obtain performance counters on Linux. Commands such as vmstat and uptime, provide general system metrics such as CPU usage, System Memory, and System load. Most of the commands are already installed by default with others being readily available in default repositories. The commands can be separated into:

- CPU
- Memory
- Disk I/O
- Processes
- Network

## CPU

## Sysstat utilities installation

Some commands are part of the sysstat package which might not be installed by default. The package can be easily installed with:

```bash
sudo apt install -y sysstat
```

The mpstat utility is part of the sysstat package. It displays per CPU utilization and averages, which is helpful to quickly identify CPU usage. mpstat provides an overview of CPU utilization across the available CPUs, helping identify usage balance and if a single CPU is heavily loaded.

```bash
mpstat -P ALL 1
```

The options and arguments are:

- -P: Indicates the processor to display statistics, the ALL argument indicates to display statistics for all the online CPUs in the system.
- 1: The first numeric argument indicates how often to refresh the display in seconds.
- 2: The second numeric argument indicates how many times the data refreshes.

The number of times the mpstat command displays data can be changed by increasing the second numeric argument to accommodate for longer data collection times. Ideally 3 or 5 seconds should suffice, for systems with increased core counts 2 seconds can be used to reduce the amount of data displayed. From the output:

```text
Linux 6.8.0-1013-azure (linux001)       08/29/24        _x86_64_        (1 CPU)

17:00:08     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
17:00:09     all    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
17:00:09       0    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00

17:00:09     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
17:00:10     all    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
17:00:10       0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00

Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
Average:     all    0.50    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.50
Average:       0    0.50    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.50
```

Things to look out for
Some details to keep in mind when reviewing the output for mpstat:

Verify that all CPUs are properly loaded and not a single CPU is serving all the load. This information could indicate a single threaded application.
Look for a healthy balance between %usr and %sys as the opposite would indicate more time spent on the actual workload than serving kernel processes.
Look for %iowait percentages as high values could indicate a system that is constantly waiting for I/O requests.
High %soft usage could indicate high network traffic.

### vmstat

The vmstat utility is widely available in most Linux distributions, it provides high level overview for CPU, Memory, and Disk I/O utilization in a single pane. The command for vmstat is:

```bash
vmstat -w 1 5
```

The options and arguments are:

- -w: Use wide printing to keep consistent columns.
- 1: The first numeric argument indicates how often to refresh the display in seconds.
- 5: The second numeric argument indicates how many times the data refreshes.

The output:

```text
--procs-- -----------------------memory---------------------- ---swap-- -----io---- -system-- ----------cpu----------
   r    b         swpd         free         buff        cache   si   so    bi    bo   in   cs  us  sy  id  wa  st  gu
   2    0            0       642036        85644      2287696    0    0    69   584  101    1   2   0  97   1   0   0
   0    0            0       642036        85644      2287712    0    0     0     0  137  175   0   0 100   0   0   0
   0    0            0       642036        85644      2287712    0    0     0     0   53   79   0   0 100   0   0   0
   0    0            0       642036        85644      2287712    0    0     0     0   29   57   0   0 100   0   0   0
   0    0            0       642036        85644      2287712    0    0     0     0   23   46   0   0 100   0   0   0
```

Things to look out for
Some details to keep in mind when reviewing the output for vmstat:

- The r column indicates the number of processes waiting for CPU time, a high value could indicate a CPU bottleneck.
- The b column indicates the number of processes in uninterruptible sleep, a high value could indicate a disk I/O bottleneck.
- The wa column indicates the percentage of time the CPU is waiting for I/O operations to complete, a high value could indicate a disk I/O bottleneck.
- The si and so columns indicate the amount of data swapped in and out of memory, a high value could indicate a memory bottleneck.
- The us and sy columns indicate the percentage of time the CPU is spending on user and system processes, respectively.
- The id column indicates the percentage of time the CPU is idle.
- The gu column indicates the percentage of time the CPU is guest time.
- The st column indicates the percentage of time the CPU is stolen time.
- The in and cs columns indicate the number of interrupts and context switches per second, respectively.
- The bi and bo columns indicate the number of blocks received and sent to block devices per second, respectively.
- The free column indicates the amount of free memory available.
- The buff column indicates the amount of memory used as buffers.
- The cache column indicates the amount of memory used as cache.
- The swpd column indicates the amount of memory swapped to disk.

### uptime

For CPU related metrics, the uptime utility provides a broad overview of the system load with the load average values.

```bash
uptime
```

The output:

```text
 17:00:08 up  1:00,  1 user,  load average: 0.00, 0.00, 0.00
```

The load average displays three numbers. These numbers are for 1, 5 and 15 minute intervals of system load.

To interpret these values, it's important to know the number of available CPUs in the system, obtained from the mpstat output before. The value depends on the total CPUs, so as an example of the mpstat output the system has 8 CPUs, a load average of 8 would mean that ALL cores are loaded to a 100%.

A value of 4 would mean that half of the CPUs were loaded at 100% (or a total of 50% load on ALL CPUs). In the previous output, the load average is 9.26, which means the CPU is loaded at about 115%.
The 1m, 5m, 15m intervals help identify if load is increasing or decreasing over time.

## Memory

### free

The free utility provides a high level overview of the system memory usage.

```bash
free -m
```

The -m option displays the output in megabytes.

The output:

```text
              total        used        free      shared  buff/cache   available
Mem:           7826        1044        5864         104        917        6544
Swap:          2047           0        2047
```

Things to look out for
Some details to keep in mind when reviewing the output for free:

- The total column indicates the total amount of memory available.
- The used column indicates the amount of memory used.
- The free column indicates the amount of memory available for use.
- The shared column indicates the amount of memory shared between processes.
- The buff/cache column indicates the amount of memory used as buffers and cache.
- The available column indicates the amount of memory available for use by applications.
- The swap column indicates the amount of swap space available.

## I/O

### iostat

The iostat utility provides an overview of disk I/O utilization.

```bash
iostat -dxtm 1 5
```

The options and arguments are:

- -d: Per device usage report.
- -x: Extended statistics.
- -t: Display the timestamp for each report.
- -m: Display in MB/s.
- 1: The first numeric argument indicates how often to refresh the display in seconds.
- 2: The second numeric argument indicates how many times the data refreshes.
