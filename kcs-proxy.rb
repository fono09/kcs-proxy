#!/usr/bin/env ruby
# coding:  utf-8

require 'pp'

require 'webrick'
require 'webrick/httpproxy'
require 'json'

class Exporter

	
	def initialize(addr,rabel,data)

		@addr = addr
		@rabel = rabel
		@data = data
		@buffer = ""
		
	end

	def csv

		if(@addr[0] == @addr[1]) then 

			@buffer << @rabel.map{ |rabel_key,rabel_value| "#{rabel_value}(#{rabel_key})" }.join(',') << "\n"

			@data.each do |row|

				@buffer << @rabel.map{|rabel_key,rabel_value|
			
					if row[rabel_key].kind_of?(String) then

						row[rabel_key].chomp

					else

						row[rabel_key].pretty_inspect.chomp

					end

				}.join(',') << "\n"

			end
			
			File.open("kcs-dump-#{@addr[0]}.log","a",0644) do |f|

				f.flock(File::LOCK_EX)
				f.write(@buffer)

			end

			return @buffer

		else

			return nil

		end
	end

end

kcs_handler = Proc.new do |req,res|

	fork do
	
		uri = req.unparsed_uri
		body = res.body

		if uri.include?("kcsapi") then

			kcs_addr = uri.gsub(/.*?kcsapi\/(.*?)/,'\1')
			kcs_data = JSON.parse(body.gsub(/svdata=/,''))

			api_start2_api_mst_ship = Exporter.new( 
				["api_start2",kcs_addr],
				[
					["api_id","内部ID"],
					["api_sortno","図鑑ID"],
					["api_name","艦名"],
					["api_yomi","読み"],
					["api_stype","艦種"],
					["api_afterlv","改造Lv"],
					["api_aftershipid","改造後内部ID"],
					["api_taik","耐久/最大"],
					["api_souk","装甲/最大"],
					["api_houg","火力/最大"],
					["api_raig","雷装/最大"],
					["api_tyku","対空/最大"],
					["api_luck","運/最大"],
					["api_soku","速力"],
					["api_leng","射程"],
					["api_slot_num","スロット数"],
					["api_maxeq","スロット毎艦載機数"],
					["api_buildtime","建造時間(分)"],
					["api_broken","解体時資源"],
					["api_powup","改修素材時"],
					["api_backs","レアリティー"],
					["api_getmes","取得時メッセージ"],
					["api_afterfuel","改造時消費燃料"],
					["api_afterbull","改造時消費弾薬"],
					["api_fuel_max","最大消費燃料"],
					["api_bull_max","最大消費弾薬"],
					["api_voicef","特殊ボイス(0で無し)"]
				],
				kcs_data["api_data"]["api_mst_ship"]
			)

			api_start2_api_mst_ship.csv

			buffer = "==========\n" << kcs_data.pretty_inspect << "==========\n"

			kcs_file = kcs_addr.gsub(/\//,'_')
			File.open("kcs-dump-pp-#{kcs_file}.log", "a", 0644) do |f|

					f.flock(File::LOCK_EX)
					f.write(buffer)
		
			end


		end

	end
	
end

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

