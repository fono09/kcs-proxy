#!/usr/bin/env ruby
# coding:  utf-8

require 'pp'

require 'webrick'
require 'webrick/httpproxy'
require 'json'

api_list = %w!api_start2  api_port/port  api_get_member/basic api_get_member/furniture api_get_member/slot_item api_get_member/useitem api_get_member/kdock api_get_member/ndock api_get_member/unsetslot api_get_member/ship2 api_get_member/ship3 api_get_member/material api_get_member/record api_get_member/questlist api_get_member/deck api_get_member/sortie_conditions api_get_member/mapcell api_get_member/mapinfo api_get_member/practice api_get_member/mission  api_req_member/get_practice_enemyinfo  api_req_map/start api_req_map/next  api_req_sortie/battle api_req_sortie/battleresult  api_req_mission/start  api_req_practice/battle api_req_practice/battle_result  api_req_quest/start api_req_quest/stop  api_req_member/updatecomment api_req_member/get_incentive  api_req_kaisou/slotset api_req_kaisou/powerup  api_req_hokyu/charge  api_req_kousyou/createitem api_req_kousyou/createship api_req_kousyou/getship  api_req_hensei/change api_req_hensei/lock  api_req_ranking/getlist  api_req_nyukyo/speedchange!


kcs_handler = Proc.new{|req,res|

	if req.unparsed_uri.include?("kcsapi") then

		
		Thread.fork(res.body) {|body|
			File.open("kcs-dump.log","a",0644){ |f|
				f.flock(File::LOCK_EX)
				f.write JSON.parse(body.gsub(/svdata=/,'')).pretty_inspect
			}

		}

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

