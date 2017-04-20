function Start-AudioRecorder
{
  [CmdletBinding()]
  param
  (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [int]$RecordTime,
	
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OutFile
  )
  
  # The default record time is 10 seconds
  if (-not $PSBoundParameters['RecordTime']){
     $RecordTime = 10
  }

  # The default recorded file is called AudioRecorder-year-month-day-hour-minutes-seconds.wav and
  # will be created on your desktop 
  if (-not $PSBoundParameters['OutFile']){
     $DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
     $OutFile = "$($DesktopPath)\AudioRecorder-$(Get-Date -format yyyy-MM-dd-H-mm-ss).wav"
  }
  
  # Reference to the function mciSendString from the C:\Windows\System32\winmm.dll
  $memberdef =@"
[DllImport("winmm.dll", CharSet = CharSet.Ansi)]
public static extern int mciSendStringA(
string lpstrCommand,
string lpstrReturnString,
int uReturnLength,
IntPtr hwndCallback);
"@
  
  # Get the name of the output file without extension 
  $t = [System.IO.Path]::GetFileNameWithoutExtension($OutFile)
  
  try{

     # Importing the DLL function mciSendString  
     $winmm = Add-Type -MemberDefinition $memberdef -ErrorAction SilentlyContinue -PassThru -name mciSendString

     
     # Create a new audio alias  
     $winmm::mciSendStringA("open new Type waveaudio Alias $($t)","",0,0) | Out-Null
          
     # Start recording 
     $winmm::mciSendStringA("record $($t)","",0,0)| Out-Null

     # Wait the RecordTime in seconds 
     Start-Sleep -Seconds $RecordTime

     # Stop and save the output file 
     $winmm::mciSendStringA("save $($t) $($OutFile)","",0,0)| Out-Null

     # Close the alias
     $winmm::mciSendStringA("close $($t)","",0,0)| Out-Null

     # Everything is fine!
     Write-Host "Recorded $($RecordTime) second(s) in the file: $($OutFile)"

  }
  catch [Exception]{
    # If something goes wrong delete the output file and warn the user 
    if (Test-Path $OutFile) {
         Remove-Item $OutFile
    }
    Write-Host "Could not record audio!"
  }

}

# TESTS

Start-AudioRecorder 
#Start-AudioRecorder -RecordTime 5
#Start-AudioRecorder -RecordTime 5 -OutFile C:\Users\hackingscool\Desktop\victoria.wav