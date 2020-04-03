[xml]$GPOXmlReport = Get-GPOReport -All -ReportType Xml
($GPOXmlReport.GPOS.GPO | Where-Object {$_.LinksTo -eq $null}).Name