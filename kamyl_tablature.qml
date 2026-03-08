//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Kamyl (Circassian Flute) Tab Plugin
//
//  Based on the Tin Whistle Tablature Plugin
//  Copyright (C) 2012 Werner Schweer
//  Copyright (C) 2013 - 2016 Joachim Schmitz
//  Copyright (C) 2014 Jörn Eichler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE
//=============================================================================

import QtQuick 2.15
import MuseScore 3.0
import Muse.UiComponents 1.0

MuseScore {
   version: "2.2"
   description: "This plugin provides fingering diagrams for the Kamyl (Circassian flute)"
   title: "Kamyl Tablature"
   categoryCode: "composing-arranging-tools"

   property bool kamylFound: false

   // Kamyl tabs using Unicode circles: ● (filled) and ○ (empty)
   // Format: "hole1\nhole2\nhole3\nregister\nnoteName"
   // Index corresponds to pitch offset from base pitch (57 = A3)
   property variant tabs : [
      "●\n●\n●\n0\nA3",   // 0: MIDI 57 = A0
      "●\n●\n○\n0\nBb3",  // 1: MIDI 58 = Bb0
      "",                 // 2: MIDI 59 - not playable
      "●\n○\n○\n0\nC4",   // 3: MIDI 60 = C0
      "",                 // 4: MIDI 61 - not playable
      "○\n○\n○\n0\nD4",   // 5: MIDI 62 = D0
      "",                 // 6: MIDI 63 - not playable (dead zone)
      "",                 // 7: MIDI 64 - not playable (dead zone)
      "",                 // 8: MIDI 65 - not playable (dead zone)
      "",                 // 9: MIDI 66 - not playable (dead zone)
      "",                 // 10: MIDI 67 - not playable (dead zone)
      "",                 // 11: MIDI 68 - not playable (dead zone)
      "●\n●\n●\n1\nA4",   // 12: MIDI 69 = A1
      "●\n●\n○\n1\nBb4",  // 13: MIDI 70 = Bb1
      "",                 // 14: MIDI 71 - not playable
      "●\n○\n○\n1\nC5",   // 15: MIDI 72 = C1
      "",                 // 16: MIDI 73 - not playable
      "○\n○\n○\n1\nD5",   // 17: MIDI 74 = D1
      "",                 // 18: MIDI 75 - not playable
      "●\n●\n●\n2\nE5",   // 19: MIDI 76 = E2
      "●\n●\n○\n2\nF5",   // 20: MIDI 77 = F2
      "",                 // 21: MIDI 78 - not playable
      "●\n○\n○\n2\nG5",   // 22: MIDI 79 = G2
      "",                 // 23: MIDI 80 - not playable
      "○\n○\n○\n2\nA5",   // 24: MIDI 81 = A2
      "●\n●\n○\n3\nBb5",  // 25: MIDI 82 = Bb3
      "",                 // 26: MIDI 83 - not playable
      "●\n○\n○\n3\nC6",   // 27: MIDI 84 = C3
      "",                 // 28: MIDI 85 - not playable
      "○\n○\n○\n3\nD6"    // 29: MIDI 86 = D3
   ]

   MessageDialog {
      id: noKamylsFound
      title: "No Staffs use a Kamyl"
      text: "No selected staff in the current score uses a Kamyl (Circassian flute) instrument.\n" +
            "Use tab \"Instruments -> Add\" to select instruments"

      onAccepted: {
         quit()
      }

      visible: false;
   }

   function selectKamylTabCharacter (pitch, basePitch) {
      var tabText = ""
      var index = pitch - basePitch
      if (index < 0) {
         console.log("Skipped note as it was too low, pitch : " + pitch)
         return tabText
      }
      if (index >= tabs.length) {
         console.log("Skipped note as it was too high, pitch : " + pitch)
         return tabText
      }
      tabText = tabs[index]
      console.log("Pitch " + pitch + " -> index " + index + " -> tab: " + (tabText !== "" ? "found" : "empty"))
      return tabText
   }

   function setTabCharacterFont (text, tabSize) {
      text.fontFace = "Arial"
      text.fontSize = tabSize
      // Vertical align to top
      text.align = 0
      // Place text below the staff
      text.placement = Placement.BELOW
      // Turn off note relative placement
      text.autoplace = false
   }

   function getKamylPitch(instrument) {
      var pitch = "none"
      // Работаем с любым инструментом - просто применяем табулатуру камыля
      if (instrument === "kamyl" || instrument === "wind.flutes.kamyl" || !instrument || instrument === "") {
         pitch = "kamyl"
      } else {
         // Для всех остальных инструментов тоже применяем табулатуру камыля
         console.log("Applying kamyl tablature to instrument: " + instrument)
         pitch = "kamyl"
      }
      return pitch
   }

   function getBasePitch(kamylPitch) {
      var pitch = 0
      if (kamylPitch === "kamyl") {
         pitch = 57  // A3 (базовая нота камыля)
      } else {
         console.log("No base pitch found for: " + kamylPitch)
      }
      return pitch
   }

   function getTabOffset(kamylPitch) {
      var offset = 0
      if (kamylPitch === "kamyl") {
         offset = 8.0  // Увеличено с 7.0 до 8.0 - табы ещё ниже
      } else {
         console.log("No offset found for: " + kamylPitch)
      }
      return offset
   }

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
      console.log("All tabs removed")
   }

   function renderKamylTablature () {
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
         console.log("Full score staves " + startStaff + " - " + endStaff)
      } else {
         startStaff = cursor.staffIdx
         cursor.rewind(2)
         if (cursor.tick === 0) {
            endTick = curScore.lastSegment.tick + 1
         } else {
            endTick = cursor.tick
         }
         endStaff = cursor.staffIdx
         console.log("Selected staves " + startStaff + " - " + endStaff + " - " + endTick)
      }

      var basePitch
      var pitch
      var tabOffsetY
      
      for (var staff = startStaff; staff <= endStaff; staff++) {

         var instrument;
         var hasInstrumentId = curScore.staves[staff].part.instrumentId !== undefined;
         if (hasInstrumentId) {
            instrument = curScore.staves[staff].part.instrumentId
         } else {
            instrument = "kamyl"
         }

         var kamylPitch = getKamylPitch(instrument)
         if (kamylPitch != "none") {
            kamylFound = true;
            basePitch = getBasePitch(kamylPitch)
            tabOffsetY = getTabOffset(kamylPitch)
            if (curScore.hasLyrics) {
               tabOffsetY += 2.8
            }
         } else {
            basePitch = 0
            tabOffsetY = 0
            console.log("Skipped staff " + staff + " for instrumentId: " + instrument)
            continue
         }

         console.log("Staff " + staff + " kamyl type: " + instrument + " with base pitch: " + basePitch + " and offset: " + tabOffsetY)

         cursor.voice = 0
         cursor.rewind(1)
         cursor.staffIdx = staff

         if (fullScore)
            cursor.rewind(0)

         var tabFontSizeNormal = 8   // Уменьшено с 10 до 8 - кружки ещё ближе
         var tabFontSizeGrace = 6    // Уменьшено с 8 до 6

         while (cursor.segment && (fullScore || cursor.tick < endTick)) {
            if (cursor.element && cursor.element.type === Element.CHORD) {
               var text = newElement(Element.STAFF_TEXT);

               // Process main note (no tie check, no repeat check)
               var chord = cursor.element;
               var pitch = chord.notes[0].pitch;

               text.text = selectKamylTabCharacter(pitch, basePitch)
               
               if (text.text !== "") {
                  // Удаляем все старые табы в этом сегменте перед добавлением новых
                  removeAllTabsInSegment(cursor.segment);
                  
                  // Разделяем таб на основную часть и название ноты
                  var tabParts = text.text.split("\n")
                  var noteName = tabParts[tabParts.length - 1]  // Последняя строка - название ноты
                  var mainTab = ""
                  for (var i = 0; i < tabParts.length - 1; i++) {
                     mainTab += tabParts[i]
                     if (i < tabParts.length - 2) {
                        mainTab += "\n"
                     }
                  }
                  
                  // Основной таб (кружки + регистр)
                  text.text = mainTab
                  cursor.add(text)
                  setTabCharacterFont(text, tabFontSizeNormal)
                  text.offsetY = tabOffsetY
                  text.offsetX = 0.5

                  // Название ноты отдельно, меньшим шрифтом
                  // Позиция рассчитывается от последней строки основного таба
                  // Основной таб: 3 кружка + регистр = 4 строки
                  var noteText = newElement(Element.STAFF_TEXT)
                  noteText.text = noteName
                  cursor.add(noteText)
                  noteText.fontSize = 5  // Фиксированный размер 5
                  noteText.fontFace = "Arial"
                  noteText.align = 0
                  noteText.placement = Placement.BELOW
                  noteText.autoplace = false
                  // offsetY = базовое смещение + высота 4 строк (уменьшенный коэффициент)
                  noteText.offsetY = tabOffsetY + (tabFontSizeNormal * 0.25 * 4)
                  noteText.offsetX = 0.5
               }

               text = newElement(Element.STAFF_TEXT)
            }

            cursor.next()
         }
      }

      curScore.endCmd();
      quit()
   }

   onRun: {
      console.log("Hello Kamyl tablature")

      if (typeof curScore === 'undefined') {
         quit()
      }

      renderKamylTablature()
      
      if (!kamylFound) {
         noKamylsFound.open()
      }

      quit()
   }
}
