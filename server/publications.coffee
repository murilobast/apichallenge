Meteor.publish 'champions', (region, sort, limit, skips)-> 
	Champions.find({region: region},{sort: sort, limit: limit, skip: skips })