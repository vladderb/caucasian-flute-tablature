//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Kamyl (Circassian Flute) Tab Plugin - Remove Tabs
//
//  Copyright (C) 2026 Vladislav Derbenyov
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENSE
//=============================================================================

import QtQuick 2.0
import MuseScore 3.0

MuseScore {
   version: "1.2"
   description: "Remove Kamyl fingering tablature"
   menuPath: "Plugins.Remove Kamyl Tablature"

   function removeAllTabsInSegment(segment) {
      var i = 0
      while (i < segment.annotations.length) {
         var el = segment.annotations[i]
         if (el.type === Element.STAFF_TEXT) {
            var txt = el.text
            var isTab = txt.indexOf("●") >= 0 || txt.indexOf("○") >= 0 || txt.indexOf("◑") >= 0 || txt.indexOf("?") >= 0
            
            var clean = txt.replace(/<[^>]*>/g, '').trim()
            var isRegister = /^[0-4]$/.test(clean)
            
            if (isTab || isRegister) {
               removeElement(el)
               continue
            }
         }
         i++
      }
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
            removeAllTabsInSegment(cursor.segment)
            cursor.next()
         }
      }

      curScore.endCmd()
      Qt.quit()
   }
}
