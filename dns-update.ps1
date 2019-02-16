# Title: 	Update DNS for auto.[domain] in namesilo
# Author: 	Doodk
# Version: 	1.0.1
# Date:		2019/02/16

$key = ""
$domain = "example.com"
$domainTLD = "auto"

function FormatMessage($dnsxml) {
	$dnsxml = $dnsxml.Substring(32, $dnsxml.Length - 32 - 11 - 8 - 1)
	
	$dnsxml = $dnsxml.Replace("<request><operation>", "")
	$dnsxml = $dnsxml.Replace("</operation><ip>", " @ ")
	$dnsxml = $dnsxml.Replace("</ip></request><reply>", "`n`t")

	#$dnsxml = $dnsxml.Replace("</request><reply>", "`n`n<reply>")

	$dnsxml = $dnsxml.Replace("><", ">`n`t<")
	$dnsxml = $dnsxml.Replace("`t</", "</")

	$dnsxml = $dnsxml + "`n"
	return $dnsxml
}

# pre settings
$timestring = Get-Date -Format "yyMMdd-HHmmss"
$ip = (Read-Host -Prompt "Enter new IP address").Trim()
$server = (Read-Host -Prompt "Enter new server location (ex:us-ga or blank)").Trim()
$server = "pxi-" + $server + "-" + $timestring

Write-Host `n


# add new server to DNS
$addDNS = "https://www.namesilo.com/api/dnsAddRecord?version=1&type=xml&key=" + $key + "&domain=" + $domain + "&rrtype=A&rrttl=7207" + `
		"&rrhost=" + $server + `
		"&rrvalue=" + $ip
$addDNS = (curl -uri $addDNS).Content
FormatMessage $addDNS


# get domainTLD.[domain]'s DNS ID
$dnslist = "https://www.namesilo.com/api/dnsListRecords?version=1&type=xml&key=" + $key + "&domain=" + $domain
$dnslist = (curl -uri $dnslist).Content
$recordIndex = $dnslist.IndexOf("<host>" + $domainTLD + "." + $domain + "</host>")
$dnsIDIndex = $dnslist.LastIndexOf("<resource_record>", $recordIndex)
$dnsIDIndex = $dnslist.IndexOf("<record_id>", $dnsIDIndex)+11
$dnsID = $dnslist.Substring($dnsIDIndex, $dnslist.IndexOf("</", $dnsIDIndex) - $dnsIDIndex)


# update domainTLD.[domain]'s DNS w/ new server
$updateAutoDNS = "https://www.namesilo.com/api/dnsUpdateRecord?version=1&type=xml&key=" + $key + "&domain=" + $domain + "&rrttl=3600" + `
		"&rrhost="+ $domainTLD + `
		"&rrid=" + $dnsID + `
		"&rrvalue=" + $server + "." + $domain
$updateAutoDNS = (curl -uri $updateAutoDNS).Content
FormatMessage $updateAutoDNS

Write-Host -NoNewline "Press any key to exit..."
[void][System.Console]::ReadKey($true)
