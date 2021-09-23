class ResultsController < ApplicationController
    require 'httparty'
    require 'json'
    def index
        @summoner_name = params["summonerName"]
        @api_key = "api_key=RGAPI-81d1e7a4-58c8-4e8f-bc91-f92d834cfcb4"
        @profile = get_account_info_by_summoner_name(@summoner_name)
        @match_list = get_match_list_by_puuid(@profile['puuid'], 0, 20)
        @match_info = Array.new(20)
        for i in 0..19
          if @match_list[i]
            @match_info[i] = get_match_info_by_matchID(@match_list[i])
          end
        end
        @filtered_match_info = Array.new(20)
        for i in 0..19
          if @match_info[i]
            @filtered_match_info[i] = filter_match_info_for_one_player(@profile['puuid'], @match_info[i])
          end
        end
    end
      
    def get_account_info_by_summoner_name(summoner_name)
        response = HTTParty.get('https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/' + summoner_name.to_s + '?' + @api_key)
        if response.code == 200
          return JSON.parse(response.body)
        else
          return response.code
        end
    end
  
    def get_match_list_by_puuid(puuid, start_index, number_of_games)
      response = HTTParty.get('https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/' + puuid.to_s + '/ids?start=' + start_index.to_s + '&count=' + number_of_games.to_s + '&' + @api_key)
      if response.code == 200
        return JSON.parse(response.body)
      else
        return response.code
      end
    end

    def get_match_info_by_matchID(matchID)
      response = HTTParty.get('https://americas.api.riotgames.com/lol/match/v5/matches/' + matchID.to_s + '?' + @api_key)
      if response.code == 200
        return JSON.parse(response.body)
      else
        return response.code
      end
    end

    def get_match_timeline_by_matchID(matchID)
      response = HTTParty.get('https://americas.api.riotgames.com/lol/match/v5/matches/' + matchID.to_s + "/timeline" + '?' + @api_key)
      if response.code == 200
        return JSON.parse(response.body)
      else
        return response.code
      end
    end

    def filter_match_info_for_one_player(puuid, match_info)
      for i in 0..9
        if match_info["metadata"]["participants"][i] == puuid
          for x in 0..9
            if match_info["info"]["participants"][x]["participantId"] == i+1
              return match_info["info"]["participants"][x]
            end
          end
        end
      end
      return "error"
    end

    def get_champion_data_by_championID(championID)
      response = HTTParty.get('http://ddragon.leagueoflegends.com/cdn/11.15.1/data/en_US/champion.json')
      champion_list = JSON.parse(response.body)
      for champions in champion_list["data"]
        x = champions[1]["key"].to_i
        y = championID.to_i
        if x == y
          return champions[1]
        end
      end
      return "failed to find a champion with that champion ID"
    end
end