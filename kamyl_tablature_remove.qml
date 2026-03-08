//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Kamyl (Circassian Flute) Tab Plugin - Remove Tabs
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE
//=============================================================================

import QtQuick 2.15
import MuseScore 3.0

MuseScore {
   version: "1.2"
   description: "Remove all Kamyl tablature from the score"
   title: "Remove Kamyl Tablature"
   categoryCode: "composing-arranging-tools"

   function removeAllTabsInSegment(segment) {
      var removables = [];

      for (var i = 0; i < segment.annotations.length; i++) {
         var element = segment.annotations[i];
         
         // Удаляем все STAFF_TEXT, которые содержат кружки или являются названиями нот
         if (element.type === Element.STAFF_TEXT) {
            var text = element.text;
            var isTab = text.indexOf("●") >= 0 || text.indexOf("○") >= 0;
            
            // Названия нот могут содержать HTML теги: <font size="5"/><font face="Arial"/>A3
            // Проверяем, содержит ли текст паттерн названия ноты (буква A-G + опционально b/# + цифра)
            var notePattern = /[A-G][b#]?\d/;
            var isNoteName = notePattern.test(text);
            
            // Дополнительная проверка: размер шрифта 5 или offsetY > 10
            var isSmallFont = element.size === 5 || element.fontSize === 5;
            var isBelowStaff = element.offsetY > 10;
            
            if (isTab || (isNoteName && (isSmallFont || isBelowStaff))) {
               removables.push(element);
               console.log("Removing: " + text.substring(0, 50) + " (offsetY: " + element.offsetY + ", size: " + element.size + ")");
            }
         }
      }

      for (var i = 0; i < removables.length; i++) {
         removeElement(removables[i]);
      }
   }

   function removeAllTabs() {
      curScore.startCmd();

      var cursor = curScore.newCursor();
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;
      cursor.rewind(1)
      
      if (!cursor.segment) {
         fullScore = true
         startStaff = 0;
         endStaff  = curScore.nstaves - 1;
         console.log("Removing tabs from full score, staves " + startStaff + " - " + endStaff)
      } else {
         startStaff = cursor.staffIdx
         cursor.rewind(2)
         if (cursor.tick === 0) {
            endTick = curScore.lastSegment.tick + 1
         } else {
            endTick = cursor.tick
         }
         endStaff = cursor.staffIdx
         console.log("Removing tabs from selected staves " + startStaff + " - " + endStaff)
      }

      for (var staff = startStaff; staff <= endStaff; staff++) {
         cursor.voice = 0
         cursor.rewind(1)
         cursor.staffIdx = staff

         if (fullScore)
            cursor.rewind(0)

         while (cursor.segment && (fullScore || cursor.tick < endTick)) {
            removeAllTabsInSegment(cursor.segment);
            cursor.next()
         }
      }

      curScore.endCmd();
      console.log("All Kamyl tabs removed")
   }

   onRun: {
      console.log("Remove Kamyl tablature")

      if (typeof curScore === 'undefined') {
         quit()
      }

      removeAllTabs()
      quit()
   }
}
