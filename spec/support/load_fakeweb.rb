require 'fakeweb'

profile_html      = File.read File.dirname(__FILE__) + '/profile.html' 
leagues_html      = File.read File.dirname(__FILE__) + '/leagues.html' 
league_html       = File.read File.dirname(__FILE__) + '/league.html' 
achievements_html = File.read File.dirname(__FILE__) + '/achievements.html'
matches_html      = File.read File.dirname(__FILE__) + '/matches.html'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/', body: profile_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/leagues', body: leagues_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/12345', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/96905', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/96716', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/98162', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/97369', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/96828', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/97985', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/98523', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/96863', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/97250', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/96830', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/98336', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/98936', body: league_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/achievements/', body: achievements_html, status: 200, content_type: 'text/html'
FakeWeb.register_uri :get, 'http://us.battle.net/sc2/en/profile/2377239/1/Demon/matches', body: matches_html, status: 200, content_type: 'text/html'
