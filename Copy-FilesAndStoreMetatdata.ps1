# R equires -Version 3.0 
# R equires -Modules ActiveDirectory, DnsClient
# R equires -RunAsAdministrator

Function Copy-FilesStoreMetaData {
	<#
 .SYNOPSIS
Copy backup files from source to destination and capture metadata for historical information and future planning
.DESCRIPTION
<A detailed description of the script>
.PARAMETER <paramName>
<Description of script parameter>
.EXAMPLE
<An example of using the script>
#>

	BEGIN 
    {
		function New-TimedStampFileName {
			param (
				[Parameter(Mandatory,HelpMessage='Prefix of file or log name')]
				[alias('FilePrefix')]
				$FileNameBase,
				[Parameter(Mandatory,HelpMessage='Extention of file.  txt, csv, log')]
				[alias('Extension')]
				$FileNameExtension,
				[Parameter(HelpMessage='Formatting Choice 1: YYMMDDHHmm, 2: YYYYMMDD, 3: DDHHmmss, 4: 17/03/16_21:52')]
				[alias('DateFormatChoice')]
				[ValidateRange(1,4)]
				$FileNameDateFormat
			)
			switch ($FileNameDateFormat){
				1{$DateStamp = Get-Date -uformat '%y%m%d%H%M'} # 1703162145 YYMMDDHHmm
				2{$DateStamp = Get-Date -uformat '%Y%m%d'} # 20170316 YYYYMMDD
				3{$DateStamp = Get-Date -uformat '%d%H%M%S'} # 16214855 DDHHmmss
				4{$DateStamp = Get-Date -uformat '%y/%m/%d_%H:%M'} # 17/03/16_21:52
				default{$DateStamp = Get-Date -uformat '%y%m%d%H%M%S'} # 1703162145 YYMMDDHHmmss
			}
			$FileNameBase + '-'+$DateStamp + '.'+$FileNameExtension
		}

		function Create-OutputFile {
            $Script:OutputFile = New-TimedStampFileName -FileNameBase DataCopyFileMetaData -FileNameExtension txt -FileNameDateFormat 2
            

		}

	} # Finish BEGIN 

	PROCESS 
    {
		function Get-DriveInformation {
			#Content
			get-wmiobject -Class Win32_Share | Sort-Object -Property Name | Select-Object -Property Name, Path, Status

			get-wmiobject -Class Win32_MappedLogicalDisk | Select-Object -Property Name, Description, FileSystem, @{Label='Size';Expression={"{0,12:n0} MB" -f ($_.Size/1mb)}}, @{Label="Free Space";Expression={"{0,12:n0} MB" -f ($_.FreeSpace/1mb)}}, ProviderName

		}

		function Get-FileMetadata {
			#Content


		}

		function Move-Files {
			#Content


		}

		function Set-InputFileData {
			#Content


		}

	} # Finish PROCESS

	END 
    {
		Export-NpsConfiguration -Path "<Path>\$($env:COMPUTERNAME)-NPS-$(Get-Date -Uformat %Y%m%d).xml"
		Copy-Item -Path "<Same Path\$($env:COMPUTERNAME)-NPS-$(Get-Date -Uformat %Y%m%d).xml" -Destination '<UNC Path>'
		#exit
	} # Finish END

}

Copy-FilesStoreMetaData