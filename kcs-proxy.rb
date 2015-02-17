#!/usr/bin/env ruby
# coding:  utf-8

require 'pp'

require 'webrick'
require 'webrick/httpproxy'
require 'json'


kcs_handler = Proc.new {|req,res|

	if req.unparsed_uri.include?("kcsapi") then
		
		Thread.fork(res.body,req.unparsed_uri) do |body,uri|
				
			buffer = uri.gsub(/.*?kcsapi\/(.*?)/,'\1')
			buffer << "\n"
			buffer << JSON.parse(body.gsub(/svdata=/,'')).pretty_inspect

			File.open("kcs-dump.log","a",0644) do |f|
		
				f.flock(File::LOCK_EX)
				f.write(buffer)

			end

		end

	end
	
}

kcs_proxy = WEBrick::HTTPProxyServer.new(
	:BindAddress		=>	'0.0.0.0',
	:Port			=>	'8081',
	:ProxyVia		=>	false,
	:Logger			=>	WEBrick::Log::new("kcs.log", WEBrick::BasicLog::FATAL),
	:ProxyContentHandler	=>	kcs_handler
)

Signal.trap('INT') do

	kcs_proxy.shutdown
	exit

end


kcs_proxy.start

