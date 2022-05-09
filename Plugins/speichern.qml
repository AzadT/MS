import MuseScore 3.0

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0

MuseScore {
      menuPath: "Plugins.Übungsdateien exportieren"
      description: "Exportiere Übungsdateien, mit Auswahl für die Aufteilung der Stimmgruppen."
      version: "1.0"

      pluginType: "dock"
      dockArea:   "left"

      implicitWidth:  200
      implicitHeight: 400

      id: exportDialog

      onRun: {
            if(typeof curScore === 'undefined') {
                  console.log("no active score found");
                  Qt.quit();
            }
      }

      property variant channelExport : 0 // 0, wenn nicht als Kanal x exportiert werden soll, 1 wenn es als Kanal x exportiert werden soll.
      property variant numberOfSopranoVoices : 2
      property variant numberOfAltVoices : 2
      property variant numberOfTenorVoices : 2
      property variant numberOfBassVoices : 2
      

      function countChannels(){
            var numChannels = 0;
            var parts = curScore.parts;
            
            for (var i = 0; i < parts.length; ++i) {
                  var part = parts[i]
                  var instrs = part.instruments;
                  for (var j = 0; j < instrs.length; ++j) {
                        var instr = instrs[j]
                        var channels = instr.channels;
                        for (var k = 0; k < channels.length; ++k) {
                              numChannels = numChannels + 1;
                        }
                  }
            }
            return numChannels;
      }
      
      // 0-indizierter Kanalindex als Parameter. Wenn der Index auf -1 gesetzt wird, werden alle auf die Ausgangslautstärke gestellt
      function setVolume(loud_channel_index){
            var counter = 0;
            var parts = curScore.parts;
            for (var i = 0; i < parts.length; ++i) {
                  var part = parts[i];
                  var instrs = part.instruments;
                  for (var j = 0; j < instrs.length; ++j) {
                        var instr = instrs[j];
                        var channels = instr.channels;
                        for (var k = 0; k < channels.length; ++k) {
                              var channel = channels[k];
                              if (loud_channel_index == counter){
                                    channel.volume = 127;
                              } else if (loud_channel_index >= 0){
                                    channel.volume = 40;
                              } else {
                                    channel.volume = 127;
                              }
                              counter = counter + 1;
                        }
                  }
            }
      }

      function getScorePath(){
            return curScore.path.slice(0,-5);
      }

      // Wenn als Kanal exportiert werden soll: Path + " Kanal index"
      // Andernfalls, wenn etwa SSATTB: S1 S2 A T1 T2 B
      function channelIndexToFilename(path,index) {
            if (index < 0) {
                  return path + " Fehler";
            }

            if (exportAsChannels == 1) {
                  return path + " Kanal " + String(index + 1);
            }

            var voiceArray = [];
            if (numberOfSopranoVoices == 1) {
                  voiceArray.push("S");
            } else {     
                  for (var i = 0; i < numberOfSopranoVoices; ++i) {
                        voiceArray.push("S" + String(i + 1));
                  }
            }

            if (numberOfAltVoices == 1) {
                  voiceArray.push("A");
            } else {     
                  for (var i = 0; i < numberOfAltVoices; ++i) {
                        voiceArray.push("A" + String(i + 1));
                  }
            }

            if (numberOfTenorVoices == 1) {
                  voiceArray.push("T");
            } else {     
                  for (var i = 0; i < numberOfTenorVoices; ++i) {
                        voiceArray.push("T" + String(i + 1));
                  }
            }

            if (numberOfBassVoices == 1) {
                  voiceArray.push("B");
            } else {     
                  for (var i = 0; i < numberOfBassVoices; ++i) {
                        voiceArray.push("B" + String(i + 1));
                  }
            }

            var voiceName = "";

            if (index >= voiceArray.length) {
                  voiceName = " Kanal " + String(index + 1)
            } else {
                  voiceName = " " + voiceArray[index];
            }

            return path + voiceName;
      }

      function saveChannel(i) {
            setVolume(i);
            writeScore(curScore,channelIndexToFilename(getScorePath(),i),"mp3");
            setVolume(-1);
      }
      
      function exportMP3(){
            var numChannels = countChannels();
            for (var i = 0; i < numChannels; i++){
                  saveChannel(i);
            }
            Qt.quit();
      }
      
      
      function updateSettings() {
            for (var i = 0; i < exportAsChannels.buttonList.length; i++) {
                  var s = exportAsChannels.buttonList[i];
                  if (s.checked) {
                        channelExport = -(i-1);
                        break;
                  }
            }

            for (var i = 0; i < numberOfSoprano.buttonList.length; i++) {
                  if (numberOfSoprano.buttonList[i].checked) {
                        numberOfSopranoVoices = numberOfSoprano.buttonList.length - i;
                        break;
                  }
            }

            for (var i = 0; i < numberOfAlt.buttonList.length; i++) {
                  if (numberOfAlt.buttonList[i].checked) {
                        numberOfAltVoices = numberOfAlt.buttonList.length - i;
                        break;
                  }
            }

            for (var i = 0; i < numberOfTenor.buttonList.length; i++) {
                  if (numberOfTenor.buttonList[i].checked) {
                        numberOfTenorVoices = numberOfTenor.buttonList.length - i;
                        break;
                  }
            }

            for (var i = 0; i < numberOfBass.buttonList.length; i++) {
                  if (numberOfBass.buttonList[i].checked) {
                        numberOfBassVoices = numberOfBass.buttonList.length - i;
                        break;
                  }
            }
      }

      ColumnLayout {
      // Left: column of note names
      // Right: radio buttons in flat/nat/sharp positions
      id: radioVals
      anchors.left: pedalPositions.right

      RowLayout {
        id: flatRow1
        spacing: 20
        Text  { text:  "  "; font.bold: true }

      }

      RowLayout {
        id: exportAsChannels
        spacing: 20
        Text  { text:  "  Ignoriere Stimmaufteilung:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: exportAsChannels;text: "Ja"; exclusiveGroup: rowA },
          RadioButton { parent: exportAsChannels;text: "Nein"; exclusiveGroup: rowA ;checked: true }
        ]
      }
      
      RowLayout {
        id: numberOfSoprano
        spacing: 20
        Text  { text:  "  Anzahl Sopranstimmen:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: numberOfSoprano;text: "3"; exclusiveGroup: rowB },
          RadioButton { parent: numberOfSoprano;text: "2"; exclusiveGroup: rowB },
          RadioButton { parent: numberOfSoprano;text: "1"; exclusiveGroup: rowB ;checked: true }
        ]
      }
      
      RowLayout {
        id: numberOfAlt
        spacing: 20
        Text  { text:  "  Anzahl Altstimmen:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: numberOfAlt;text: "3"; exclusiveGroup: rowC ;},
          RadioButton { parent: numberOfAlt;text: "2"; exclusiveGroup: rowC ;},
          RadioButton { parent: numberOfAlt;text: "1"; exclusiveGroup: rowC ;checked: true }
        ]
      }

      RowLayout {
        id: numberOfTenor
        spacing: 20
        Text  { text:  "  Anzahl Tenorstimmen:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: numberOfTenor;text: "3"; exclusiveGroup: rowD },
          RadioButton { parent: numberOfTenor;text: "2"; exclusiveGroup: rowD },
          RadioButton { parent: numberOfTenor;text: "1"; exclusiveGroup: rowD ;checked: true }
        ]
      }

      RowLayout {
        id: numberOfBass
        spacing: 20
        Text  { text:  "  Anzahl Bassstimmen:"; font.bold: true }
        property list<RadioButton> buttonList: [
          RadioButton { parent: numberOfBass;text: "3"; exclusiveGroup: rowE },
          RadioButton { parent: numberOfBass;text: "2"; exclusiveGroup: rowE },
          RadioButton { parent: numberOfBass;text: "1"; exclusiveGroup: rowE ;checked: true }

        ]
      }



      ExclusiveGroup { id: rowA; onCurrentChanged: { updateSettings(); }}
      ExclusiveGroup { id: rowB; onCurrentChanged: { updateSettings(); }}
      ExclusiveGroup { id: rowC; onCurrentChanged: { updateSettings(); }}
      ExclusiveGroup { id: rowD; onCurrentChanged: { updateSettings(); }}
      ExclusiveGroup { id: rowE; onCurrentChanged: { updateSettings(); }}
  }

  Button {
    id: buttonCancel
    text: qsTr("Abbrechen")
    anchors.bottom: exportDialog.bottom
    anchors.right: exportDialog.right
    anchors.bottomMargin: 10
    anchors.rightMargin: 10
    width: 100
    height: 40
    onClicked: {
      Qt.quit();
    }
  }

  Button {
    id: buttonOK
    text: qsTr("OK")
    width: 100
    height: 40
    anchors.bottom: exportDialog.bottom
    anchors.right:  buttonCancel.left
    anchors.topMargin: 10
    anchors.bottomMargin: 10
    onClicked: {
      curScore.startCmd();
      exportMP3();
      curScore.endCmd();
    }
  }
}