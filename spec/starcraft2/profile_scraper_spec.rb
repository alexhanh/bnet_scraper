require 'spec_helper'

describe BnetScraper::Starcraft2::ProfileScraper do
  it_behaves_like 'an SC2 Scraper' do
    let(:scraper_class) { BnetScraper::Starcraft2::BaseScraper }
    let(:subject) { scraper_class.new(url: 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/') }
  end

  let(:scraper) { BnetScraper::Starcraft2::ProfileScraper.new(bnet_id: '2377239', account: 'Demon') }

  describe '#scrape' do
    subject do
      VCR.use_cassette('demon_profile', record: :new_episodes) do
        scraper.scrape
      end
    end

    its(:achievement_points) { should == '3680' }
    its(:current_solo_league) { should == 'Platinum' }
    its(:highest_solo_league) { should == 'Platinum' }
    its(:current_team_league) { should == 'Diamond' }
    its(:highest_team_league) { should == 'Master' }
    its(:career_games) { should == '1719' }
    its(:games_this_season) { should == '114' }
    its(:portrait) { should == 'Mohandar' }
    its(:terran_swarm_level) { should == 0 }
    its(:protoss_swarm_level) { should == 0 }
    its(:zerg_swarm_level) { should == 0 }

    context 'first league ever' do
      let(:scraper) { BnetScraper::Starcraft2::ProfileScraper.new url: 'http://us.battle.net/sc2/en/profile/3513522/1/Heritic/' }

      subject do
        VCR.use_cassette('new_league', record: :new_episodes) do
          scraper.scrape
        end
      end

      its(:current_solo_league) { should == 'Bronze' }
      its(:highest_solo_league) { should == 'Bronze' }
      its(:current_team_league) { should == 'Bronze' }
      its(:highest_team_league) { should == 'Silver' }
    end

    context 'campaign completion' do
      let(:profile) { subject }
      it 'returns hash of highest difficulty completed for each campaign' do
        profile.campaign_completion.should be_instance_of Hash
        profile.campaign_completion[:terran].should == :brutal
        profile.campaign_completion[:zerg].should == :normal
      end
    end
  end

  describe 'get_league_list' do
    before do
      VCR.use_cassette('demon_profile_leagues') do
        scraper.get_league_list
      end
    end

    subject { scraper.profile.leagues }
    it { should have(8).leagues }
  end

  describe '#scrape' do
    it 'should return InvalidProfileError if response is 404' do
      VCR.use_cassette('profile_invalid') do
        scraper = BnetScraper::Starcraft2::ProfileScraper.new url: 'http://us.battle.net/sc2/en/profile/2377239/1/SomeDude/'
        expect { scraper.scrape }.to raise_error(BnetScraper::InvalidProfileError)
      end
    end

    context 'account that has not laddered' do
      let(:scraper) {BnetScraper::Starcraft2::ProfileScraper.new(url: 'http://us.battle.net/sc2/en/profile/3354437/1/ClarkeKent/') }
      before do
        VCR.use_cassette('profile_not_laddered') do
          scraper.scrape
        end
      end
      
      it 'should have an empty array of leagues' do
        scraper.leagues.should == []
      end
    end
  end
end
