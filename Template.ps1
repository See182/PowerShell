<# 
.SYNOPSIS 
Script that will list the logon information of AD users. 
 
.DESCRIPTION 
This script will list the AD users logon information with their logged on computers by inspecting the Kerberos TGT Request 
Events(EventID 4768) from domain controllers. Not Only User account Name is fetched, but also users OU path and Computer  
Accounts are retrieved. You can also list the history of last logged on users. In Environment where Exchange Servers are  
used, the exchange servers authentication request for users will also be logged since it also uses EventID (4768) to for  
TGT Request. You can also export the result to CSV file format. Powershell version 3.0 is needed to use the script. 
You can Define the following parameters to suite your need:                                                                                     
-MaxEvent        Specify the number of all (4768) events to search for TGT Requests. Default is 1000.                                             
-LastLogonOnly    Display only the history of last logon users.                                                                                 
-OuOnly            Do not display the full path of users/computers. Only OU is displayed.                                                         
Author: phyoepaing3.142@gmail.com                                                                                                             
Country: Myanmar(Burma)                                                                                                                         
Released Date: 08/29/2016 
 
Example usage:                                                                                       
.\Get_AD_Users_Logon_History.ps1 -MaxEvent 800 -LastLogonOnly -OuOnly 
 
.EXAMPLE 
.\Get_AD_Users_Logon_History.ps1 | Format-Table * -Auto 
This command will retrieve AD users logon within default 1000 EventID-4768 events and display the results as table. 
 
.EXAMPLE 
.\Get_AD_Users_Logon_History.ps1 -MaxEvent 500 -LastLogonOnly -OuOnly 
This command will retrieve AD users logon within 500 EventID-4768 events and show only the last logged users with their 
related logged on computers. Only OU name is displayed in results. 
 
.EXAMPLE 
.\Get_AD_Users_Logon_History.ps1 | Export-Csv Users_Loggedon_History.csv 
This command will retrieve AD users logon within default 1000 EventID-4768 events and export the result to CSV file. 
 
.PARAMETER MaxEvent 
This paraemeter will specify the number of EventID-4768 events to look for. 
 
.PARAMETER LastLogonOnly 
This paraemeter will display the history of last logged on users in descending order. 
 
.PARAMETER OuOnly 
This paraemeter will show only the OU names for users/computers but not the full path. 
 
.LINK 
You can find this script and more at: https://www.sysadminplus.blogspot.com/ 
#> 