#!/bin/bash

REPORT="/var/www/webbisivu/viikko3/index.html"

# System information
UPTIME=$(uptime -p)
TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone)
CURRENT_TIME=$(date)

# Disk information (root filesystem)
DISK_USED_PERCENT=$(df -h / | awk 'NR==2 {print $5}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_AVAILABLE=$(df -h / | awk 'NR==2 {print $4}')
DISK_USED_NUM=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
if [ "$DISK_USED_NUM" -ge 80 ]; then
    DISK_STATUS='<span style="color:#e74c3c;font-weight:bold;">WARNING</span>'
else
    DISK_STATUS='<span style="color:#2ecc71;font-weight:bold;">OK</span>'
fi

# Memory information (MB)
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/^Mem:/ {print $7}')
MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))

# Pie chart calculations
USED_PERCENT=$(( MEM_USED * 100 / MEM_TOTAL ))

# SVG arc coordinates
ANGLE=$(awk "BEGIN {print $USED_PERCENT * 3.6}")

if (( USED_PERCENT > 50 )); then
    LARGE_ARC=1
else
    LARGE_ARC=0
fi

X=$(awk "BEGIN {print 100 + 80 * sin($ANGLE * 3.14159 / 180)}")
Y=$(awk "BEGIN {print 100 - 80 * cos($ANGLE * 3.14159 / 180)}")

cat > "$REPORT" <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Server Status Report</title>
<style>
* {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: "Segoe UI", sans-serif;
}
body {
        background-color: #BFC1C2;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        color: #2F3A44;
}

.container {
        background: rgba(255,255,255,0.65);
        backdrop-filter: blur(10px);
        padding: 2.5rem;
        border-radius: 18px;
        width: 90%;
        max-width: 850px;
        box-shadow: 0 8px 24px rgba(0,0,0,0.12);
        text-align: center;
}

.card {
    background: white;
    padding: 20px;
    margin-bottom: 20px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.row {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
}

.row .card {
    flex: 1;
    min-width: 350px;
}
h1 {
        color: #1F2933;
        font-size: 2.5rem;
        margin-bottom: 0.75rem;
        letter-spacing: 1px;
}
.subtitle {
        color: #69737D;
        font-size: 0.95rem;
        margin-bottom: 1.5rem;
}
p {
        color: #4A5560;
        margin-bottom: 1.5rem;
        font-size: 1rem;
        line-height: 1.6;
}

a {
        display: inline-block;
        text-decoration: none;
        background: #3B5A77;
        color: white;
        padding: 12px 24px;
        border-radius: 10px;
        font-weight: 600;
        transition: 0.3s;
}
a:hover {
        background: #2C445A;
        transform: translateY(-2px);
}
table {
    width: 100%;
    border-collapse: collapse;
}

td {
    padding: 10px;
    border-bottom: 1px solid #ddd;
}

.chart {
    text-align: center;
}
</style>
</head>
<body>

<div class="container">

<h1>Week 3</h1>
<div class="subtitle">Server Status Report</div>
<div class="row">
<div class="card">
<h2>System Information</h2>
<table>
<tr><td><strong>Current Time</strong></td><td>$CURRENT_TIME</td></tr>
<tr><td><strong>Timezone</strong></td><td>$TIMEZONE</td></tr>
<tr><td><strong>Uptime</strong></td><td>$UPTIME</td></tr>
</table>
</div>

<div class="card">
<h2>Disk Usage</h2>
<table>
<tr><td><strong>Used</strong></td><td>$DISK_USED_PERCENT</td></tr>
<tr><td><strong>Total Size</strong></td><td>$DISK_TOTAL</td></tr>
<tr><td><strong>Available</strong></td><td>$DISK_AVAILABLE</td></tr>
<tr><td><strong>Status</strong></td><td>$DISK_STATUS</td></tr>
</table>
</div>
</div>
<div class="row">
<div class="card chart">
<h2>Memory Usage</h2>

<svg width="220" height="220" viewBox="0 0 200 200">
    <circle cx="100" cy="100" r="80"
            fill="#2ecc71"/>

    <path d="M100,100
             L100,20
             A80,80 0 $LARGE_ARC,1 $X,$Y
             Z"
          fill="#e74c3c"/>

    <circle cx="100" cy="100" r="45" fill="white"/>

    <text x="100" y="105"
          text-anchor="middle"
          font-size="18"
          font-weight="bold">
          $USED_PERCENT%
    </text>
</svg>

<table>
<tr><td><strong>Total RAM</strong></td><td>${MEM_TOTAL} MB</td></tr>
<tr><td><strong>Used RAM</strong></td><td>${MEM_USED} MB</td></tr>
<tr><td><strong>Available RAM</strong></td><td>${MEM_AVAILABLE} MB</td></tr>
</table>

<p>
<span style="color:#e74c3c;">&#9632;</span> Used RAM &nbsp;&nbsp;
<span style="color:#2ecc71;">&#9632;</span> Available RAM
</p>
</div>
<div class="card">
<h2>How this website works</h2>
<br>
<p>This dashboard is generated automatically every minute by a scheduled cron task. The underlying Bash script gathers live system metrics from the Linux server, including uptime, timezone, storage utilization, and memory consumption. The generated HTML report is published directly through the Nginx web server.</p>
<p>You can find the Bash script used in this website from project github.</p>
</div>
</div>
    <a href="https://github.com/heikinsauna/Linux-admin" target="_blank">
        Visit Project GitHub
    </a>
    <br>
    <br>
    <a href="http://195.148.22.221" target="_blank">
	Main page / Week 1
    </a>
<br>
<h2>Testing and lesson learned</h2>
<p>I first created really basic script that only made the html-file. After that I tested it. I used previous weeks html as a palette for this weeks website. After I confirmed that website works I followed the examples to get the system information from Linux machine and saved it to variables for my website.
After I got the basics saved I made the DISK_STATUS OK or WARNING using if-else learned from Ville's examples. After I confirmed this working I started to tune the website at my own computer to look more professional. Then I came up with the idea of the pie-chart. I investigated and used AI to make that fancy pie-chart for the RAM-usage. I want to belive that OpenAI CEO Sam Altman is gonna be happy when he sees all that unused RAM in the CSC-datacenter. After I was happy with my week3-website I run the cron job to automate the bash-script to run every minute.
</div>

</body>
</html>
EOF
