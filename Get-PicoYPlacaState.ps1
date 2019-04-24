function Get-PicoYPlacaState {
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$plateNumber,
    [string]$date,
    [string]$time,
    [int]$startTime = 600,
    [int]$endTime = 1800
)

# Write-Host $PSBoundParameters

# The default ruleset allows plates with even numbered last digits to drive on Monday, Wednesday, Friday
# Odd-numbered last digits can drive on Tuesday, Thursday and Saturday. All cars can drive on Sunday
# The rules are in effect from 6 AM (6:00) to 6 PM (18:00)

# If date or time not specified, assume now
if (!($PSBoundParameters.date)) {
    #write-host "getting date from system"
    [datetime]$date = Get-Date
    $year = $date.Year
    $month = $date.Month
    $day = $date.Day
}
else {
    write-host "date entered from switch"
    write-host $date
    [datetime]$date = $date -as [DateTime];
    if ($date.GetType().Name -ne "DateTime") {
        Write-Host -BackgroundColor Red -ForegroundColor Black "Invalid Date entered. Enter date in YYYY-MM-DD format"
        Break
    }
    $year = $date.Year
    $month = $date.Month
    $day = $date.Day
}
if (!($PSBoundParameters.time)) {
    #write-host "getting time from system"
    [string]$time = Get-Date -Format HH:mm
    [string]$hour = Get-Date -Format HH
    [string]$minute = Get-Date -Format mm
}
else {
    write-host "time entered by switch"
    #checks that the time entered is usable
    [datetime]$time = $time -as [DateTime];
    if ($time.GetType().Name -ne "DateTime") {
        Write-Host -BackgroundColor Red -ForegroundColor Black "Invalid Time entered. Enter time in HH:MM format"
        Break
    }
    $hour = $time.hour
    $minute = $time.minute
}

$lastDigit = $plateNumber[-1]
#Make sure the last digit is an int
if ($lastDigit -notmatch "^[0-9]*$") {
    Write-Host -BackgroundColor Red -ForegroundColor Black "Expected last character of plate to be an integer, is not. Cannot continue"
    break
}

$dayOfWeek = (Get-Date $date).DayOfWeek
#fix a seeming bug in Powershell
if ($minute.Length -eq 1) {
    [string]$minute = "0" + $minute
}

$fancyDate = Get-Date -Year $year -Month $month -Day $day -Hour $hour -Minute $minute
[int]$timeInt = "$hour" + "$minute"
Write-Host $plateNumber $date $time $dayOfWeek $timeInt
if (($timeInt -lt $startTime) -or ($timeInt -gt $endTime) -or ($dayOfWeek -eq "Sunday")) {
    Write-Host -BackgroundColor Green -ForegroundColor Black "Rules not in effect, all cars allowed on road"
}
# run even plates here
elseif ((($lastDigit % 2) -eq 0) -and 
    (($dayOfWeek -eq "Monday") -or ($dayOfWeek -eq "Wednesday") -or ($dayOfWeek -eq "Friday"))) {
    Write-Host -BackgroundColor Green -ForegroundColor Black "Plate $plateNumber is allowed to be on the road on $fancyDate"
}
#run odd plates
elseif ((($lastDigit % 2) -eq 1) -and 
    (($dayOfWeek -eq "Tuesday") -or ($dayOfWeek -eq "Thursday") -or ($dayOfWeek -eq "Saturday"))) {
    Write-Host -BackgroundColor Green -ForegroundColor Black "Plate $plateNumber is allowed to be on the road on $fancyDate"
}
else {
    Write-Host -BackgroundColor Red "Plate $plateNumber is not allowed to be on the road on $fancyDate"
}
}
<#
    .SYNOPSIS
    This script takes a plate number and a date and time and returns if the car will be allowed to be driving.
    .PARAMETER plateNumber
        A 6-7 digit alphanumeric plate number.
    .PARAMETER date
        The date in the format YYYY-MM-DD. If not specified, the program will assume today's date. This is not dependent on time being specified.
    .PARAMETER time
        The time in 24 hour format. If not specified, the program will assume now. This is not dependent on date being specified.
    .EXAMPLE
        This example specifies a time and date:
        Get-PicoYPlacaState -plateNumber "AAA-1234" -date "2019-04-24" -time "17:34"
    .EXAMPLE
        This example only specifies a date. This will assume the date given and the time now. You could also run with only a time and no date, which will assume today and the time specified.
        Get-PicoYPlacaState -platenumber "AAA-1234" -date "2019-04-24"

    .EXAMPLE
        This example only specifies a plate. It assumes today and right now.
        Get-PicoYPlacaState -plateNumber "AAA-1234"
    .NOTES
        Author: Damon Breeden
        Github: https://github.com/damonbreeden
    #>


$evenPlate = "AAA-1234"
$oddPlate = "AAA-2345"

Write-Host "runs an even plate now"
Get-PicoYPlacaState -plateNumber $evenPlate

Write-Host "runs an odd plate now"
Get-PicoYPlacaState -plateNumber $oddPlate

Write-Host "runs an even plate on a Thursday at 6:01 PM"
Get-PicoYPlacaState -plateNumber $evenPlate -date 2019-04-25 -time 18:01

Write-Host "Run an odd plate on Monday at the current time"
Get-PicoYPlacaState -plateNumber $oddPlate -date 2019-07-01

Write-Host "Run an even plate today at 4 PM"
Get-PicoYPlacaState -plateNumber $evenPlate -time 16:00

Write-Host "Run an odd plate today at 4 PM"
Get-PicoYPlacaState -plateNumber $oddPlate -time 16:00

Write-Host "Uncomment line 136 to enter an invalid date. This results in an error."
#Get-PicoYPlacaState -plateNumber $evenPlate -date Today

Write-Host "Uncomment line 139 to enter an invalid plate. This results in an error."
#Get-PicoYPlacaState -plateNumber 1234-aaa

Write-Host "Uncomment line 142 to enter an invalid time. This results in an error."
#Get-PicoYPlacaState -plateNumber $evenPlate -time "1500 PM"