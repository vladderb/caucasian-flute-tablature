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
   version: "2.0"
   description: "This plugin provides fingering diagrams for the Kamyl (Circassian flute)"
   title: "Kamyl Tablature"
   categoryCode: "composing-arranging-tools"

   property bool kamylFound: false

   // Kamyl tabs using Unicode circles: ● (filled) and ○ (empty)
   // Format: "hole1\nhole2\nhole3\nregister\nnoteName"
   // Index corresponds to pitch offset from base pitch (53 = F3)
   // Покрывает диапазон 53-90 для учета транспонирования MuseScore
   property variant tabs : [
      "●\n●\n●\n0\nA3",   // 0: MIDI 53 = A0 (транспонированный)
      "●\n●\n○\n0\nBb3",  // 1: MIDI 54 = Bb0 (транспонированный)
      "",                 // 2: MIDI 55 - not playable
      "",                 // 3: MIDI 56 - not playable
      "●\n●\n●\n0\nA3",   // 4: MIDI 57 = A0
      "●\n●\n○\n0\nBb3",  // 5: MIDI 58 = Bb0
      "",                 // 6: MIDI 59 - not playable
      "●\n○\n○\n0\nC4",   // 7: MIDI 60 = C0
      "",                 // 8: MIDI 61 - not playable
      "○\n○\n○\n0\nD4",   // 9: MIDI 62 = D0
      "",                 // 10: MIDI 63 - not playable
      "",                 // 11: MIDI 64 - not playable
      "●\n●\n●\n1\nA4",   // 12: MIDI 65 = A1 (транспонированный)
      "●\n●\n○\n1\nBb4",  // 13: MIDI 66 = Bb1 (транспонированный)
      "",                 // 14: MIDI 67 - not playable
      "",                 // 15: MIDI 68 - not playable
      "●\n●\n●\n1\nA4",   // 16: MIDI 69 = A1
      "●\n●\n○\n1\nBb4",  // 17: MIDI 70 = Bb1
      "",                 // 18: MIDI 71 - not playable
      "●\n○\n○\n1\nC5",   // 19: MIDI 72 = C1
      "",                 // 20: MIDI 73 - not playable
      "○\n○\n○\n1\nD5",   // 21: MIDI 74 = D1
      "",                 // 22: MIDI 75 - not playable
      "●\n●\n●\n2\nE5",   // 23: MIDI 76 = E2
      "●\n●\n○\n2\nF5",   // 24: MIDI 77 = F2
      "",                 // 25: MIDI 78 - not playable
      "●\n○\n○\n2\nG5",   // 26: MIDI 79 = G2
      "",                 // 27: MIDI 80 - not playable
      "○\n○\n○\n2\nA5",   // 28: MIDI 81 = A2
      "●\n●\n○\n3\nBb5",  // 29: MIDI 82 = Bb3
      "",                 // 30: MIDI 83 - not playable
      "●\n○\n○\n3\nC6",   // 31: MIDI 84 = C3
      "",                 // 32: MIDI 85 - not playable
      "○\n○\n○\n3\nD6",   // 33: MIDI 86 = D3
      "",                 // 34: MIDI 87 - not playable
      "●\n○\n○\n3\nC6",   // 35: MIDI 88 = C3 (транспонированный)
      "",                 // 36: MIDI 89 - not playable
      "○\n○\n○\n3\nD6"    // 37: MIDI 90 = D3 (транспонированный)
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
      if (instrument === "kamyl" || instrument === "wind.flutes.kamyl") {
         pitch = "kamyl"
      } else {
         console.log("No pitch found for instrumentId: " + instrument)
      }
      return pitch
   }

   function getBasePitch(kamylPitch) {
      var pitch = 0
      if (kamylPitch === "kamyl") {
         pitch = 53  // F3 (скорректировано для G8va)
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

   function removeDuplicatesInSegment(segment, elementToKeep) {
      var removables = [];

      for (var i = 0; i < segment.annotations.length; i++) {
         var element = segment.annotations[i];
         if (element.is(elementToKeep)) {
            continue;
         }

         if (element.offsetX == elementToKeep.offsetX && element.offsetY == elementToKeep.offsetY) {
            removables.push(element);
         }
      }

      for (var i = 0; i < removables.length; i++) {
         var element = segment.annotations[i];
         removeElement(element);
      }
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

                  removeDuplicatesInSegment(cursor.segment, text);
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
