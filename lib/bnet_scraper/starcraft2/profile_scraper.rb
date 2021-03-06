require 'bnet_scraper/starcraft2/profile'
require 'bnet_scraper/starcraft2/portrait'

module BnetScraper
  module Starcraft2
    # This pulls basic profile information for an account, as well as an array of league URLs.  This is a good starting
    # point for league scraping as it provides the league URLs necessary to do supplemental scraping.
    #
    #   scraper = BnetScraper::Starcraft2::ProfileScraper.new(url: 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/')
    #   scraper.scrape
    #   # => {
    #     bnet_id: '2377239',
    #     account: 'Demon',
    #     bnet_index: 1,
    #     race: 'Protoss',
    #     wins: '684',
    #     achievement_points: '3630',
    #     current_solo_league: 'Not Yet Ranked',
    #     highest_solo_league: 'Platinum',
    #     current_team_league: 'Not Yet Ranked',
    #     highest_team_league: 'Diamond',
    #     career_games: '1568',
    #     games_this_season: '0',
    #     most_played: '4v4',
    #     leagues: [
    #       {
    #         name: "1v1 Platinum Rank 95",
    #         id:   "96905",
    #         href: "http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/96905#current-rank"
    #       }
    #     ]
    #   }
    class ProfileScraper < BaseScraper
      attr_reader :achievement_points, :career_games, :leagues, :games_this_season, 
        :highest_solo_league, :current_solo_league, :highest_team_league,
        :current_team_league, :portrait, :terran_swarm_level, :protoss_swarm_level,
        :zerg_swarm_level, :profile

      def initialize options = {}
        super
        @leagues = []
        @profile ||= Profile.new url: profile_url
      end

      def scrape
        html = retrieve_data

        get_profile_data html
        get_portrait html
        get_solo_league_info html
        get_team_league_info html
        get_swarm_levels html
        get_campaign_completion html
        get_league_list

        @profile
      end

      # Retrieves the HTML document and feed into Nokogiri
      #
      # @return [Nokogiri::HTML] HTML document of Profile
      def retrieve_data
        response = Faraday.get profile_url

        if response.success?
          Nokogiri::HTML(response.body)
        else
          raise BnetScraper::InvalidProfileError
        end
      end

      # Scrapes the Achievement Points, Career Games, and Games this Season from Profile
      #
      # @param [Nokogiri::HTML] Profile html object to scrape from
      def get_profile_data html
        @profile.achievement_points = html.css("#profile-header h3").inner_html()
        @profile.career_games = html.css(".career-stat-block:nth-child(4) .stat-value").inner_html()
        @profile.games_this_season = html.css(".career-stat-block:nth-child(5) .stat-value").inner_html()
      end

      # Extracts background spritesheet and sprite coordinates to map to a multidimensional 
      # array of portrait names. The first index is the spritesheet page, the second index 
      # is the position within the spritesheet
      #
      # @param [Nokogiri::XML] html node
      # @return [BnetScraper::Starcraft2::Portrait] Portrait containing spritesheet information
      def get_portrait html
        @profile.portrait = Portrait.new(*extract_portrait_info(html))
      end

      # Extracts portrait information (spritesheet page, portsize size, X, Y) from HTML page
      #
      # @param [Nokogiri::XML] html node
      # @return [Fixnum, Fixnum, Fixnum, Fixnum] Array of sprite information
      def extract_portrait_info html
        html.css("#portrait .icon-frame").attr('style').to_s.scan(/url\('.+(\d+)-(\d+)\.jpg'\) -{0,1}(\d+)px -{0,1}(\d+)px/).flatten.map(&:to_i)
      end

      # Extracts the current and highest ever solo league achieved
      #
      # @param [Nokogiri::XML] html node
      def get_solo_league_info html
        @profile.highest_solo_league = get_highest_league_info :solo, html
        @profile.current_solo_league = get_current_league_info :solo, html
      end

      # Extracts the current and highest ever team league achieved
      #
      # @param [Nokogiri::XML] html node
      def get_team_league_info html
        @profile.highest_team_league = get_highest_league_info :team, html
        @profile.current_team_league = get_current_league_info :team, html
      end

      # Extracts the highest league achieved for a given league type
      #
      # @param [Symbol] league to be scraped. Values: :solo or :team
      # @param [Nokogiri::HTML] html ode to scrape
      # @return [String] League of Ladder
      def get_highest_league_info league_type, html
        if div = html.css("#best-finish-#{league_type.upcase} div")[0]
          div.children[2].inner_text.strip
        else
          "Not Yet Ranked"
        end
      end

      # Extracts the current league achieved for a given league type
      #
      # @param [Symbol] league to be scraped. Values: :solo or :team
      # @param [Nokogiri::HTML] html node to scrape
      # @return [String] League of Ladder
      def get_current_league_info league_type, html
        if div = html.css("#best-finish-#{league_type.upcase} div")[0].children[8]
          div.inner_text.strip
        else
          "Not Yet Ranked"
        end
      end

      # Extracts the HotS Swarm Levels for each race
      #
      # @param [Nokogiri::HTML] html node to scrape
      def get_swarm_levels html
        @profile.protoss_swarm_level = get_swarm_level :protoss, html
        @profile.terran_swarm_level = get_swarm_level :terran, html
        @profile.zerg_swarm_level = get_swarm_level :zerg, html
      end

      # Extracts the swarm level for a given race
      #
      # @param [Symbol] race to determine the swarm level of
      # @param [Nokogiri::HTML] html node to scrape from
      # @return [Fixnum] Swarm Level
      def get_swarm_level race, html
        level = html.css(".race-level-block.#{race} .level-value").inner_html
        level.match(/Level (\d+)/)[1].to_i
      end

      # Extracts completion level of the SC2 Campaigns
      # 
      # @param [Nokogiri::HTML] html node to scrape
      def get_campaign_completion html
        @profile.terran_campaign_completion = html.css('.campaign-wings-of-liberty .badge')[0].attr('class').split[1].to_sym
        @profile.zerg_campaign_completion = html.css('.campaign-heart-of-the-swarm .badge')[0].attr('class').split[1].to_sym
      end

      # scrapes the league list from account's league page and sets an array of URLs
      def get_league_list
        response = Faraday.get profile_url + "ladder/leagues"
        if response.success?
          html = Nokogiri::HTML(response.body)

          @profile.leagues = html.css("a[href*='#current-rank']").map do |league|
            League.new({
              name: league.inner_text().strip,
              id: league.attr('href').sub('#current-rank',''),
              href: "#{profile_url}ladder/#{league.attr('href')}"
            })
          end
        else
          raise BnetScraper::InvalidProfileError
        end
      end

      def output
         {
          bnet_id: @bnet_id,
          account: @account,
          bnet_index: @bnet_index,
          race: @race,
          current_solo_league: @current_solo_league,
          highest_solo_league: @highest_solo_league,
          current_team_league: @current_team_league,
          highest_team_league: @highest_team_league,
          career_games: @career_games,
          games_this_season: @games_this_season,
          most_played: @most_played,
          achievement_points: @achievement_points,
          leagues: @leagues,
          portrait: @portrait
        }  
      end
    end
  end
end
