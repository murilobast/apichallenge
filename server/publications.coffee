Meteor.publish 'wins', (region, limit, skips)-> 
	Champions.find({region: region},{sort: {winrate: -1}, limit: limit, skip: skips })

Meteor.publish 'losses', (region, limit, skips)-> 
	Champions.find({region: region},{sort: {lossrate: -1}, limit: limit, skip: skips })

Meteor.publish 'picks', (region, limit, skips)-> 
	Champions.find({region: region},{sort: {pickrate: -1}, limit: limit, skip: skips })

Meteor.publish 'bans', (region, limit, skips)-> 
	Champions.find({region: region},{sort: {banrate: -1}, limit: limit, skip: skips })