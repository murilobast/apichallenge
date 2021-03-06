# LoL - API Challenge
This Github repo is made for LoL API Challenge @RiotGamesAPI. This was an URF specific challenge more information can be found [here](https://developer.riotgames.com/discussion/riot-games-api/show/bX8Z86bm).
<br>
The result of this project is a website which is [Lelking.com](http://www.lelking.com/) (works on mobile too!). The project is made with [Meteor](https://www.meteor.com/) and a further explanation about everything on the project and this repo is below.
## What is meteor? And why?
> Meteor is a complete open source platform for building web and mobile apps in plain JavaScript.

Well, that sums it up pretty much. CoffeeScipt was used instead of JavaScript. Sorry, all of you JavaScript freaks but you can compile it easily [here](http://js2.coffee/). Meteor is build on [NodeJS](https://nodejs.org/), which probably was used a lot in this API Challenge. NodeJS was purposely avoided because it really takes a lot of your time when writing real-time responsive apps. Time was something that was very limited and another reason was based on the fact that the app had to pull data, update the database and render the view in real-time. Fortunately everything changed after URF stopped and all the data could be pulled once.
<br>
More on Meteor and the differences between plain NodeJS and other frameworks [here](http://www.quora.com/JavaScript-Frameworks/AngularJS-Meteor-Backbone-Express-or-plain-NodeJs-When-to-use-each-one).
##Why so little code in the server folder?
>Fortunately everything changed after URF stopped and all the data could be pulled once.

The application does not need to pull any data serverside and update the database every 5 minute as it did in the beginning (you can see the old server code in the "tests" folder). Instead a script was made to pull every match from the new API Challenge[ endpoint](https://developer.riotgames.com/api/methods#!/980/3340). Another script gets the champion information, makes champion objects, updates the champion objects and finally inserts them to the database. The scripts does not run with Meteor and that is also why they are in the "tests" folder. Everything in the "tests" folder does not get executed when running Meteor. The scripts are meant to run separately.

##Quick Guide
This guide is not very friendly nor complete and it is more for the people who already has gotten their feet wet regarding NodeJS, Meteor, Git etc. Although beginners can just follow the straight forward guides on the following websites and of course use google to troubleshoot problems, information etc.

#####What to install
* [Meteor](https://www.meteor.com/install)
* [MongoDB](https://www.mongodb.org/downloads)

#####How to use
1. Clone the repository. `git clone https://github.com/murilobast/apichallenge.git`
2. Open terminal and navigate to the folder.
3. Write `npm install` - Should create the folder "node_modules"
4. Navigate to the folder "app"
5. Write `meteor` - Meteor should start running locally now.
6. Open a new terminal session.
7. Edit getMatches.coffee and getChampions.coffee where you provide your own API key.
8. Run getMatches.coffee in the terminal. `coffee getMatches.coffee`
9. Run getChampions.coffee and follow the instructions in the code. (to uncomment delete the '#') `coffee getChampions.coffee` - Run this command every time you uncomment the code.
10. Open `http://localhost:3000/` in your browser.

##Feedback
Please give us some feedback! It's very appreciated and if you're struggling trying to understand something please tweet us or send us a mail.
<br>
@Deam_me @Murilobast - Deam@Lelking.com Murilo@Lelking.com