Meteor.publish 'wins', (region, limit, skips)-> 
	Champions.find({region: region},{sort: {winrate: -1}, limit: limit, skip: skips })

Meteor.publish 'losses', (region, limit, skips)-> 
	Champions.find({region: region},{sort: {winrate: 1}, limit: limit, skip: skips })

Meteor.publish 'picks', (region, limit, skips)-> 
	Champions.find({region: region},{sort: {games: -1}, limit: limit, skip: skips })

Meteor.publish 'bans', (region, limit, skips)-> 
	Champions.find({region: region},{sort: {bans: -1}, limit: limit, skip: skips })

Meteor.publish 'champions', (region, limit, skips)-> 
	Champions.find({region: region},{limit: limit, skip: skips })