import QtQuick 2.0
import MuseScore 3.0

MuseScore {
   version: "1.2"
   description: "Add Kamyl fingering tablature"
   menuPath: "Plugins.Kamyl Tablature"

   property variant tabs : [
      "",                 // 0: MIDI 53
      "",                 // 1: MIDI 54
      "",                 // 2: MIDI 55
      "",                 // 3: MIDI 56
      "●\n●\n●\n0\nA3",   // 4: MIDI 57
      "●\n●\n○\n0\nBb3",  // 5: MIDI 58
      "●\n◑\n○\n0\nB3",   // 6: MIDI 59
      "●\n○\n○\n0\nC4",   // 7: MIDI 60
      "◑\n○\n○\n0\nC#4",  // 8: MIDI 61
      "○\n○\n○\n0\nD4",   // 9: MIDI 62
      "", "", "", "", "", "",
      "●\n●\n●\n1\nA4",   // 16: MIDI 69
      "●\n●\n○\n1\nBb4",  // 17: MIDI 70
      "●\n◑\n○\n1\nB4",   // 18: MIDI 71
      "●\n○\n○\n1\nC5",   // 19: MIDI 72
      "◑\n○\n○\n1\nC#5",  // 20: MIDI 73
      "○\n○\n○\n1\nD5",   // 21: MIDI 74
      "",
      "●\n●\n●\n2\nE5",   // 23: MIDI 76
      "●\n●\n○\n2\nF5",   // 24: MIDI 77
      "●\n◑\n○\n2\nF#5",  // 25: MIDI 78
      "●\n○\n○\n2\nG5",   // 26: MIDI 79
      "◑\n○\n○\n2\nG#5",  // 27: MIDI 80
      "○\n○\n○\n2\nA5",   // 28: MIDI 81
      "●\n●\n○\n3\nBb5",  // 29: MIDI 82
      "●\n◑\n○\n3\nB5",   // 30: MIDI 83
      "●\n○\n○\n3\nC6",   // 31: MIDI 84
      "◑\n○\n○\n3\nC#6",  // 32: MIDI 85
      "○\n●\n○\n3\nD6",   // 33: MIDI 86
      "●\n●\n●\n4\nD#6",  // 34: MIDI 87
      "", "", "", "", "", "", "", "", ""
   ]

   function removeAllTabsInSegment(segment) {
      var i = 0
      while (i < segment.annotations.length) {
         var el = segment.annotations[i]
         if (el.type === Element.STAFF_TEXT) {
            var txt = el.text
            if (txt.indexOf("●") >= 0 || txt.indexOf("○") >= 0 || txt.indexOf("◑") >= 0 || txt.indexOf("?") >= 0) {
               removeElement(el)
               continue
            }
            var clean = txt.replace(/<[^>]*>/g, '').trim()
            if (/^[0-4]$/.test(clean)) {
               removeElement(el)
               continue
            }
         }
         i++
      }
   }

   function getTabCharacter(pitch) {
      var index = pitch - 53
      if (index < 0 || index >= tabs.length)
         return ""
      return tabs[index]
   }

   onRun: {
      if (typeof curScore === 'undefined' || curScore == null) {
         Qt.quit()
         return
      }

      curScore.startCmd()
      var cursor = curScore.newCursor()
      cursor.rewind(1)

      var startStaff = 0
      var endStaff = curScore.nstaves - 1

      if (cursor.segment) {
         startStaff = cursor.staffIdx
         cursor.rewind(2)
         endStaff = cursor.staffIdx
      }

      for (var staff = startStaff; staff <= endStaff; staff++) {
         cursor.staffIdx = staff
         cursor.voice = 0
         cursor.rewind(1)

         while (cursor.segment) {
            if (cursor.element && cursor.element.type === Element.CHORD) {
               removeAllTabsInSegment(cursor.segment)

               var pitch = cursor.element.notes[0].pitch
               var tab = getTabCharacter(pitch)

               if (tab !== "") {
                  var parts = tab.split("\n")
                  var holes = parts[0] + "\n" + parts[1] + "\n" + parts[2]
                  var register = parts[3]

                  var text1 = newElement(Element.STAFF_TEXT)
                  text1.text = holes
                  text1.fontFace = "Arial"
                  text1.fontSize = 14
                  text1.placement = Placement.BELOW
                  text1.autoplace = false
                  text1.offsetY = 7.0
                  text1.offsetX = 0.5
                  text1.lineSpacing = 0.8
                  cursor.add(text1)

                  var text2 = newElement(Element.STAFF_TEXT)
                  text2.text = register
                  text2.fontSize = 7
                  text2.fontFace = "Arial"
                  text2.align = 1
                  text2.placement = Placement.BELOW
                  text2.autoplace = false
                  text2.offsetY = 7.0 + (14 * 0.8 * 0.20 * 3) + 1.0
                  text2.offsetX = 1.4
                  cursor.add(text2)
               }
            }
            cursor.next()
         }
      }

      curScore.endCmd()
      Qt.quit()
   }
}
