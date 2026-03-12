//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Kamyl (Circassian Flute) Tab Plugin
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
import Muse.UiComponents 1.0

MuseScore {
   version: "1.2"
   description: "This plugin provides fingering diagrams for the Kamyl (Circassian flute)"
   title: "Kamyl Tablature"
   categoryCode: "composing-arranging-tools"

   property bool kamylFound: false

   // Kamyl tabs using Unicode circles:
   // ● (U+25CF) - filled circle (closed hole)
   // ○ (U+25CB) - empty circle (open hole)
   // ◑ (U+25D1) - half-closed hole (right half black)
   // Format: "hole1\nhole2\nhole3\nregister\nnoteName"
   // Index corresponds to pitch offset from base pitch (53 = F3, with G8va sounds as A3)
   property variant tabs : [
      "",                 // 0: MIDI 53 - not playable
      "",                 // 1: MIDI 54 - not playable
      "",                 // 2: MIDI 55 - not playable
      "",                 // 3: MIDI 56 - not playable
      "●\n●\n●\n0\nA3",   // 4: MIDI 57 = A0
      "●\n●\n○\n0\nBb3",  // 5: MIDI 58 = Bb0
      "●\n◑\n○\n0\nB3",   // 6: MIDI 59 = B natural (хроматизм)
      "●\n○\n○\n0\nC4",   // 7: MIDI 60 = C0
      "◑\n○\n○\n0\nC#4",  // 8: MIDI 61 = C# / Db (хроматизм)
      "○\n○\n○\n0\nD4",   // 9: MIDI 62 = D0
      "",                 // 10: MIDI 63 - not playable (dead zone)
      "",                 // 11: MIDI 64 - not playable (dead zone)
      "",                 // 12: MIDI 65 - not playable (dead zone)
      "",                 // 13: MIDI 66 - not playable (dead zone)
      "",                 // 14: MIDI 67 - not playable (dead zone)
      "",                 // 15: MIDI 68 - not playable (dead zone)
      "●\n●\n●\n1\nA4",   // 16: MIDI 69 = A1
      "●\n●\n○\n1\nBb4",  // 17: MIDI 70 = Bb1
      "●\n◑\n○\n1\nB4",   // 18: MIDI 71 = B natural (хроматизм)
      "●\n○\n○\n1\nC5",   // 19: MIDI 72 = C1
      "◑\n○\n○\n1\nC#5",  // 20: MIDI 73 = C# / Db (хроматизм)
      "○\n○\n○\n1\nD5",   // 21: MIDI 74 = D1
      "",                 // 22: MIDI 75 - not playable
      "●\n●\n●\n2\nE5",   // 23: MIDI 76 = E2
      "●\n●\n○\n2\nF5",   // 24: MIDI 77 = F2
      "●\n◑\n○\n2\nF#5",  // 25: MIDI 78 = F# (хроматизм)
      "●\n○\n○\n2\nG5",   // 26: MIDI 79 = G2
      "◑\n○\n○\n2\nG#5",  // 27: MIDI 80 = G# / Ab (хроматизм)
      "○\n○\n○\n2\nA5",   // 28: MIDI 81 = A2
      "●\n●\n○\n3\nBb5",  // 29: MIDI 82 = Bb3
      "●\n◑\n○\n3\nB5",   // 30: MIDI 83 = B natural (хроматизм)
      "●\n○\n○\n3\nC6",   // 31: MIDI 84 = C3
      "◑\n○\n○\n3\nC#6",  // 32: MIDI 85 = C# / Db (хроматизм)
      "○\n●\n○\n3\nD6",   // 33: MIDI 86 = D3
      "●\n●\n●\n4\nD#6",  // 34: MIDI 87 = D#6 регистр 4 (хроматизм, transposed from C#7)
      "",                 // 35: MIDI 88 - not playable
      "",                 // 36: MIDI 89 - not playable
      "",                 // 37: MIDI 90 - not playable
      "",                 // 38: MIDI 91 - not playable
      "",                 // 39: MIDI 92 - not playable
      "",                 // 40: MIDI 93 - not playable
      "",                 // 41: MIDI 94 - not playable
      "",                 // 42: MIDI 95 - not playable
      "",                 // 43: MIDI 96 - not playable
      ""                  // 44: MIDI 97 - not playable (was C#7 before G8va transposition)
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
      
      // Определяем название ноты
      var noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "Bb", "B"]
      var octave = Math.floor(pitch / 12) - 1
      var noteName = noteNames[pitch % 12] + octave
      
      if (index < 0) {
         console.log("Skipped note as it was too low, pitch : " + pitch)
         // Для нот вне диапазона показываем ???
         return "?\n?\n?\n?\n" + noteName
      }
      if (index >= tabs.length) {
         console.log("Skipped note as it was too high, pitch : " + pitch)
         // Для нот вне диапазона показываем ???
         return "?\n?\n?\n?\n" + noteName
      }
      tabText = tabs[index]
      // Если таб пустой (нота не играется на камыле), показываем ???
      if (tabText === "") {
         console.log("Pitch " + pitch + " -> index " + index + " -> no tab available, showing ???")
         return "?\n?\n?\n?\n" + noteName
      }
      console.log("Pitch " + pitch + " -> index " + index + " -> tab: found")
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
      // Уменьшаем межстрочный интервал для кружков
      text.lineSpacing = 0.8
   }

   function getKamylPitch(instrument) {
      var pitch = "none"
      // Работаем только с инструментом камыль
      if (instrument === "kamyl" || instrument === "wind.flutes.kamyl") {
         pitch = "kamyl"
      } else {
         console.log("Skipping instrument: " + instrument + " (not kamyl)")
      }
      return pitch
   }

   function getBasePitch(kamylPitch) {
      var pitch = 0
      if (kamylPitch === "kamyl") {
         pitch = 53  // F3 (с учетом G8va звучит как A3)
      } else {
         console.log("No base pitch found for: " + kamylPitch)
      }
      return pitch
   }

   function getTabOffset(kamylPitch) {
      var offset = 0
      if (kamylPitch === "kamyl") {
         offset = 7.0  // Уменьшено с 8.0 до 7.0 - табы выше
      } else {
         console.log("No offset found for: " + kamylPitch)
      }
      return offset
   }

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

         var tabFontSizeNormal = 14   // Размер кружков увеличен до 14
         var tabFontSizeRegister = 7  // Размер цифры регистра

         while (cursor.segment && (fullScore || cursor.tick < endTick)) {
            if (cursor.element && cursor.element.type === Element.CHORD) {
               // Удаляем все старые табы в этом сегменте ПЕРЕД проверкой новых
               removeAllTabsInSegment(cursor.segment);
               
               var text = newElement(Element.STAFF_TEXT);

               // Process main note (no tie check, no repeat check)
               var chord = cursor.element;
               var pitch = chord.notes[0].pitch;

               text.text = selectKamylTabCharacter(pitch, basePitch)
               
               if (text.text !== "") {
                  // Разделяем таб на кружки, регистр и название ноты
                  var tabParts = text.text.split("\n")
                  // tabParts[0-2] = кружки, tabParts[3] = регистр, tabParts[4] = название ноты
                  
                  var holes = tabParts[0] + "\n" + tabParts[1] + "\n" + tabParts[2]
                  var register = tabParts[3]
                  
                  // Кружки (отверстия)
                  text.text = holes
                  cursor.add(text)
                  setTabCharacterFont(text, tabFontSizeNormal)
                  text.offsetY = tabOffsetY
                  text.offsetX = 0.5

                  // Цифра регистра отдельно, меньшим шрифтом, центрированная
                  var registerText = newElement(Element.STAFF_TEXT)
                  registerText.text = register
                  cursor.add(registerText)
                  registerText.fontSize = tabFontSizeRegister
                  registerText.fontFace = "Arial"
                  registerText.align = 1  // Центрирование (0=left, 1=center, 2=right)
                  registerText.placement = Placement.BELOW
                  registerText.autoplace = false
                  // offsetY = базовое смещение + высота 3 кружков (с учетом уменьшенного межстрочного интервала)
                  registerText.offsetY = tabOffsetY + (tabFontSizeNormal * 0.8 * 0.20 * 3) + 1.0
                  registerText.offsetX = 1.4  // Увеличено смещение вправо для выравнивания с кружками
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
