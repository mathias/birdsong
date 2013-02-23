#!/usr/bin/env ruby -w

require 'rubygems'
require 'httparty'
require 'json'

credentials_path = File.expand_path('../credentials.json', __FILE__)

if File.exist? credentials_path
  credentials = JSON.parse File.open(credentials_path, 'r').read
else
  puts "Must supply an API key in credentials.json"
  exit
end

## Strategy:
# get list of all charts
# grab all charts
# save the charts into a format that we can use later

class Birdsong
  def initialize(credentials)
    @user = credentials['user']
    @domain = 'http://ws.audioscrobbler.com'
    @api_version = '2.0'
    @key = credentials['key']
    @user = credentials['user']
  end

  def base_uri
    @domain + '/' + @api_version + '/'
  end

  def user_and_api_key
    '&user=' + @user + '&api_key=' + @key
  end

  def get_charts
    charts_method = 'user.getweeklychartlist'
    HTTParty.get(base_uri + '?method=' + charts_method + user_and_api_key + '&format=json')
  end

  def discover_all_charts
    @chart_list = get_charts
    @charts = @chart_list['weeklychartlist']['chart'] 
    puts 'There are ' + @charts.count.to_s + ' pages of tracks'
  end

  def get_for_time_period(method, from, to)
    HTTParty.get("http://ws.audioscrobbler.com/2.0/?method=#{method}&user=mathiasdgauger&api_key=2aa88b33dab67074a35861290c556a87&format=json" + '&from=' + from + '&to=' + to)
  end

  def write_json_for_method(method, from, to)
    api_method = "user.get#{method}"
    weekly_chart = get_for_time_period(api_method, from, to)

    unless weekly_chart.has_key?(method) && weekly_chart[method].has_key?("#text")
      File.open(File.expand_path("../data/#{method}_#{from}_to_#{to}.json", __FILE__), 'w').write weekly_chart
      puts "Wrote results for method #{method} from #{from} to #{to}"
    else
      puts "No results for method #{method} from #{from} to #{to}" 
    end
  end

  def grab_all_results
    artist_method = 'weeklyartistchart'
    track_method = 'weeklytrackchart'
    album_method = 'weeklyalbumchart'

    output_path = File.expand_path('../data/', __FILE__)
    Dir.mkdir(output_path) unless Dir.exist? output_path

    @charts.reverse.each do |chart|
      write_json_for_method(artist_method, chart['from'], chart['to'])
      write_json_for_method(album_method, chart['from'], chart['to'])
      write_json_for_method(track_method, chart['from'], chart['to'])
    end
  end

  def crawl_and_save
    discover_all_charts
    grab_all_results
  end
end

birdsong = Birdsong.new(credentials)
birdsong.crawl_and_save
