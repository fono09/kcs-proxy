#!/usr/bin/env ruby

require 'pp'

require 'webrick'
require 'webrick/httpproxy'
require 'json'

=begin
gapi_get_member/ship3
gapi_req_kaisou/slotset
gapi_req_hokyu/charge
gapi_get_member/ndock
gapi_req_kousyou/createship
gapi_get_member/kdock
gapi_get_member/material
gapi_req_hensei/change
gapi_get_member/record
gapi_req_member/updatecomment
gapi_req_ranking/getlist
gapi_port/port
gapi_req_kaisou/powerup
gapi_req_kousyou/createitem
=end

api_list = ['/api_port/port',]
kcs_handler = Proc.new() {|req,res|

	if req.unparsed_uri.include?("kcsapi") then

		p req.unparsed_uri
		print "\n"


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

