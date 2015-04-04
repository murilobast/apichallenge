var bans = Bans.findOne().bans;
bans.sort();
var current = null;
var cnt = 0;
var topbans = []
for (var i = 0; i < bans.length; i++) {
    if (bans[i] != current) {
        if (cnt > 0) {
        	topbans.push({championId: current, count: cnt});
        }
        current = bans[i];
        cnt = 1;
    } else {
        cnt++;
    }
}
if (cnt > 0) {
    topbans.push({championId: current, count: cnt});
}
topbans.sort(function(a, b){return a.count-b.count});
console.log(topbans);