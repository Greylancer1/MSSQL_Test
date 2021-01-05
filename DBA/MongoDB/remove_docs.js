var date = new Date();
var daysToDeletion = 120;
var deletionDate = new Date(date.setDate(date.getDate() - daysToDeletion));

printjson(deletionDate);

var db = db.getSiblingDB('db')
db.getMongo().setSlaveOk();

printjson(db.messages.find({insertDate : {$lt : deletionDate}}).count());

//delete old Messages:
db.messages.remove({insertDate : {$lt : deletionDate}});