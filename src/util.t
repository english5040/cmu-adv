/* Ben Scott - bescott@andrew.cmu.edu - 2015-09-21 - CMU.ADV - util */

#include <adv3.h>
#include <en_us.h>
#include "macros.h"

/* begin mods */

// Passage template -> masterObject 'vocabWords' 'name' @location? "desc"?
// Door template 'name' @room1 @room2;

// Room template [room_list] "desc"?;
// alternate format, includes up / down, etc.
// [northwest, north, northeast] // [[NW,  U,  N,  NE],
// [west,    'roomName',   east] //  [W,  IN, OUT, E ],
// [southwest, south, southeast] //  [SW, D,   S,  SE]]

modify Goal goalState = OpenGoal;

modify YellAction {
    execAction() { mainReport('You bark as loud as you can. '); }
}

modify Thing {
    dobjFor(BarkAt) {
        verify() {
            illogical('{The dobj/he} {is} not something you can bark at. '); }
    }
}

modify Actor {
    makeProper() {
        if (isProperName==null && properName!=null) {
            name = properName;
            isProperName = true;
            initializeVocabWith(properName);
        } return name;
    }
}

class Ambience : RandomFiringScript, ShuffledEventList {
    eventPercent = 50;
}

Ambience template [eventList];

/* end mods */


/* begin events */
Events : object {
    sleep() { }

    init() {
        cmu_officer.addToAgenda(officer_agenda);
    }

    propertyset '*_limbo' {
        daemon = null;
        init() {
            user.travelTo(limbo, into_limbo, into_limbo.connectorBack(
                user.getTraveler(into_limbo), limbo));
            if (daemon_limbo==null)
                daemon_limbo = new Daemon(self,&play_limbo,2);
        }

        play() { list_limbo.doScript(); }

        stop() {
            if (daemon_limbo!=null) {
                daemon_limbo.removeEvent;
                daemon_limbo = null;
            }
        }
    }

    list_limbo : RandomFiringScript, ShuffledEventList {
        firstEvents = ['You begin to run, as fast as you can, in some direction. You get nowhere. '];
        eventList = ['The fog glowers at your plight. ',
            'You think you noticed it get slightly brighter for a moment. ',
            'The fog glowers at your plight. ',
            {: print('<b>lo! but you are saved!</b>'),
                user.reset(), Events.stop_limbo() }]
        eventPercent = 80;
    }
}

//combinedSpecialDesc : ListGroupSorted {
//  compareGroupItems(a,b) { return (a.listOrder-b.listOrder);} }



util : object {

    capitalize(s) {
        if (s.length()<1) return s.toUpper();
        return s[0].toUpper()+s.substr(1);
    }

    censor : StringPreParser {
        doParsing(str, which) {
            if (rexMatch(util.obscenities.toLower(),str)!=null) {
                util.offenses+=1;
                if (util.offenses>8) {
                    "Come back when you've classed it up a bit.";
                    finishGameMsg('You have missed the point entirely.',null); }
                else if (util.offenses>7) "Be very careful.";
                else if (util.offenses>6) "Tenacious, huh?";
                else if (util.offenses>5) "I'll do something awful if you keep this up.";
                else if (util.offenses>4) "No, you're right, this is hilarious.";
                else if (util.offenses>3) "How was middle school for you?";
                else if (util.offenses>2) "Try me.";
                else if (util.offenses>1) "Knock it off.";
                else if (util.offenses>0) "Be careful.";
                return null;
            } return str;
        }
    }

    suppressOutput : OutputFilter { filterText(tgt,src) { return ' '; } }

    obscenities = '%bfuck|shit|ass|penis|pussy|shit|damn|vagina|tit|boob|felch|cunt|blumpkin|clit|cum|semen%b';
    offenses = 0;
}

modify statusLine {
    showStatusRight() {
        "<<user.name>> - <<versionInfo.name>> - ";
        inherited();
    }
}

enum male, female;
