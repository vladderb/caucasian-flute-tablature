//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Kamyl (Circassian Flute) Tab Plugin - Remove Tabs
//
//  Copyright (C) 2026 Vladislav Derbenyov
//  Based on the Tin Whistle Tablature Plugin
//  Copyright (C) 2012 Werner Schweer
//  Copyright (C) 2013 - 2016 Joachim Schmitz
//  Copyright (C) 2014 Jörn Eichler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENSE
//=============================================================================

import QtQuick 2.15
import MuseScore 3.0

MuseScore {
   version: "1.6"
   description: "Remove all Kamyl tablature from the score"
   title: "Remove Kamyl Tablature"
   categoryCode: "composing-arranging-tools"

   function removeAllTabsInSegment(segment) {
      var removables = [];

      for (var i = 0; i < segment.annotations.length; i++) {
         var element = segment.annotations[i];
         
         // Удаляем все STAFF_TEXT, которые содержат кружки, знаки вопроса или цифры регистра
         if (element.type === Element.STAFF_TEXT) {
            var text = element.text;
            
            // Проверяем наличие кружков и знаков вопроса
            var isTab = text.indexOf("●") >= 0 || text.indexOf("○") >= 0 || text.indexOf("◑") >= 0 || text.indexOf("?") >= 0;
            
            // Проверяем, является ли это цифрой регистра (может содержать HTML теги)
            // Ищем одиночную цифру 0-4, возможно с HTML тегами вокруг
            var cleanText = text.replace(/<[^>]*>/g, '').trim();
            var isRegister = /^[0-4]$/.test(cleanText);
            
            if (isTab || isRegister) {
               removables.push(element);
               console.log("Removing: " + cleanText);
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
