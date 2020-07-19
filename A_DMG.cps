/**
  Copyright (C) 2012-2017 by Autodesk, Inc.
  All rights reserved.

  Siemens SINUMERIK 840D post processor configuration.

  dmg maho

  #TODO MCALL Ciklai
  anton: LABEL, IRANKIU APRASYMAS ZMIN, OPZMIN
  istrinti irankiu dublikatai

  $Revision: 41757 c26015439a1ddd19e2ba12a92d1f6f285cc9892d $
  $Date: 2017-12-20 11:03:56 $
  
  FORKID {75AF44EA-0A42-4803-8DE7-43BF08B352B3}
*/

// description = "Siemens SINUMERIK 840D";
description = "A - Deckel MAHO"
vendor = "Siemens";
vendorUrl = "http://www.siemens.com";
legal = "Copyright (C) 2012-2017 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 24000;

longDescription = "Siemens 840D post  processor for use with Gen 1&2 DMU 50 machines";

extension = "mpf";
setCodePage("ascii");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
var useArcTurn = true; //BORE and circular helical moves to one string anton
maximumCircularSweep = toRad(useArcTurn ? (999 * 360) : 90); // max revolutions
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion



// user-defined properties
properties = {
  writeMachine: true, // write machine
  writeTools: true, // writes the tools
  preloadTool: false, // preloads next tool on tool change if any
  maxSpindleSpeed:20000, //max Spindle Speed
  autoBazes: true,
  xOffset:"120.05", // enter X-offset value for output in G10 block 
  yOffset:"41.35", // enter Y-offset value for output in G10 block 
  zOffset:"-100.0", // enter Z-offset value for output in G10 block 
  showSequenceNumbers: false, // show sequence numbers
  sequenceNumberStart: 10, // first sequence number
  sequenceNumberIncrement: 1, // increment for sequence numbers
  optionalStop: true, // optional stop
  useShortestDirection: false, // specifies that shortest angular direction should be used
  useParametricFeed: false, // specifies that feed should be output using Q values
  showNotes: true, // specifies that operation notes should be output.
  useCIP: false, // enable to use the CIP command
  useCycle832: false, // enable to use CYCLE832
  toolAsName: true, // specifies if the tool should be called with a number or with the tool description
  useSubroutines: false, // specifies that subroutines per each operation should be generated
  useFilesForSubprograms: false, // specifies that one file should be generated to section
  useSubroutinePatterns: false, // generates subroutines for patterned operation
  useSubroutineCycles: false, // generates subroutines for cycle operations on same holes
  safeRetractDistance: 100. // distance to add to retract distance when rewinding rotary axes
};

// user-defined property definitions
propertyDefinitions = {
  writeMachine: {title:"Write machine", description:"Output the machine settings in the header of the code.", type:"boolean"},
  writeTools: {title:"Write tool list", description:"Output a tool list in the header of the code.", type:"boolean"},
  preloadTool: {title:"Preload tool", description:"Preloads the next tool at a tool change (if any).", type:"boolean"},
  maxSpindleSpeed:{group:0, title:"max Spindle Speed", description:"Value for S", type:"integer"},
  autoBazes: {group:1, title:"Automatines bazes", description:"Iraso bloka G10 L2 P  X  Y  Z ", type:"boolean"},
  xOffset:{group:1, title:"X Offset", description:"Value for X workoffset", type:"string"}, // xOffset - Anton
  yOffset:{group:1, title:"Y Offset", description:"Value for Y workoffset", type:"string"}, // yOffset - Anton
  zOffset:{group:1, title:"Z Offset", description:"Value for Z workoffset", type:"string"}, // zOffset - Anton
  showSequenceNumbers: {title:"Use sequence numbers", description:"Use sequence numbers for each block of outputted code.", type:"boolean"},
  sequenceNumberStart: {title:"Start sequence number", description:"The number at which to start the sequence numbers.", type:"integer"},
  sequenceNumberIncrement: {title:"Sequence number increment", description:"The amount by which the sequence number is incremented by in each block.", type:"integer"},
  optionalStop: {title:"Optional stop", description:"Outputs optional stop code during when necessary in the code.", type:"boolean"},
  useShortestDirection: {title:"Use shortest direction", description:"Specifies that the shortest angular direction should be used.", type:"boolean"},
  useParametricFeed:  {title:"Parametric feed", description:"Specifies the feed value that should be output using a Q value.", type:"boolean"},
  showNotes: {title:"Show notes", description:"Writes operation notes as comments in the outputted code.", type:"boolean"},
  useCIP: {title:"Use CIP", description:"Enable to use the CIP command.", type:"boolean"},
  useCycle832: {title:"Use CYCLE832", description:"Enable to use CYCLE832.", type:"boolean"},
  toolAsName: {title:"Tool as name", description:"If enabled, the tool will be called with the tool description rather than the tool number.", type:"boolean"},
  useSubroutines: {group:2, title:"Use subroutines", description:"Specifies that subroutines per each operation should be generated.", type:"boolean"},
  useFilesForSubprograms: {group:3, title:"Use files for subroutines", description:"If enabled, subroutines will be saved as individual files.", type:"boolean"},
  useSubroutinePatterns: {group:2, title:"Use subroutine patterns", description:"Generates subroutines for patterned operation.", type:"boolean"},
  useSubroutineCycles: {group:2, title:"Use subroutine cycles", description:"Generates subroutines for cycle operations on same holes.", type:"boolean"},
  safeRetractDistance: {title:"Safe retract distance", description:"Specifies the distance to add to retract distance when rewinding rotary axes.", type:"spatial"}
};

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});
var hFormat = createFormat({prefix:"H", decimals:0});
var dFormat = createFormat({prefix:"D", decimals:0});
var nFormat = createFormat({prefix:"N", decimals:0});


var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true}); //taskas po koordinaciu anton
var abcFormat = createFormat({decimals:3, scale:DEG});
var abcDirectFormat = createFormat({decimals:3, scale:DEG, prefix:"=DC(", suffix:")"});
var abc3Format = createFormat({decimals:6});
var feedFormat = createFormat({decimals:(unit == MM ? 3 : 4)});
var toolFormat = createFormat({decimals:0});
var toolProbeFormat = createFormat({decimals:0, zeropad:true, width:3});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3});
var taperFormat = createFormat({decimals:1, scale:DEG});
var arFormat = createFormat({decimals:3, scale:DEG});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange:function () {retracted = false;}, prefix:"Z"}, xyzFormat);
var a3Output = createVariable({prefix:"A3=", force:true}, abc3Format);
var b3Output = createVariable({prefix:"B3=", force:true}, abc3Format);
var c3Output = createVariable({prefix:"C3=", force:true}, abc3Format);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F", force:false}, feedFormat); //force anton
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({}, dFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, xyzFormat);

var gMotionModal = createModal({force:true}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G94-95
var gUnitModal = createModal({}, gFormat); // modal group 6 // G70-71

// fixed settings
var firstFeedParameter = 1;
var maximumLineLength = 80; // the maximum number of charaters allowed in a line
var minimumCyclePoints = 5; // minimum number of points in cycle operation to consider for subprogram

var WARNING_WORK_OFFSET = 0;
var WARNING_LENGTH_OFFSET = 1;
var WARNING_DIAMETER_OFFSET = 2;
var SUB_UNKNOWN = 0;
var SUB_PATTERN = 1;
var SUB_CYCLE = 2;

// collected state
var sequenceNumber;
var currentWorkOffset;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var retracted = false; // specifies that the tool has been retracted to the safe plane
var subprograms = [];
var currentPattern = -1;
var firstPattern = false;
var currentSubprogram = 0;
var definedPatterns = new Array();
var incrementalMode = false;
var saveShowSequenceNumbers;
var cycleSubprogramIsActive = false;
var patternIsActive = false;
var lastOperationComment = "";
var subprogramExtension = "spf";

/**
  Writes the specified block.
*/
function writeBlock() {
  if (properties.showSequenceNumbers) {
    writeWords2(" N" + sequenceNumber, arguments);
    sequenceNumber += properties.sequenceNumberIncrement;
  } else {
    writeWords(" ", arguments);
  }
}

function formatComment(text) {
  return "; " + String(text);
}

/**
  Output a comment.
*/
function writeComment(text) {
  if (properties.showSequenceNumbers) {
    writeWords2("N" + sequenceNumber, formatComment(text));
    sequenceNumber += properties.sequenceNumberIncrement;
  } else {
    writeWords(formatComment(text));
  }
}

function removeDups(names) {
  let unique = {};
  names.forEach(function(i) {
    if(!unique[i]) {
      unique[i] = true;
    }
  });
  return Object.keys(unique);
}

function onOpen() {

  if (false) { //anton true
    //var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-120.0001, 120.0001], preference:1});
    var bAxis = createAxis({coordinate:1, table:true, axis:[0, 1, 0], range:[-5.0000, 110.0000], preference:1});
    var cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], range:[-360, 360], cyclic:true});
    machineConfiguration = new MachineConfiguration(bAxis, cAxis);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(0);
  }


  // NOTE: setup your home positions here
  machineConfiguration.setRetractPlane(-.03937 * 25.4); // home position Z
  machineConfiguration.setHomePositionX(-19 * 25.4); // home position X
  machineConfiguration.setHomePositionY(-.1 * 25.4); // home position Y


  if (properties.useShortestDirection) {
    // abcFormat and abcDirectFormat must be compatible except for =DC()
    if (machineConfiguration.isMachineCoordinate(0)) {
      if (machineConfiguration.getAxisByCoordinate(0).isCyclic() || isSameDirection(machineConfiguration.getAxisByCoordinate(0).getAxis(), machineConfiguration.getSpindleAxis())) {
        aOutput = createVariable({prefix:"A"}, abcDirectFormat);
      }
    }
    if (machineConfiguration.isMachineCoordinate(1)) {
      if (machineConfiguration.getAxisByCoordinate(1).isCyclic() || isSameDirection(machineConfiguration.getAxisByCoordinate(1).getAxis(), machineConfiguration.getSpindleAxis())) {
        bOutput = createVariable({prefix:"B"}, abcDirectFormat);
      }
    }
    if (machineConfiguration.isMachineCoordinate(2)) {
      if (machineConfiguration.getAxisByCoordinate(2).isCyclic() || isSameDirection(machineConfiguration.getAxisByCoordinate(2).getAxis(), machineConfiguration.getSpindleAxis())) {
        cOutput = createVariable({prefix:"C"}, abcDirectFormat);
      }
    }
  }

  if (!machineConfiguration.isMachineCoordinate(0)) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1)) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2)) {
    cOutput.disable();
  }

  sequenceNumber = properties.sequenceNumberStart;
  // if (!((programName.length >= 2) && (isAlpha(programName[0]) || (programName[0] == "_")) && isAlpha(programName[1]))) {
  //   error(localize("Program name must begin with 2 letters."));
  // }
  // writeln("; %_N_" + translateText(String(programName).toUpperCase(), " ", "_") + "_MPF");
  


  
  if (true) {
    var kelias = ""
    if (hasGlobalParameter("document-path"))                      
    {                                                    
        var path = getGlobalParameter("document-path");
        if (path)
      {
        // writeComment(path);
        kelias += path;
        }
    }
    if (hasGlobalParameter("job-description"))                      
    {                                                    
        var path = getGlobalParameter("job-description");
        if (path)
      {
        // writeComment(path);
        kelias += "     " + path;
        }
    }
    // if (hasGlobalParameter("username"))                      
    // {                                                    
    //     var path = getGlobalParameter("username");
    //     if (path)
    //   {
    //     // writeComment(path);
    //     kelias += "    - " + path;
    //     }
    // }
    writeComment(kelias)
    
    //Anton PROGRAMOS DATA
    var d = new Date(); // output current date and time
    writeComment("DMG:   " + d.toLocaleDateString() + " " +
    d.toLocaleTimeString());  
    writeln("")
  }
  if (programComment) {
    writeComment(programComment);
  }


  

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (properties.writeMachine && (vendor || model || description)) {
    writeComment(localize("Machine"));
    if (vendor) {
      writeComment("  " + localize("vendor") + ": " + vendor);
    }
    if (model) {
      writeComment("  " + localize("model") + ": " + model);
    }
    if (description) {
      writeComment("  " + localize("description") + ": "  + description);
    }
  }



//Anton

  // dump tool information
  if (properties.writeTools) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }
    var tools = getToolTable();
    //    Anton lentele pradzioje pagal seka
    if (tools.getNumberOfTools() > 0) {
      var irankiai = [];
      for (var i = 0; i < getNumberOfSections(); ++i) {        
        var sectioniii = getSection(i);
        var tool = sectioniii.getTool();
        var comment = "" //"T" + toolFormat.format(tool.number);
        if (tool.description) {
          comment += tool.description.toLowerCase();
        }
        comment += "   - D=" + xyzFormat.format(tool.diameter); // + " H=" + xyzFormat.format(tool.bodyLength);    
        if (zRanges[tool.number]) {
          comment += "   Zmin=" + xyzFormat.format(zRanges[tool.number].getMinimum());
        }
        // if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
        //   comment += " " + localize("- K") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        // } 
        // if (tool.cornerRadius > 0) {
        //   comment += " - " + localize("CR") + "=" + xyzFormat.format(tool.cornerRadius); 
        // }          
        // writeComment(comment);
        irankiai.push(comment)
      }
      var lines = String(removeDups(irankiai)).split(",");
      for (line in lines) {
        var comment = lines[line];
        if (comment) {
          writeComment(comment);
        }
      }


    }
  }

  if (false) { // stock - workpiece
    var workpiece = getWorkpiece();
    var delta = Vector.diff(workpiece.upper, workpiece.lower);
    if (delta.isNonZero()) {
      writeComment(
        "WORKPIECE" + "(" + ",,," + "\"" + "BOX" + "\""  + "," + "112" + "," + xyzFormat.format(workpiece.upper.z) + "," + xyzFormat.format(workpiece.lower.z) + "," + "80" +
        "," + xyzFormat.format(workpiece.upper.x) + "," + xyzFormat.format(workpiece.upper.y) + "," + xyzFormat.format(workpiece.lower.x) + "," + xyzFormat.format(workpiece.lower.y) + ")"
      );
    }
  }

  //autobazes anton 

  //G10 L2 P X Y Z offset - Anton
if (properties.autoBazes) {
  var workOffset = getSection(0).workOffset;
  workOffset = workOffset == 0 ? 1 : workOffset;
   var xoffset = parseFloat(properties.xOffset);
   var yoffset = parseFloat(properties.yOffset);
   var zoffset = parseFloat(properties.zOffset);
  writeln("");
  writeln("$P_UIFR[1,X,TR]=" + xyzFormat.format(xoffset));
  writeln("$P_UIFR[1,Y,TR]=" + xyzFormat.format(yoffset));
  writeln("$P_UIFR[1,Z,TR]="+ xyzFormat.format(zoffset));
  writeln("")
}

  writeln("")
  writeln("BEGIN:")
  writeln("")


  // ORIGINAL dump tool information
  // if (properties.writeTools) {
  //   var zRanges = {};
  //   if (is3D()) {
  //     var numberOfSections = getNumberOfSections();
  //     for (var i = 0; i < numberOfSections; ++i) {
  //       var section = getSection(i);
  //       var zRange = section.getGlobalZRange();
  //       var tool = section.getTool();
  //       if (zRanges[tool.number]) {
  //         zRanges[tool.number].expandToRange(zRange);
  //       } else {
  //         zRanges[tool.number] = zRange;
  //       }
  //     }
  //   }

  //   var tools = getToolTable();
  //   if (tools.getNumberOfTools() > 0) {
  //     for (var i = 0; i < tools.getNumberOfTools(); ++i) {
  //       var tool = tools.getTool(i);
  //       var comment = "T" + (properties.toolAsName ? "="  + "\"" + (tool.description.toUpperCase()) + "\"" : toolFormat.format(tool.number)) + " " +
  //         "D=" + xyzFormat.format(tool.diameter) + " " +
  //         localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
  //       if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
  //         comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
  //       }
  //       if (zRanges[tool.number]) {
  //         comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
  //       }
  //       comment += " - " + getToolTypeName(tool.type);
  //       writeComment(comment);
  //     }
  //   }
  // }



  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }


  // absolute coordinates and feed per min
  // writeBlock(gAbsIncModal.format(90), gFeedModeModal.format(95), gPlaneModal.format(17));

  // switch (unit) {
  // case IN:
  //   writeBlock(gUnitModal.format(70)); // lengths
  //   //writeBlock(gFormat.format(700)); // feeds
  //   break;
  // case MM:
  //   writeBlock(gUnitModal.format(71)); // lengths
  //   //writeBlock(gFormat.format(710)); // feeds
  //   break;
  // }

  // writeBlock(gFormat.format(64)); // continuous-path mode
  // writeBlock(gPlaneModal.format(17));
}

function onComment(message) {
  writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

function setWCS() {
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    workOffset = 1;
  }
  if (workOffset > 0) {
    if (workOffset > 4) {
      var code = 500 + workOffset - 4 + 4;
      if (code > 599) {
        error(localize("Work offset out of range."));
        return;
      }
      if (workOffset != currentWorkOffset) {
        writeBlock(gFormat.format(code));
        currentWorkOffset = workOffset;
      }
    } else {
      if (workOffset != currentWorkOffset) {
        writeBlock(gFormat.format(53 + workOffset)); // G54->G59
        currentWorkOffset = workOffset;
      }
    }
  }
}

function isProbeOperation() {
  return (hasParameter("operation-strategy") && getParameter("operation-strategy") == "probe");
}

function onParameter(name, value) {
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  //this.feed = feed;
}

function getFeed(f) { // anton change to g95
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F=R" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f/spindleSpeed); // use feed value
  // f / spindleSpeed
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  
  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }
  
  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), Math.max(getParameter("operation:tool_feedCutting"), getParameter("operation:tool_feedEntry"), getParameter("operation:tool_feedExit")));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed anton test this g95??
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), this.highFeedrate);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }
  
  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("R" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;
var currentWorkPlaneABCTurned = false;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc, turn) {
  if (is3D() && !machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z) ||
        (!currentWorkPlaneABCTurned && turn))) {
    return; // no change
  }
  currentWorkPlaneABC = abc;
  currentWorkPlaneABCTurned = turn;

  if (!retracted) {
    writeRetract(Z);
  }
  writeRetract(X, Y);

  if (turn) {
    onCommand(COMMAND_UNLOCK_MULTI_AXIS);
  }

  var FR = 1; // 0 = without moving to safety plane, 1 = move to safety plane only in Z, 2 = move to safety plane Z,X,Y
  var TC = "DMG";
  var ST = 200000;
  var MODE = 27;
  var X0 = 0;
  var Y0 = 0;
  var Z0 = 0;
  var A = abc.x;
  var B = abc.y;
  var C = abc.z;
  var X1 = 0;
  var Y1 = 0;
  var Z1 = 0;
  var DIR = turn ? 1 : 0; // direction
      
  writeBlock(
    "CYCLE800(" +
    FR + "," +
    "\"" + TC + "\"," +
    ST + "," +
    MODE + "," +
    xyzFormat.format(X0) + "," +
    xyzFormat.format(Y0) + "," +
    xyzFormat.format(Z0) + "," +
    abcFormat.format(C) + "," +
    abcFormat.format(B) + "," +
    abcFormat.format(A) + "," +
    xyzFormat.format(X1) + "," +
    xyzFormat.format(Y1) + "," +
    xyzFormat.format(Z1) + "," +
    DIR + ",,1)"
  );
  forceABC();
  forceXYZ();

  if (turn) {
    //if (!currentSection.isMultiAxis()) {
      onCommand(COMMAND_LOCK_MULTI_AXIS);
    //}
  }
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }
  
  try {
    abc = machineConfiguration.remapABC(abc);
    currentMachineABC = abc;
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }
  
  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
  }
  
  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  var tcp = true;
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }
  
  return abc;
}

/** Returns true if the spatial vectors are significantly different. */
function areSpatialVectorsDifferent(_vector1, _vector2) {
  return (xyzFormat.getResultingValue(_vector1.x) != xyzFormat.getResultingValue(_vector2.x)) ||
    (xyzFormat.getResultingValue(_vector1.y) != xyzFormat.getResultingValue(_vector2.y)) ||
    (xyzFormat.getResultingValue(_vector1.z) != xyzFormat.getResultingValue(_vector2.z));
}

/** Returns true if the spatial boxes are a pure translation. */
function areSpatialBoxesTranslated(_box1, _box2) {
  return !areSpatialVectorsDifferent(Vector.diff(_box1[1], _box1[0]), Vector.diff(_box2[1], _box2[0])) &&
    !areSpatialVectorsDifferent(Vector.diff(_box2[0], _box1[0]), Vector.diff(_box2[1], _box1[1]));
}

function subprogramDefine(_initialPosition, _abc, _retracted, _zIsOutput) {
  // convert patterns into subprograms
  var usePattern = false;
  patternIsActive = false;
  if (currentSection.isPatterned && currentSection.isPatterned() && properties.useSubroutinePatterns) {
    currentPattern = currentSection.getPatternId();
    firstPattern = true;
    for (var i = 0; i < definedPatterns.length; ++i) {
      if ((definedPatterns[i].patternType == SUB_PATTERN) && (currentPattern == definedPatterns[i].patternId)) {
        currentSubprogram = definedPatterns[i].subProgram;
        usePattern = definedPatterns[i].validPattern;
        firstPattern = false;
        break;
      }
    }

    if (firstPattern) {
      // determine if this is a valid pattern for creating a subprogram
      usePattern = subprogramIsValid(currentSection, currentPattern, SUB_PATTERN);
      if (usePattern) {
        currentSubprogram++;
      }
      definedPatterns.push({
        patternType: SUB_PATTERN,
        patternId: currentPattern,
        subProgram: currentSubprogram,
        validPattern: usePattern,
        initialPosition: _initialPosition,
        finalPosition: _initialPosition
      });
    }

    if (usePattern) {
      // make sure Z-position is output prior to subprogram call
      if (!_retracted && !_zIsOutput) {
        writeBlock(gMotionModal.format(0), zOutput.format(_initialPosition.z));
      }

      // call subprogram
      if (!properties.useFilesForSubprograms) {
        writeBlock("CALL BLOCK LABEL" + currentSubprogram + " TO LABEL0");
      }
      patternIsActive = true;

      if (firstPattern) {
        subprogramStart(_initialPosition, _abc, true);
      } else {
        skipRemainingSection();
        setCurrentPosition(getFramePosition(currentSection.getFinalPosition()));
      }
    }
  }

  // Output cycle operation as subprogram
  if (!usePattern && properties.useSubroutineCycles && currentSection.doesStrictCycle &&
    (currentSection.getNumberOfCycles() == 1) && currentSection.getNumberOfCyclePoints() >= minimumCyclePoints) {
  var finalPosition = getFramePosition(currentSection.getFinalPosition());
  currentPattern = currentSection.getNumberOfCyclePoints();
  firstPattern = true;
  for (var i = 0; i < definedPatterns.length; ++i) {
    if ((definedPatterns[i].patternType == SUB_CYCLE) && (currentPattern == definedPatterns[i].patternId) &&
        !areSpatialVectorsDifferent(_initialPosition, definedPatterns[i].initialPosition) &&
        !areSpatialVectorsDifferent(finalPosition, definedPatterns[i].finalPosition)) {
      currentSubprogram = definedPatterns[i].subProgram;
      usePattern = definedPatterns[i].validPattern;
      firstPattern = false;
      break;
    }
  }

    if (firstPattern) {
      // determine if this is a valid pattern for creating a subprogram
      usePattern = subprogramIsValid(currentSection, currentPattern, SUB_CYCLE);
      if (usePattern) {
        currentSubprogram++;
      }
      definedPatterns.push({
        patternType: SUB_CYCLE,
        patternId: currentPattern,
        subProgram: currentSubprogram,
        validPattern: usePattern,
        initialPosition: _initialPosition,
        finalPosition: finalPosition
      });
    }
    cycleSubprogramIsActive = usePattern;
  }

  // Output each operation as a subprogram
  if (!usePattern && properties.useSubroutines) {
    currentSubprogram++;
    // writeBlock("REPEAT LABEL" + currentSubprogram + " LABEL0");
    if (!properties.useFilesForSubprograms) {
    // writeBlock("CALL BLOCK LABEL" + currentSubprogram + " TO LABEL0");
    writeBlock("REPEAT LABEL" + currentSubprogram); //ANTON LABEL
    }
    firstPattern = true;
    subprogramStart(_initialPosition, _abc, false);
  }
}

function subprogramStart(_initialPosition, _abc, _incremental) {
  var comment = "";
  if (hasParameter("operation-comment")) {
    comment = getParameter("operation-comment");
  }
  
  if (properties.useFilesForSubprograms) {
    // used if external files are used for subprograms
    var subprogram = "sub" + programName.substr(0, Math.min(programName.length, 20)) + getCurrentSectionId(); // set the subprogram name
    var callType = "SPF CALL";
    writeBlock(subprogram + " ;", callType); // call subprogram
    var path = FileSystem.getCombinedPath(FileSystem.getFolderPath(getOutputPath()), subprogram + "." + subprogramExtension); // set the output path for the subprogram(s)
    redirectToFile(path); // redirect output to the new file (defined above)
    writeln("; %_N_" + translateText(String(subprogram).toUpperCase(), " ", "_") + "_SPF"); // add the program name to the first line of the newly created file
  } else {
    // used if subroutines are contained within the same file
    redirectToBuffer();
    writeln(
      "LABEL" + currentSubprogram + ":" +
      conditional(comment, formatComment(comment.substr(0, maximumLineLength - 2 - 6 - 1)))
    ); // output the subroutine name as the first line of the new file
  }
  
  saveShowSequenceNumbers = properties.showSequenceNumbers;
  properties.showSequenceNumbers = false; // disable sequence numbers for subprograms
  if (_incremental) {
    setIncrementalMode(_initialPosition, _abc);
  }
}

function subprogramEnd() {
  if (firstPattern && !properties.useFilesForSubprograms) {
    // writeBlock("LABEL0:"); // sets the end block of the subroutine
    writeBlock("ENDLABEL:"); //ANTON LABEL sets the end block of the subroutine
    writeln("");
    subprograms += getRedirectionBuffer();
  } else if (properties.useFilesForSubprograms) {
    writeBlock(mFormat.format(17)); // close the external subprogram with M17
    subprograms += getRedirectionBuffer();
  }
  forceAny();
  firstPattern = false;
  properties.showSequenceNumbers = saveShowSequenceNumbers;
  closeRedirection();
}

function subprogramIsValid(_section, _patternId, _patternType) {
  var sectionId = _section.getId();
  var numberOfSections = getNumberOfSections();
  var validSubprogram = _patternType != SUB_CYCLE;

  var masterPosition = new Array();
  masterPosition[0] = getFramePosition(_section.getInitialPosition());
  masterPosition[1] = getFramePosition(_section.getFinalPosition());
  var tempBox = _section.getBoundingBox();
  var masterBox = new Array();
  masterBox[0] = getFramePosition(tempBox[0]);
  masterBox[1] = getFramePosition(tempBox[1]);

  var rotation = getRotation();
  var translation = getTranslation();

  for (var i = 0; i < numberOfSections; ++i) {
    var section = getSection(i);
    if (section.getId() != sectionId) {
      defineWorkPlane(section, false);
      // check for valid pattern
      if (_patternType == SUB_PATTERN) {
        if (section.getPatternId() == _patternId) {
          var patternPosition = new Array();
          patternPosition[0] = getFramePosition(section.getInitialPosition());
          patternPosition[1] = getFramePosition(section.getFinalPosition());
          tempBox = section.getBoundingBox();
          var patternBox = new Array();
          patternBox[0] = getFramePosition(tempBox[0]);
          patternBox[1] = getFramePosition(tempBox[1]);

          if (!areSpatialBoxesTranslated(masterPosition, patternPosition) || !areSpatialBoxesTranslated(masterBox, patternBox)) {
            validSubprogram = false;
            break;
          }
        }

      // check for valid cycle operation
      } else if (_patternType == SUB_CYCLE) {
        if ((section.getNumberOfCyclePoints() == _patternId) && (section.getNumberOfCycles() == 1)) {
          var patternInitial = getFramePosition(section.getInitialPosition());
          var patternFinal = getFramePosition(section.getFinalPosition());
          if (!areSpatialVectorsDifferent(patternInitial, masterPosition[0]) && !areSpatialVectorsDifferent(patternFinal, masterPosition[1])) {
            validSubprogram = true;
            break;
          }
        }
      }
    }
  }
  setRotation(rotation);
  setTranslation(translation);
  return(validSubprogram);
}

function setIncrementalMode(xyz, abc) {
  xOutput = createIncrementalVariable({prefix:"X"}, xyzFormat);
  xOutput.format(xyz.x);
  xOutput.format(xyz.x);
  yOutput = createIncrementalVariable({prefix:"Y"}, xyzFormat);
  yOutput.format(xyz.y);
  yOutput.format(xyz.y);
  zOutput = createIncrementalVariable({prefix:"Z"}, xyzFormat);
  zOutput.format(xyz.z);
  zOutput.format(xyz.z);
  aOutput = createIncrementalVariable({prefix:"A"}, abcFormat);
  aOutput.format(abc.x);
  aOutput.format(abc.x);
  bOutput = createIncrementalVariable({prefix:"B"}, abcFormat);
  bOutput.format(abc.y);
  bOutput.format(abc.y);
  cOutput = createIncrementalVariable({prefix:"C"}, abcFormat);
  cOutput.format(abc.z);
  cOutput.format(abc.z);
  gAbsIncModal.reset();
  writeBlock(gAbsIncModal.format(91));
  incrementalMode = true;
}

function setAbsoluteMode(xyz, abc) {
  if (incrementalMode) {
    xOutput = createVariable({prefix:"X"}, xyzFormat);
    xOutput.format(xyz.x);
    yOutput = createVariable({prefix:"Y"}, xyzFormat);
    yOutput.format(xyz.y);
    zOutput = createVariable({prefix:"Z"}, xyzFormat);
    zOutput.format(xyz.z);
    aOutput = createVariable({prefix:"A"}, abcFormat);
    aOutput.format(abc.x);
    bOutput = createVariable({prefix:"B"}, abcFormat);
    bOutput.format(abc.y);
    cOutput = createVariable({prefix:"C"}, abcFormat);
    cOutput.format(abc.z);
    gAbsIncModal.reset();
    writeBlock(gAbsIncModal.format(90));
    incrementalMode = false;
  }
}

function onSection() {
  // if (properties.toolAsName && !tool.description) { anton
  //   if (hasParameter("operation-comment")) {
  //     error(localize("Tool description is empty in operation " + "\"" + (getParameter("operation-comment").toUpperCase()) + "\""));
  //   } else {
  //     error(localize("Tool description is empty."));
  //   }
  //   return;
  // }
  var insertToolCall = isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number) ||
    conditional(properties.toolAsName, tool.description != getPreviousSection().getTool().description);

  retracted = false; // specifies that the tool has been retracted to the safe plane
  var zIsOutput = false; // true if the Z-position has been output, used for patterns

  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
    Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations
  if (insertToolCall || newWorkOffset || newWorkPlane) {
    
    // retract to safe plane
    writeRetract(Z);

    if (newWorkPlane) {
      setWorkPlane(new Vector(0, 0, 0), false); // reset working plane
    }
  }

  writeln("");
  
  // if (hasParameter("operation-comment")) {
  //   var comment = getParameter("operation-comment");
  //   if (comment) {
  //     writeComment(comment);
  //   }
  // }
  

  if (true) {         
    var showToolZMin = true;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        var toolInfo = (" ;   D=" + xyzFormat.format(tool.diameter) + "   ZMIN=" + xyzFormat.format(zRange.getMinimum()));
      }
    }
    





  
  if (insertToolCall) {
    forceWorkPlane();

    // onCommand(COMMAND_COOLANT_OFF);
  
    if (!isFirstSection() && properties.optionalStop) {
      onCommand(COMMAND_OPTIONAL_STOP);
    }

    if (tool.number > 99999999) {
      warning(localize("Tool number exceeds maximum value."));
    }

    var lengthOffset = 1; // optional, use tool.lengthOffset instead
    if (lengthOffset > 99) {
      error(localize("Length offset out of range."));
      return;
    }
    writeWords( //dump toolchange anton
      mFormat.format(6),
      ("(" + (properties.toolAsName ? ""  + "\"" + ((tool.description.toLowerCase()) + "\")" + toolInfo) : toolFormat.format(tool.number))
    ));
    // writeComment(toolInfo)
      //  dFormat.format(lengthOffset));

    // writeBlock(mFormat.format(6));
    // if (tool.comment) {
    //   writeComment(tool.comment);
    // }
    // var showToolZMin = false;
    // if (showToolZMin) {
    //   if (is3D()) {
    //     var numberOfSections = getNumberOfSections();
    //     var zRange = currentSection.getGlobalZRange();
    //     var number = tool.number;
    //     for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
    //       var section = getSection(i);
    //       if (section.getTool().number != number) {
    //         break;
    //       }
    //       zRange.expandToRange(section.getGlobalZRange());
    //     }
    //     writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
    //   }
    }

    if (hasParameter("operation-comment")) { //anton
      var opZmin = "   Zmin=" + xyzFormat.format(currentSection.getGlobalZRange().getMinimum());
      var comment = getParameter("operation-comment");
      if (comment && ((comment !== lastOperationComment) || !patternIsActive || insertToolCall)) {
        // writeln("");
        writeWords(" ;  " + comment + opZmin); //anton
        lastOperationComment = comment;
      } else if (!patternIsActive || insertToolCall) {
        writeln("");
      }
    } else {
      writeln("");
    }
    if (properties.showNotes && hasParameter("notes")) {
      var notes = getParameter("notes");
      if (notes) {
        var lines = String(notes).split("\n");
        var r1 = new RegExp("^[\\s]+", "g");
        var r2 = new RegExp("[\\s]+$", "g");
        for (line in lines) {
          var comment = lines[line].replace(r1, "").replace(r2, "");
          if (comment) {
            writeWords("   ; PASTABA:  " + comment);
          }
        }
      }
    }


    if (properties.preloadTool) {
      var nextTool = (properties.toolAsName ? getNextToolDescription(tool.description) : getNextTool(tool.number));
      if (nextTool) {
        writeBlock("(" + (properties.toolAsName ? ""  + "\"" + (nextTool.description.toLowerCase()) + "\")" : toolFormat.format(nextTool.number)));
      } else {
        // preload first tool
        var section = getSection(0);
        var firstToolNumber = section.getTool().number;
        var firstToolDescription = section.getTool().description;
        if (properties.toolAsName) {
          if (tool.description != firstToolDescription) {
            writeBlock("(" + "\"" + (firstToolDescription.toLowerCase()) + "\")");
          }
        // } else {
        //   if (tool.number != firstToolNumber) {
        //     writeBlock("T" + toolFormat.format(firstToolNumber));
        //   }
        }
      }
    }
  }

  if (properties.useCycle832) {
    if (hasParameter("operation-strategy") && (getParameter("operation-strategy") == "drill")) {
      writeBlock("CYCLE832()");
    } else if (hasParameter("operation:tolerance")) {
      var tolerance = Math.max(getParameter("operation:tolerance"), 0);
      if (tolerance > 0) {
        var workMode = 0;
        //Thresholds
        var stockToLeaveThresholdF = toPreciseUnit(0, MM);      //Finishing      workMode=1 from 0.000mm - 0.009mm
        var stockToLeaveThresholdS = toPreciseUnit(0.01, MM);   //Semi-finishing workMode=2 from 0.010mm - 0.253mm
        var stockToLeaveThresholdR = toPreciseUnit(0.254, MM);    //Roughing       workMode=3 from 0.254mm - open end
        //Stocks from Operation
        var stockToLeave = (hasParameter("operation:stockToLeave")) ? getParameter("operation:stockToLeave") : 0;
        var verticalStockToLeave = (hasParameter("operation:verticalStockToLeave")) ? getParameter("operation:verticalStockToLeave") : 0;
        var minStockToLeave = Math.min( stockToLeave, verticalStockToLeave );
        //Check conditions for Roughing
        if ( minStockToLeave >= stockToLeaveThresholdR ) {
          workMode = 3;
        }
        //Check conditions for Semi-Finishing
        if ( ( minStockToLeave >= stockToLeaveThresholdS ) && ( minStockToLeave <  stockToLeaveThresholdR ) ) {
          workMode = 2;
        }
        //Check conditions for Finishing
        if ( ( minStockToLeave >= stockToLeaveThresholdF ) && ( minStockToLeave <  stockToLeaveThresholdS ) ) {
          workMode = 1;
        }
        if (workMode) {
          writeBlock("CYCLE832(" + xyzFormat.format(tolerance) + ", " + workMode + ", 1)");
        } else {
          writeBlock("CYCLE832()");
        }
      } else {
        writeBlock("CYCLE832()");
      }
    } else {
      writeBlock("CYCLE832()");
    }
  }
  //anton maxSpindleSpeed
  if ((insertToolCall ||
       forceSpindleSpeed ||
       isFirstSection() ||
       (rpmFormat.areDifferent(tool.spindleRPM, sOutput.getCurrent())) ||
       (tool.clockwise != getPreviousSection().getTool().clockwise)) &&
      !isProbeOperation()) {
    forceSpindleSpeed = false;
    newSpindleSpeed = tool.spindleRPM; //anton
    
    if (tool.spindleRPM < 1) {
      error(localize("Spindle speed out of range."));
      return;
    }
    
    if (tool.spindleRPM > properties.maxSpindleSpeed) {
      newSpindleSpeed = properties.maxSpindleSpeed; //anton
      writeWords("   ; S" + tool.spindleRPM); //sukiai pagal iranki Anton
      // warning(localize("Spindle speed exceeds maximum value."));
    }
    writeBlock(
      sOutput.format(newSpindleSpeed), mFormat.format(tool.clockwise ? 3 : 4)
    );
    // writeBlock( //original
    //   sOutput.format(tool.spindleRPM), mFormat.format(tool.clockwise ? 3 : 4)
    // );
  }

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  setWCS();

  forceXYZ();

  if (!is3D() || machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
    // set working plane after datum shift

    var abc = new Vector(0, 0, 0);
    cancelTransformation();
    if (!currentSection.isMultiAxis()) {
      abc = currentSection.workPlane.getTransposed().eulerZYX_R;
      abc = new Vector(-abc.x, -abc.y, -abc.z);
    }
    setWorkPlane(abc, true); // turn
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }

  forceAny();

  if (!currentSection.isMultiAxis()) {
    onCommand(COMMAND_LOCK_MULTI_AXIS);
  }

  if (retracted && !insertToolCall) {
    var lengthOffset = 1; // optional, use tool.lengthOffset instead
    if (lengthOffset > 99) {
      error(localize("Length offset out of range."));
      return;
    }
    writeBlock(dFormat.format(lengthOffset));
  }

  if (currentSection.isMultiAxis()) {
    forceWorkPlane();
    cancelTransformation();

    // turn machine
    if (currentSection.isOptimizedForMachine()) {
      var abc = currentSection.getInitialToolAxisABC();
      writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), aOutput.format(abc.x), bOutput.format(abc.y), cOutput.format(abc.z));
    }

    writeBlock("TRAORI");
    var initialPosition = getFramePosition(currentSection.getInitialPosition());

    if (currentSection.isOptimizedForMachine()) {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z)
      );
    } else {
      var d = currentSection.getGlobalInitialToolAxis();
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z),
        a3Output.format(d.x),
        b3Output.format(d.y),
        c3Output.format(d.z)
      );
    }
  } else {

    var initialPosition = getFramePosition(currentSection.getInitialPosition());
    if (!retracted) {
      if (getCurrentPosition().z < initialPosition.z) {
        writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
        zIsOutput = true;
      }
    }
    
    if (insertToolCall) {
      if (tool.lengthOffset != 0) {
        warningOnce(localize("Length offset is not supported."), WARNING_LENGTH_OFFSET);
      }

      if (!machineConfiguration.isHeadConfiguration()) {
        writeBlock(
          gAbsIncModal.format(90), gAbsIncModal.format(95),
          gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
        );
        var z = zOutput.format(initialPosition.z);
        if (z) {
          writeBlock(gMotionModal.format(0), z);
        }
      } else {
        writeBlock(
          gAbsIncModal.format(90),
          gMotionModal.format(0),
          xOutput.format(initialPosition.x),
          yOutput.format(initialPosition.y),
          zOutput.format(initialPosition.z)
        );
      }
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y)
      );
    }
  }

  // set coolant after we have positioned at Z
  if (insertToolCall) {
    forceCoolant();
  }
  setCoolant(tool.coolant);

  if (properties.useParametricFeed &&
      hasParameter("operation-strategy") &&
      (getParameter("operation-strategy") != "drill") && // legacy
      !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
    if (!insertToolCall &&
        activeMovements &&
        (getCurrentSectionId() > 0) &&
        ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }
  
  if (insertToolCall) {
    gPlaneModal.reset();
  }
  retracted = false;
  // define subprogram
  subprogramDefine(initialPosition, abc, retracted, zIsOutput);
}

function getNextToolDescription(description) {
  var currentSectionId = getCurrentSectionId();
  if (currentSectionId < 0) {
    return null;
  }
  for (var i = currentSectionId + 1; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    var sectionTool = section.getTool();
    if (description != sectionTool.description) {
      return sectionTool; // found next tool
    }
  }
  return null; // not found
}

function onDwell(seconds) {
  if (seconds > 0) {
    writeBlock(gFormat.format(4), "F" + secFormat.format(seconds));
  }
}

// function onSpindleSpeed(spindleSpeed) {
//   writeBlock(sOutput.format(spindleSpeed));
// }

var expandCurrentCycle = false;

// function onCycle() { //uses mcall anton
//   writeBlock(gPlaneModal.format(17));
  
//   expandCurrentCycle = false;

//   if ((cycleType != "tapping") &&
//       (cycleType != "right-tapping") &&
//       (cycleType != "left-tapping") &&
//       !isProbeOperation() &&
//       (cycleType != "tapping-with-chip-breaking")) {
//     writeBlock(feedOutput.format(cycle.feedrate/spindleSpeed)); //g95 anton
//   }

//   var RTP = cycle.clearance; // return plane (absolute)
//   var RFP = cycle.stock; // reference plane (absolute)
//   var SDIS = cycle.retract - cycle.stock; // safety distance
//   var DP = cycle.bottom; // depth (absolute)
//   // var DPR = RFP - cycle.bottom; // depth (relative to reference plane)
//   var DTB = cycle.dwell;
//   var SDIR = tool.clockwise ? 3 : 4; // direction of rotation: M3:3 and M4:4

//   switch (cycleType) {
//   case "drilling":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     writeBlock(
//       "MCALL CYCLE81(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ + ")"
//     );
//     break;
//   case "counter-boring":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     writeBlock(
//       "MCALL CYCLE82(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + conditional(DTB > 0, secFormat.format(DTB)) + ")"
//     );
//     break;
//   case "chip-breaking":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     // add support for accumulated depth
//     var FDEP = cycle.stock - cycle.incrementalDepth;
//     var FDPR = cycle.incrementalDepth; // relative to reference plane (unsigned)
//     var DAM = 0; // degression (unsigned)
//     var DTS = 0; // dwell time at start
//     var FRF = 1; // feedrate factor (unsigned)
//     var VARI = 0; // chip breaking
//     var _AXN = 3; // tool axis
//     var _MDEP = cycle.incrementalDepth; // minimum drilling depth
//     var _VRT = 0; // retraction distance
//     var _DTD = (cycle.dwell != undefined) ? cycle.dwell : 0;
//     var _DIS1 = 0; // limit distance

//     writeBlock(
//       "MCALL CYCLE83(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + xyzFormat.format(FDEP) +
//       ", " /*+ xyzFormat.format(FDPR)*/ +
//       ", " + xyzFormat.format(DAM) +
//       ", " + /*conditional(DTB > 0, secFormat.format(DTB))*/ // only dwell at bottom
//       ", " + conditional(DTS > 0, secFormat.format(DTS)) +
//       ", " + xyzFormat.format(FRF) +
//       ", " + xyzFormat.format(VARI) +
//       ", " + /*_AXN +*/
//       ", " + xyzFormat.format(_MDEP) +
//       ", " + xyzFormat.format(_VRT) +
//       ", " + secFormat.format(_DTD) +
//       ", 0" + /*xyzFormat.format(_DIS1) +*/
//       ")"
//     );
//     break;
//   case "deep-drilling":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     var FDEP = cycle.stock - cycle.incrementalDepth;
//     var FDPR = cycle.incrementalDepth; // relative to reference plane (unsigned)
//     var DAM = 0; // degression (unsigned)
//     var DTS = 0; // dwell time at start
//     var FRF = 1; // feedrate factor (unsigned)
//     var VARI = 1; // full retract
//     var _MDEP = cycle.incrementalDepth; // minimum drilling depth
//     var _VRT = 0; // retraction distance
//     var _DTD = (cycle.dwell != undefined) ? cycle.dwell : 0;
//     var _DIS1 = 0; // limit distance

//     writeBlock(
//       "MCALL CYCLE83(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + xyzFormat.format(FDEP) +
//       ", " /*+ xyzFormat.format(FDPR)*/ +
//       ", " + xyzFormat.format(DAM) +
//       ", " + /*conditional(DTB > 0, secFormat.format(DTB)) +*/ // only dwell at bottom
//       ", " + conditional(DTS > 0, secFormat.format(DTS)) +
//       ", " + xyzFormat.format(FRF) +
//       ", " + xyzFormat.format(VARI) +
//       ", " + /*_AXN +*/
//       ", " + xyzFormat.format(_MDEP) +
//       ", " + xyzFormat.format(_VRT) +
//       ", " + secFormat.format(_DTD) +
//       ", 0" + /*xyzFormat.format(_DIS1) +*/
//       ")"
//     );
//     break;
//   case "tapping":
//   case "left-tapping":
//   case "right-tapping":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     var SDAC = SDIR; // direction of rotation after end of cycle
//     var MPIT = 0; // thread pitch as thread size
//     var PIT = ((tool.type == TOOL_TAP_LEFT_HAND) ? -1 : 1) * tool.threadPitch; // thread pitch
//     var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
//     var SST = tool.spindleRPM; // speed for tapping
//     var SST1 = tool.spindleRPM; // speed for return
//     writeBlock(
//       "MCALL CYCLE84(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + conditional(DTB > 0, secFormat.format(DTB)) +
//       ", " + xyzFormat.format(SDAC) +
//       ", " + xyzFormat.format(MPIT) +
//       ", " + xyzFormat.format(PIT) +
//       ", " + xyzFormat.format(POSS) +
//       ", " + xyzFormat.format(SST) +
//       ", " + xyzFormat.format(SST1) + ")"
//     );
//     break;
//   case "tapping-with-chip-breaking":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     var SDAC = SDIR; // direction of rotation after end of cycle
//     var MPIT = 0; // thread pitch as thread size
//     var PIT = ((tool.type == TOOL_TAP_LEFT_HAND) ? -1 : 1) * tool.threadPitch; // thread pitch
//     var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
//     var SST = tool.spindleRPM; // speed for tapping
//     var SST1 = tool.spindleRPM; // speed for return
//     var _AXN = 0; // tool axis
//     var _PTAB = 0; // must be 0
//     var _TECHNO = 0; // technology settings
//     var _VARI = 1; // machining type: 0 = tapping full depth, 1 = tapping partial retract, 2 = tapping full retract
//     var _DAM = cycle.incrementalDepth; // incremental depth
//     var _VRT = cycle.chipBreakDistance; // retract distance for chip breaking
//     writeBlock(
//       "MCALL CYCLE84(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + secFormat.format(DTB) +
//       ", " + xyzFormat.format(SDAC) +
//       ", " /*+ xyzFormat.format(MPIT)*/ +
//       ", " + xyzFormat.format(PIT) +
//       ", " + xyzFormat.format(POSS) +
//       ", " + xyzFormat.format(SST) +
//       ", " + xyzFormat.format(SST1) +
//       ", " + xyzFormat.format(_AXN) +
//       ", " + xyzFormat.format(_PTAB) +
//       ", " + xyzFormat.format(_TECHNO) +
//       ", " + xyzFormat.format(_VARI) +
//       ", " + xyzFormat.format(_DAM) +
//       ", " + xyzFormat.format(_VRT) + ")"
//     );
//     break;
//   case "reaming":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     var FFR = cycle.feedrate / spindleSpeed; //g95 
//     var RFF = cycle.retractFeedrate  / spindleSpeed; //g95
//     writeBlock(
//       "MCALL CYCLE85(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + conditional(DTB > 0, secFormat.format(DTB)) +
//       ", " + xyzFormat.format(FFR) +
//       ", " + xyzFormat.format(RFF) + ")"
//     );
//     break;
//   case "stop-boring":
//     if (cycle.dwell > 0) {
//       expandCurrentCycle = true;
//     } else {
//       if (RTP > getCurrentPosition().z) {
//         writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//       }
//       writeBlock(
//         "MCALL CYCLE87(" + xyzFormat.format(RTP) +
//         ", " + xyzFormat.format(RFP) +
//         ", " + xyzFormat.format(SDIS) +
//         ", " + xyzFormat.format(DP) +
//         ", " /*+ xyzFormat.format(DPR)*/ +
//         ", " + SDIR + ")"
//       );
//     }
//     break;
//   case "fine-boring":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     var RPA = 0; // return path in abscissa of the active plane (enter incrementally with)
//     var RPO = 0; // return path in the ordinate of the active plane (enter incrementally sign)
//     var RPAP = 0; // return plane in the applicate (enter incrementally with sign)
//     var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
//     writeBlock(
//       "MCALL CYCLE86(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + conditional(DTB > 0, secFormat.format(DTB)) +
//       ", " + SDIR +
//       ", " + xyzFormat.format(RPA) +
//       ", " + xyzFormat.format(RPO) +
//       ", " + xyzFormat.format(RPAP) +
//       ", " + xyzFormat.format(POSS) + ")"
//     );
//     break;
//   case "back-boring":
//     expandCurrentCycle = true;
//     break;
//   case "manual-boring":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     writeBlock(
//       "MCALL CYCLE88(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + conditional(DTB > 0, secFormat.format(DTB)) +
//       ", " + SDIR + ")"
//     );
//     break;
//   case "boring":
//     if (RTP > getCurrentPosition().z) {
//       writeBlock(gMotionModal.format(0), zOutput.format(RTP));
//     }
//     // retract feed is ignored
//     writeBlock(
//       "MCALL CYCLE89(" + xyzFormat.format(RTP) +
//       ", " + xyzFormat.format(RFP) +
//       ", " + xyzFormat.format(SDIS) +
//       ", " + xyzFormat.format(DP) +
//       ", " /*+ xyzFormat.format(DPR)*/ +
//       ", " + conditional(DTB > 0, secFormat.format(DTB)) + ")"
//     );
//     break;
//   default:
//     expandCurrentCycle = true;
//   }
//   if (!expandCurrentCycle) {
//     xOutput.reset();
//     yOutput.reset();
//   }
// }

function onCycle() { //mcall replace anton 
  // writeBlock(gPlaneModal.format(17)); //g17 anton
  writeWords(" ;  " + cycleType) //anton
  expandCurrentCycle = false;

  if ((cycleType != "tapping") &&
      (cycleType != "right-tapping") &&
      (cycleType != "left-tapping") &&
      !isProbeOperation() &&
      (cycleType != "tapping-with-chip-breaking")) {
    writeBlock(feedOutput.format(cycle.feedrate/spindleSpeed)); //g95 anton
  }

  var RTP = cycle.clearance; // return plane (absolute) 
  var RFP = cycle.stock; // reference plane (absolute)
  var SDIS = cycle.retract - cycle.stock; // safety distance
  var DP = cycle.bottom; // depth (absolute)
  // var DPR = RFP - cycle.bottom; // depth (relative to reference plane)
  var DTB = cycle.dwell;
  var SDIR = tool.clockwise ? 3 : 4; // direction of rotation: M3:3 and M4:4

  switch (cycleType) {
  case "drilling": //81
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    writeBlock(      
      // ", " + xyzFormat.format(RFP) +
      " R2=" + xyzFormat.format(SDIS) +
      " R3=" + xyzFormat.format(DP) +
      " R10=" + xyzFormat.format(RTP)
      // ", " /*+ xyzFormat.format(DPR)*/
    );
    writeBlock(gFormat.format(81));
    break;
  case "counter-boring": //82
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    writeBlock(            
      " R2=" + xyzFormat.format(SDIS) +
      " R3=" + xyzFormat.format(DP) +
      " R4=" + conditional(DTB > 0, secFormat.format(DTB)) +
      " R10=" + xyzFormat.format(RTP)
    );
    writeBlock(gFormat.format(82));
    break;
  case "chip-breaking":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    // add support for accumulated depth
    var FDEP = cycle.stock - cycle.incrementalDepth;
    var FDPR = cycle.incrementalDepth; // relative to reference plane (unsigned)
    var DAM = 0; // degression (unsigned)
    var DTS = 0; // dwell time at start
    var FRF = 1; // feedrate factor (unsigned)
    var VARI = 0; // chip breaking
    var _AXN = 3; // tool axis
    var _MDEP = cycle.incrementalDepth; // minimum drilling depth
    var _VRT = 0; // retraction distance
    var _DTD = (cycle.dwell != undefined) ? cycle.dwell : 0;
    var _DIS1 = 0; // limit distance

    // writeBlock(
    //   "MCALL CYCLE83(" + xyzFormat.format(RTP) +
    //   ", " + xyzFormat.format(RFP) +
    //   ", " + xyzFormat.format(SDIS) +
    //   ", " + xyzFormat.format(DP) +
    //   ", " /*+ xyzFormat.format(DPR)*/ +
    //   ", " + xyzFormat.format(FDEP) +
    //   ", " /*+ xyzFormat.format(FDPR)*/ +
    //   ", " + xyzFormat.format(DAM) +
    //   ", " + /*conditional(DTB > 0, secFormat.format(DTB))*/ // only dwell at bottom
    //   ", " + conditional(DTS > 0, secFormat.format(DTS)) +
    //   ", " + xyzFormat.format(FRF) +
    //   ", " + xyzFormat.format(VARI) +
    //   ", " + /*_AXN +*/
    //   ", " + xyzFormat.format(_MDEP) +
    //   ", " + xyzFormat.format(_VRT) +
    //   ", " + secFormat.format(_DTD) +
    //   ", 0" + /*xyzFormat.format(_DIS1) +*/
    //   ")"
    // );
    writeBlock(      
      conditional(DTS > 0, " R0=" + secFormat.format(DTS)) + //xyzFormat.format(DTS) +
      " R1=" + xyzFormat.format(FDPR) +
      " R2=" + xyzFormat.format(SDIS) +
      " R3=" + xyzFormat.format(DP) +
      conditional(DTB > 0, " R4=" + secFormat.format(DTB)) +
      " R5=" + xyzFormat.format(_MDEP) +
      " R10=" + xyzFormat.format(RTP)
      // " R11=" + xyzFormat.format(VARI)
    );
    writeBlock(" ", gFormat.format(83));
    break;
  case "deep-drilling":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var FDEP = cycle.stock - cycle.incrementalDepth;
    var FDPR = cycle.incrementalDepth; // relative to reference plane (unsigned)
    var DAM = 0; // degression (unsigned)
    var DTS = 0; // dwell time at start
    var FRF = 1; // feedrate factor (unsigned)
    var VARI = 1; // full retract
    var _MDEP = cycle.incrementalDepth; // minimum drilling depth
    var _VRT = 0; // retraction distance
    var _DTD = (cycle.dwell != undefined) ? cycle.dwell : 0;
    var _DIS1 = 0; // limit distance

    writeBlock(      
      conditional(DTS > 0, " R0=" + secFormat.format(DTS)) +
      " R1=" + xyzFormat.format(FDPR) +
      " R2=" + xyzFormat.format(SDIS) +
      " R3=" + xyzFormat.format(DP) +
      conditional(DTB > 0, " R4=" + secFormat.format(DTB)) +
      " R5=" + xyzFormat.format(_MDEP) +
      " R10=" + xyzFormat.format(RTP) +
      " R11=" + xyzFormat.format(VARI)
    );
    writeBlock(" ", gFormat.format(83));

    // writeBlock(
    //   "MCALL CYCLE83(" + xyzFormat.format(RTP) +
    //   ", " + xyzFormat.format(RFP) +
    //   ", " + xyzFormat.format(SDIS) +
    //   ", " + xyzFormat.format(DP) +
    //   ", " /*+ xyzFormat.format(DPR)*/ +
    //   ", " + xyzFormat.format(FDEP) +
    //   ", " /*+ xyzFormat.format(FDPR)*/ +
    //   ", " + xyzFormat.format(DAM) +
    //   ", " + /*conditional(DTB > 0, secFormat.format(DTB)) +*/ // only dwell at bottom
    //   ", " + conditional(DTS > 0, secFormat.format(DTS)) +
    //   ", " + xyzFormat.format(FRF) +
    //   ", " + xyzFormat.format(VARI) +
    //   ", " + /*_AXN +*/
    //   ", " + xyzFormat.format(_MDEP) +
    //   ", " + xyzFormat.format(_VRT) +
    //   ", " + secFormat.format(_DTD) +
    //   ", 0" + /*xyzFormat.format(_DIS1) +*/
    //   ")"
    // );
    break;
  case "tapping":
  case "left-tapping":
  case "right-tapping":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var SDAC = SDIR; // direction of rotation after end of cycle
    var MPIT = 0; // thread pitch as thread size
    var PIT = ((tool.type == TOOL_TAP_LEFT_HAND) ? -1 : 1) * tool.threadPitch; // thread pitch
    var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
    var SST = tool.spindleRPM; // speed for tapping
    var SST1 = tool.spindleRPM; // speed for return
    writeBlock(      
      " R2=" + xyzFormat.format(SDIS) +
      " R3=" + xyzFormat.format(DP) +
      // conditional(DTB > 0, " R4=" + secFormat.format(DTB)) +
      // " R6=0" + //issiaiskinti
      // " R7=" + SDIR + //issiaiskinti
      // " R8=1" + //issiaiskinti anton
      " R9=" + xyzFormat.format(PIT) +
      " R10=" + xyzFormat.format(RTP)
    );
    writeBlock(" ", gFormat.format(84));
    // writeBlock(
    //   "MCALL CYCLE84(" + xyzFormat.format(RTP) +
    //   ", " + xyzFormat.format(RFP) +
    //   ", " + xyzFormat.format(SDIS) +
    //   ", " + xyzFormat.format(DP) +
    //   ", " /*+ xyzFormat.format(DPR)*/ +
    //   ", " + conditional(DTB > 0, secFormat.format(DTB)) +
    //   ", " + xyzFormat.format(SDAC) +
    //   ", " + xyzFormat.format(MPIT) +
    //   ", " + xyzFormat.format(PIT) +
    //   ", " + xyzFormat.format(POSS) +
    //   ", " + xyzFormat.format(SST) +
    //   ", " + xyzFormat.format(SST1) + ")"
    // );
    break;
  case "tapping-with-chip-breaking":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var SDAC = SDIR; // direction of rotation after end of cycle
    var MPIT = 0; // thread pitch as thread size
    var PIT = ((tool.type == TOOL_TAP_LEFT_HAND) ? -1 : 1) * tool.threadPitch; // thread pitch
    var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
    var SST = tool.spindleRPM; // speed for tapping
    var SST1 = tool.spindleRPM; // speed for return
    var _AXN = 0; // tool axis
    var _PTAB = 0; // must be 0
    var _TECHNO = 0; // technology settings
    var _VARI = 1; // machining type: 0 = tapping full depth, 1 = tapping partial retract, 2 = tapping full retract
    var _DAM = cycle.incrementalDepth; // incremental depth
    var _VRT = cycle.chipBreakDistance; // retract distance for chip breaking
    writeBlock(      
      " R2=" + xyzFormat.format(SDIS) +
      " R3=" + xyzFormat.format(DP) +
      // conditional(DTB > 0, " R4=" + secFormat.format(DTB)) +
      // " R6=0" + //issiaiskinti
      // " R7=" + SDIR + //issiaiskinti
      // " R8=1" + //issiaiskinti anton
      " R9=" + xyzFormat.format(PIT) +
      " R10=" + xyzFormat.format(RTP)
    );
    writeBlock(" ", gFormat.format(84));
    // writeBlock(
    //   "MCALL CYCLE84(" + xyzFormat.format(RTP) +
    //   ", " + xyzFormat.format(RFP) +
    //   ", " + xyzFormat.format(SDIS) +
    //   ", " + xyzFormat.format(DP) +
    //   ", " /*+ xyzFormat.format(DPR)*/ +
    //   ", " + secFormat.format(DTB) +
    //   ", " + xyzFormat.format(SDAC) +
    //   ", " /*+ xyzFormat.format(MPIT)*/ +
    //   ", " + xyzFormat.format(PIT) +
    //   ", " + xyzFormat.format(POSS) +
    //   ", " + xyzFormat.format(SST) +
    //   ", " + xyzFormat.format(SST1) +
    //   ", " + xyzFormat.format(_AXN) +
    //   ", " + xyzFormat.format(_PTAB) +
    //   ", " + xyzFormat.format(_TECHNO) +
    //   ", " + xyzFormat.format(_VARI) +
    //   ", " + xyzFormat.format(_DAM) +
    //   ", " + xyzFormat.format(_VRT) + ")"
    // );
    break;
  case "reaming":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var FFR = cycle.feedrate / spindleSpeed; //g95 
    var RFF = cycle.retractFeedrate  / spindleSpeed; //g95

    writeBlock(
      
      " R2=" + xyzFormat.format(SDIS) +
      " R3=" + xyzFormat.format(DP) +
      conditional(DTB > 0, " R4=" + secFormat.format(DTB)) +
      " R10=" + xyzFormat.format(RTP) +
      " R16=" + xyzFormat.format(FFR) +
      " R17=" + xyzFormat.format(RFF)
    );
    writeBlock(" ", gFormat.format(85));
    // writeBlock(
    //   "MCALL CYCLE85(" + xyzFormat.format(RTP) +
    //   ", " + xyzFormat.format(RFP) +
    //   ", " + xyzFormat.format(SDIS) +
    //   ", " + xyzFormat.format(DP) +
    //   ", " /*+ xyzFormat.format(DPR)*/ +
    //   ", " + conditional(DTB > 0, secFormat.format(DTB)) +
    //   ", " + xyzFormat.format(FFR) +
    //   ", " + xyzFormat.format(RFF) + ")"
    // );
    break;
  case "stop-boring":
    if (cycle.dwell > 0) {
      expandCurrentCycle = true;
    } else {
      if (RTP > getCurrentPosition().z) {
        writeBlock(gMotionModal.format(0), zOutput.format(RTP));
      }
      writeBlock(
        "MCALL CYCLE87(" + xyzFormat.format(RTP) +
        ", " + xyzFormat.format(RFP) +
        ", " + xyzFormat.format(SDIS) +
        ", " + xyzFormat.format(DP) +
        ", " /*+ xyzFormat.format(DPR)*/ +
        ", " + SDIR + ")"
      );
    }
    break;
  case "fine-boring":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    var RPA = 0; // return path in abscissa of the active plane (enter incrementally with)
    var RPO = 0; // return path in the ordinate of the active plane (enter incrementally sign)
    var RPAP = 0; // return plane in the applicate (enter incrementally with sign)
    var POSS = 0; // spindle position for oriented spindle stop in cycle (in degrees)
    writeBlock(
      "MCALL CYCLE86(" + xyzFormat.format(RTP) +
      ", " + xyzFormat.format(RFP) +
      ", " + xyzFormat.format(SDIS) +
      ", " + xyzFormat.format(DP) +
      ", " /*+ xyzFormat.format(DPR)*/ +
      ", " + conditional(DTB > 0, secFormat.format(DTB)) +
      ", " + SDIR +
      ", " + xyzFormat.format(RPA) +
      ", " + xyzFormat.format(RPO) +
      ", " + xyzFormat.format(RPAP) +
      ", " + xyzFormat.format(POSS) + ")"
    );
    break;
  case "back-boring":
    expandCurrentCycle = true;
    break;
  case "manual-boring":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    writeBlock(
      "MCALL CYCLE88(" + xyzFormat.format(RTP) +
      ", " + xyzFormat.format(RFP) +
      ", " + xyzFormat.format(SDIS) +
      ", " + xyzFormat.format(DP) +
      ", " /*+ xyzFormat.format(DPR)*/ +
      ", " + conditional(DTB > 0, secFormat.format(DTB)) +
      ", " + SDIR + ")"
    );
    break;
  case "boring":
    if (RTP > getCurrentPosition().z) {
      writeBlock(gMotionModal.format(0), zOutput.format(RTP));
    }
    // retract feed is ignored
    writeBlock(
      "MCALL CYCLE89(" + xyzFormat.format(RTP) +
      ", " + xyzFormat.format(RFP) +
      ", " + xyzFormat.format(SDIS) +
      ", " + xyzFormat.format(DP) +
      ", " /*+ xyzFormat.format(DPR)*/ +
      ", " + conditional(DTB > 0, secFormat.format(DTB)) + ")"
    );
    break;
  default:
    expandCurrentCycle = true;
  }
  if (!expandCurrentCycle) {
    xOutput.reset();
    yOutput.reset();
  }
}

function approach(value) {
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

function onCyclePoint(x, y, z) {
  if (isProbeOperation()) {
    currentWorkOffset = undefined;

/* probing cycle
    _MVAR  (CYCLE977)
      101 = Datum shift determine in hole with datum shift correction
      102 = "" circular boss ""
      103 = "" channel ""
      104 = "" wall ""
      105 = "" rectangle inside ""
      106 = "" rectangle outside ""
      ---
      1101 = Datum shift determine in hole with guardian zone with datum shift correction
      1102 = "" circular boss ""
      1103 = "" channel ""
      1104 = "" wall ""
      1105 = "" rectangle inside ""
*/

    var _MVAR = "_MVAR="; // CYCLE TYPE
    	var _MVAR_VALUE = xyzFormat.format(0);
    var _MA = "_MA="; // number of the axis, X=1, Y=2, Z=3
	var _MA_VALUE = xyzFormat.format(0);

    if (tool.number >= 100) {
      error(localize("Tool number is out of range for probing. Tool number must be below 100."));
      return;
    }
    var _PRNUM = "_PRNUM=" + xyzFormat.format(1); 
  	var _PRNUM_VALUE = xyzFormat.format(1); 
    var _KNUM = "_KNUM=" + xyzFormat.format(currentSection.workOffset); // automatically input in active workOffset. e.g. _KNUM=1 (G54)
    	var _KNUM_VALUE = xyzFormat.format(10000 + currentSection.workOffset);
    var _VMS = "_VMS=" + xyzFormat.format(0); // Feed of probing. 0=150mm/min, >1=300m/min
	var _VMS_VALUE = xyzFormat.format(0);  
    var _TSA = "_TSA=" + xyzFormat.format(1); // tolerance (trust area)
    	var _TSA_VALUE = xyzFormat.format(1);	
    var _NMSP = "_NMSP=" + xyzFormat.format(1); // number of measurements at same spot
    	var _NMSP_VALUE = xyzFormat.format(1);	
    var _ID = "_ID=" + xyzFormat.format(-Math.abs(cycle.clearance - (z - cycle.depth))); // incremental depth infeed in Z, direction over sign (only by circular boss, wall resp. rectangle and by hole/channel/circular boss/wall with guard zone)
    	var _ID_VALUE = xyzFormat.format(-Math.abs(cycle.clearance - (z - cycle.depth)));
    var _SZA = "_SZA=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1 - 4 * (cycle.probeClearance)) : ""); // increment depth  // diameter or width of guard zone (inside hole/channel, outside circular boss/wall), length of guard zone in X (only by rectangle)
    	var _SZA_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1 - 4 * (cycle.probeClearance)) : "");
    var _SZO = "_SZO=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1 - 4 * (cycle.probeClearance)) : ""); // increment depth  // diameter or width of guard zone (inside hole/channel, outside circular boss/wall), length of guard zone in Y (only by rectangle)
    	var _SZO_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1 - 4 * (cycle.probeClearance)) : "");
    var _TNAME = "\"" + tool.description.toUpperCase() + "\"";
    var _TZL = 	xyzFormat.format(0);	
    var _TDIF = xyzFormat.format(1.01);
    var _TUL = xyzFormat.format(1.01);
    var _TLL = xyzFormat.format(-1.01);
    var _TMV = xyzFormat.format(.34);
    var _K =  xyzFormat.format(1);
    var _EVNUM = xyzFormat.format(0);
    var _MCBIT = xyzFormat.format(0);
    var _DMODE = xyzFormat.format(1);
    var _AMODE = xyzFormat.format(1);
    var  _SETV0 = "_SETV[0]=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value in X
    	var _SETV0_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : "");
    var _SETV1 = "_SETV[1]=" + (cycle.width2 != undefined ? xyzFormat.format(cycle.width2) : ""); // nominal value in Y
	var _SETV1_VALUE = (cycle.width2 != undefined ? xyzFormat.format(cycle.width2) : "");
    // _FA is always in mm
    var _FA = "_FA=" + // measuring range (distance to surface), total measuring range=2*_FA in mm
      xyzFormat.format(((unit == MM) ? 1 : 25.4) * ((cycle.probeClearance !== undefined) ? cycle.probeClearance : cycle.probeOvertravel));

	var _FA_VALUE = xyzFormat.format(((unit == IN) ? 1 : 25.4) * ((cycle.probeClearance !== undefined) ? cycle.probeClearance : cycle.probeOvertravel));

    switch (cycleType) {
    case "probing-x":
    	var _SETVAL = "_SETVAL=" + xyzFormat.format((cycleType == "probing-x" ? x : y) + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter/2));
      	var _SETVAL_VALUE = xyzFormat.format((cycleType == "probing-x" ? x : y) + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter/2));
      
      _MVAR += xyzFormat.format(100);
      	_MVAR_VALUE += xyzFormat.format(100);
      
      _MA += xyzFormat.format(cycleType == "probing-x" ? 1 : 2);
      	_MA_VALUE += xyzFormat.format(cycleType == "probing-x" ? 1 : 2);
      
      	  var _MD_VALUE = "";		
      
      
      
	writeBlock(gMotionModal.format(0), zOutput.format(z - cycle.depth));
      
	//writeBlock("$P_UIFR[" + currentSection.workOffset + ", X, FI]=0");
	//writeBlock("$P_UIFR[" + currentSection.workOffset + ", Y, FI]=0");
	//writeBlock("$P_UIFR[" + currentSection.workOffset + ", Z, FI]=0");
	
	writeBlock("CYCLE978(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
		+ _FA_VALUE + "," + _TSA_VALUE + "," + _MA_VALUE + "," + _MD_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," 
		+ _TUL + "," + _TLL + "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
      
      break;
    case "probing-y":
      var _SETVAL = "_SETVAL=" + xyzFormat.format((cycleType == "probing-x" ? x : y) + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter/2));
      	var _SETVAL_VALUE = xyzFormat.format((cycleType == "probing-x" ? x : y) + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter/2));
      
      _MVAR += xyzFormat.format(100);
      	_MVAR_VALUE += xyzFormat.format(100);
      
      _MA += xyzFormat.format(cycleType == "probing-x" ? 1 : 2);
      	_MA_VALUE += xyzFormat.format(cycleType == "probing-x" ? 1 : 2);
      
      	  var _MD_VALUE = "";		
      
      
	writeBlock(gMotionModal.format(0), zOutput.format(z - cycle.depth));
      
	
	
	writeBlock("CYCLE978(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
		+ _FA_VALUE + "," + _TSA_VALUE + "," + _MA_VALUE + "," + _MD_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," 
		+ _TUL + "," + _TLL + "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
      
      break;
    case "probing-z":
    
      // _FA1 is always in mm
      var _FA1 = ((unit == MM) ? 1 : 25.4) * cycle.probeClearance;
      	var _FA1_VALUE = ((unit == MM) ? 1 : 25.4) * cycle.probeClearance;
      var _SETVAL = "_SETVAL=" + xyzFormat.format(z - cycle.depth);
      	var _SETVAL_VALUE = xyzFormat.format(z - cycle.depth);
      _MVAR += xyzFormat.format(100);
      	_MVAR_VALUE += xyzFormat.format(100);
      _MA += xyzFormat.format(3);
      	_MA_VALUE += xyzFormat.format(3);
      
        var _MD_VALUE = xyzFormat.format(2);	
      
	writeBlock(gMotionModal.format(0), zOutput.format(z - cycle.depth + _FA1/2));
      	
      	
	writeBlock("CYCLE978(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
		+ _FA_VALUE + "," + _TSA_VALUE + "," + _MA_VALUE + "," + _MD_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," 
		+ _TUL + "," + _TLL + "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
	
      break;
    case "probing-x-channel":
    case "probing-x-channel-with-island":
      var _SETVAL = "_SETVAL=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/channel/wall)
      	var _SETVAL_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : "");
      _MVAR += xyzFormat.format(cycleType == "probing-x-channel" ? 103 : 1003);
      	_MVAR_VALUE += xyzFormat.format(cycleType == "probing-x-channel" ? 103 : 1003);
      _MA += xyzFormat.format(1);
      	_MA_VALUE += xyzFormat.format(1);
      _STA1 = "_STA1=" + xyzFormat.format(0); // angle of the plane
      	_STA1_VALUE = xyzFormat.format(0);
      
      writeBlock(conditional(cycleType == "probing-x-channel", gMotionModal.format(0) + " " + zOutput.format(z - cycle.depth)));
      
      writeBlock("CYCLE977(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
	+ _SETV0_VALUE + "," + _SETV1_VALUE + "," + _FA_VALUE + "," + _TSA_VALUE + "," + _STA1_VALUE + "," + _ID_VALUE + "," + _SZA_VALUE 
	+ "," + _SZO_VALUE + "," + _MA_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," + _TUL + "," + _TLL 
	+ "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
      break;
    case "probing-y-channel":
    case "probing-y-channel-with-island":
      var _SETVAL = "_SETVAL=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/channel/wall)
      	var _SETVAL_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/chann
      _MVAR += xyzFormat.format(cycleType == "probing-y-channel" ? 103 : 1003);
      	_MVAR_VALUE += xyzFormat.format(cycleType == "probing-y-channel" ? 103 : 1003);
      _MA += xyzFormat.format(2);
      	_MA_VALUE += xyzFormat.format(2);
      _STA1 = "_STA1=" + xyzFormat.format(0); // angle of the plane
      	_STA1_VALUE = xyzFormat.format(0);
      
      writeBlock(conditional(cycleType == "probing-y-channel", gMotionModal.format(0) + " " + zOutput.format(z - cycle.depth)));
      
      writeBlock("CYCLE977(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
	+ _SETV0_VALUE + "," + _SETV1_VALUE + "," + _FA_VALUE + "," + _TSA_VALUE + "," + _STA1_VALUE + "," + _ID_VALUE + "," + _SZA_VALUE 
	+ "," + _SZO_VALUE + "," + _MA_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," + _TUL + "," + _TLL 
	+ "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
      break;
/* not supported currently, need min. 3 points to call this cycle (same as heindenhain)
    case "probing-xy-inner-corner":
      _MVAR += xyzFormat.format(105);
      writeBlock("CYCLE961");
      break;
    case "probing-xy-outer-corner":
      var _SETVAL = "_SETVAL=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/channel/wall)
      _MVAR += xyzFormat.format(106);
      _ID = xyzFormat.format(0);
      writeBlock(_PRNUM, _VMS, _NMSP, _FA);
      writeBlock(_MVAR, _SETVAL, _MA, _ID, _KNUM);
      writeBlock("CYCLE961");
      break;
*/
    case "probing-x-wall":
    case "probing-y-wall":
      var _SETVAL = "_SETVAL=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/channel/wall)
      	var _SETVAL_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : "");
      _MVAR += xyzFormat.format(104);
      	_MVAR_VALUE += xyzFormat.format(104);
      _MA += xyzFormat.format(cycleType == "probing-x-wall" ? 1 : 2);
      	_MA_VALUE += xyzFormat.format(cycleType == "probing-x-wall" ? 1 : 2);
      _STA1 = "_STA1=" + xyzFormat.format(0); // angle of the plane
      	_STA1_VALUE = xyzFormat.format(0);	
      
      writeBlock("$P_UIFR[" + currentSection.workOffset + ", X, FI]=0");
      writeBlock("$P_UIFR[" + currentSection.workOffset + ", Y, FI]=0");
      writeBlock("$P_UIFR[" + currentSection.workOffset + ", Z, FI]=0");
      
      writeBlock("CYCLE977(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
	+ _SETV0_VALUE + "," + _SETV1_VALUE + "," + _FA_VALUE + "," + _TSA_VALUE + "," + _STA1_VALUE + "," + _ID_VALUE + "," + _SZA_VALUE 
	+ "," + _SZO_VALUE + "," + _MA_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," + _TUL + "," + _TLL 
	+ "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
	
      break;
    case "probing-xy-circular-hole":
    case "probing-xy-circular-hole-with-island":
      var _SETVAL = "_SETVAL=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/channel/wall)
      	var _SETVAL_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : "");
      _MVAR += xyzFormat.format(cycleType == "probing-xy-circular-hole" ? 101 : 1001);
      	_MVAR_VALUE += xyzFormat.format(cycleType == "probing-xy-circular-hole" ? 101 : 1001);
      _STA1 = "_STA1=" + xyzFormat.format(0); // angle of the plane
      	_STA1_VALUE = xyzFormat.format(0);	
      writeBlock(conditional(cycleType == "probing-xy-circular-hole", gMotionModal.format(0) + " " + zOutput.format(z - cycle.depth)));
      
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", X, FI]=0");
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", Y, FI]=0");
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", Z, FI]=0");
	
	writeBlock("CYCLE977(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
		+ _SETV0_VALUE + "," + _SETV1_VALUE + "," + _FA_VALUE + "," + _TSA_VALUE + "," + _STA1_VALUE + "," + _ID_VALUE + "," + _SZA_VALUE 
		+ "," + _SZO_VALUE + "," + _MA_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," + _TUL + "," + _TLL 
		+ "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
	
      break;
    case "probing-xy-circular-boss":
      var _SETVAL = "_SETVAL=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/channel/wall)
      	var _SETVAL_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : "");
      _MVAR += xyzFormat.format(102);
      	_MVAR_VALUE += xyzFormat.format(102);
      _STA1 = "_STA1=" + xyzFormat.format(0); // angle of the plane
      	_STA1_VALUE = xyzFormat.format(0);
      
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", X, FI]=0");
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", Y, FI]=0");
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", Z, FI]=0");
	writeBlock("CYCLE977(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
		+ _SETV0_VALUE + "," + _SETV1_VALUE + "," + _FA_VALUE + "," + _TSA_VALUE + "," + _STA1_VALUE + "," + _ID_VALUE + "," + _SZA_VALUE 
		+ "," + _SZO_VALUE + "," + _MA_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," + _TUL + "," + _TLL 
		+ "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
	
      break;
    case "probing-xy-rectangular-hole":
    case "probing-xy-rectangular-boss":
    var _SETVAL = "_SETVAL=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/channel/wall)
      	var _SETVAL_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : "");
      _MVAR += xyzFormat.format(cycleType == "probing-xy-rectangular-hole" ? 105 : 106);
      	_MVAR_VALUE += xyzFormat.format(cycleType == "probing-xy-rectangular-hole" ? 105 : 106);
      _STA1 = "_STA1=" + xyzFormat.format(0); // angle of the plane
      	_STA1_VALUE = xyzFormat.format(0);
      writeBlock(conditional(cycleType == "probing-xy-rectangular-hole", gMotionModal.format(0) + " " + zOutput.format(z - cycle.depth)));
      
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", X, FI]=0");
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", Y, FI]=0");
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", Z, FI]=0");
	
	writeBlock("CYCLE977(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
		+ _SETV0_VALUE + "," + _SETV1_VALUE + "," + _FA_VALUE + "," + _TSA_VALUE + "," + _STA1_VALUE + "," + _ID_VALUE + "," + _SZA_VALUE 
		+ "," + _SZO_VALUE + "," + _MA_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," + _TUL + "," + _TLL 
		+ "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
	
      break;
    case "probing-xy-rectangular-hole-with-island":
    var _SETVAL = "_SETVAL=" + (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : ""); // nominal value (only by hole/circular boss/channel/wall)
      	var _SETVAL_VALUE = (cycle.width1 != undefined ? xyzFormat.format(cycle.width1) : "");
      _MVAR += xyzFormat.format(1105);
      	_MVAR_VALUE += xyzFormat.format(1105);
      _STA1 = "_STA1=" + xyzFormat.format(0); // angle of the plane
      	_STA1_VALUE = xyzFormat.format(0);
      
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", X, FI]=0");
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", Y, FI]=0");
	writeBlock("$P_UIFR[" + currentSection.workOffset + ", Z, FI]=0");
	
	writeBlock("CYCLE977(" + _MVAR_VALUE + "," + _KNUM_VALUE + ",," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," 
		+ _SETV0_VALUE + "," + _SETV1_VALUE + "," + _FA_VALUE + "," + _TSA_VALUE + "," + _STA1_VALUE + "," + _ID_VALUE + "," + _SZA_VALUE 
		+ "," + _SZO_VALUE + "," + _MA_VALUE + "," + _NMSP_VALUE + "," + _TNAME + ",," + _TZL + "," + _TDIF + "," + _TUL + "," + _TLL 
		+ "," + _TMV + "," + _K + "," + _EVNUM + ",," + _DMODE + "," + _AMODE + ")");
	
      break;
    case "probing-x-plane-angle":
    case "probing-y-plane-angle":
      _MVAR += xyzFormat.format(105);
      	_MVAR_VALUE += xyzFormat.format(105);
      _TSA = "_TSA=" + xyzFormat.format(0.1); // angle tolerance (in the simulation he move to the second point with this angle)
      	_TSA_VALUE = xyzFormat.format(0.1);
      _RA = "_RA=" + xyzFormat.format(0); // correction of angle, 0 dont rotate the table
      	_RA_VALUE = xyzFormat.format(0);
      _MA += xyzFormat.format(cycleType == "probing-x-plane-angle" ? 201 : 102);
      	_MA_VALUE += xyzFormat.format(cycleType == "probing-x-plane-angle" ? 201 : 102);
      _ID = "_ID=" + cycle.probeSpacing; // distance between point
      	_ID_VALUE = cycle.probeSpacing;
      _STA1 = "_STA1=" + xyzFormat.format(0); // angle of the plane
      	_STA1_VALUE = xyzFormat.format(0);
      var _SETVAL = "_SETVAL=" + xyzFormat.format((cycleType == "probing-x-plane-angle" ? x : y) + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter/2));
      	var _SETVAL_VALUE = xyzFormat.format((cycleType == "probing-x-plane-angle" ? x : y) + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter/2));
      writeBlock(gMotionModal.format(0), cycleType == "probing-x-plane-angle" ? yOutput.format(y - cycle.probeSpacing/2) : xOutput.format(x - cycle.probeSpacing/2));
      
      writeBlock(gMotionModal.format(0), zOutput.format(z - cycle.depth));
      
      
      writeBlock("CYCLE998(" + _MVAR_VALUE + "," + _KNUM_VALUE + "," + _RA_VALUE + "," + _PRNUM_VALUE + "," + _SETVAL_VALUE + "," + _STA1_VALUE + ",," + _FA_VALUE + "," + _TSA_VALUE + "," + _MA_VALUE + ",0," + _ID_VALUE + "," + _SETV0_VALUE + "," + _SETV1_VALUE + ",,," + _NMSP_VALUE + "," + _EVNUM + "," + _DMODE + "," + _AMODE + ")");
      break;
    default:
      cycleNotSupported();
    }
    return;
  }


  if (!expandCurrentCycle) {
    // place cycle operation in subprogram
    if (cycleSubprogramIsActive) {
      if (forceCycle || cycleExpanded || isProbeOperation()) {
        cycleSubprogramIsActive = false;
      } else if (!properties.useFilesForSubprograms) {
        // call subprogram
        // writeBlock("REPEAT LABEL" + currentSubprogram + " LABEL0");
        writeBlock("CALL BLOCK LABEL" + currentSubprogram + " TO LABEL0");
        subprogramStart(new Vector(x, y, z), new Vector(0, 0, 0), false);
      }
    }
    var _x = xOutput.format(x);
    var _y = yOutput.format(y);
    /*zOutput.format(z)*/
    if (_x || _y) {
      writeBlock(" ", _x, _y);
    }
  } else {
    expandCyclePoint(" ", x, y, z);
  }
}

function onCycleEnd() {
  if (cycleSubprogramIsActive) {
    subprogramEnd();
    cycleSubprogramIsActive = false;
  }
  if (!expandCurrentCycle) {
    writeBlock("  G80"); // end modal cycle //MCALL buvo anton
    zOutput.reset();
  }
  setWCS();

  zOutput.reset();
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(gMotionModal.format(0), x, y, z);
    forceFeed();
  }
}

function onLinear(_x, _y, _z, feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;

      if (tool.diameterOffset != 0) {
        warningOnce(localize("Diameter offset is not supported."), WARNING_DIAMETER_OFFSET);
      }

      writeBlock(gPlaneModal.format(17));
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, f);
        break;
      default:
        writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  if (currentSection.isOptimizedForMachine()) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(_a);
    var b = bOutput.format(_b);
    var c = cOutput.format(_c);
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
  } else {
    forceXYZ(); // required
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a3 = a3Output.format(_a);
    var b3 = b3Output.format(_b);
    var c3 = c3Output.format(_c);
    writeBlock(gMotionModal.format(0), x, y, z, a3, b3, c3);
  }
  forceFeed();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }

  if (currentSection.isOptimizedForMachine()) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(_a);
    var b = bOutput.format(_b);
    var c = cOutput.format(_c);
    var f = getFeed(feed);
    if (x || y || z || a || b || c) {
      writeBlock(gMotionModal.format(1), x, y, z, a, b, c, f);
    } else if (f) {
      if (getNextRecord().isMotion()) { // try not to output feed without motion
        forceFeed(); // force feed on next line
      } else {
        writeBlock(gMotionModal.format(1), f);
      }
    }
  } else {
    forceXYZ(); // required
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a3 = a3Output.format(_a);
    var b3 = b3Output.format(_b);
    var c3 = c3Output.format(_c);
    var f = getFeed(feed);
    if (x || y || z || a || b || c) {
      writeBlock(gMotionModal.format(1), x, y, z, a3, b3, c3, f);
    } else if (f) {
      if (getNextRecord().isMotion()) { // try not to output feed without motion
        forceFeed(); // force feed on next line
      } else {
        writeBlock(gMotionModal.format(1), f);
      }
    }
  }
}

// Start of onRewindMachine logic
/***** Be sure to add 'safeRetractDistance' to post properties. *****/
var performRewinds = true; // enables the onRewindMachine logic
var safeRetractFeed = (unit == IN) ? 20 : 500;
var safePlungeFeed = (unit == IN) ? 10 : 250;
var stockAllowance = (unit == IN) ? 0.1 : 2.5;


/** Retract to safe position before indexing rotaries. */
function moveToSafeRetractPosition(isRetracted) {
  writeRetract(Z);
  if (properties.forceHomeOnIndexing) {
    writeRetract(X, Y);
  }
}

/** Return from safe position after indexing rotaries. */
function returnFromSafeRetractPosition(position) {
  forceXYZ();
  xOutput.reset();
  yOutput.reset();
  zOutput.disable();
  onRapid(position.x, position.y, position.z);
  zOutput.enable();
  onRapid(position.x, position.y, position.z);
}

/** Determine if a point is on the correct side of a box side. */
function isPointInBoxSide(point, side) {
  var inBox = false;
  switch (side.side) {
  case "-X":
    if (point.x >= side.distance) {
      inBox = true;
    }
    break;
  case "-Y":
    if (point.y >= side.distance) {
      inBox = true;
    }
    break;
  case "-Z":
    if (point.z >= side.distance) {
      inBox = true;
    }
    break;
  case "X":
    if (point.x <= side.distance) {
      inBox = true;
    }
    break;
  case "Y":
    if (point.y <= side.distance) {
      inBox = true;
    }
    break;
  case "Z":
    if (point.z <= side.distance) {
      inBox = true;
    }
    break;
  }
  return inBox;
}

/** Intersect a point-vector with a plane. */
function intersectPlane(point, direction, plane) {
  var normal = new Vector(plane.x, plane.y, plane.z);
  var cosa = Vector.dot(normal, direction);
  if (Math.abs(cosa) <= 1.0e-6) {
    return undefined;
  }
  var distance = (Vector.dot(normal, point) - plane.distance) / cosa;
  var intersection = Vector.diff(point, Vector.product(direction, distance));
  
  if (!isSameDirection(Vector.diff(intersection, point).getNormalized(), direction)) {
    return undefined;
  }
  return intersection;
}

/** Intersect the point-vector with the stock box. */
function intersectStock(point, direction) {
  var stock = getWorkpiece();
  var sides = new Array(
    {x:1, y:0, z:0, distance:stock.lower.x, side:"-X"},
    {x:0, y:1, z:0, distance:stock.lower.y, side:"-Y"},
    {x:0, y:0, z:1, distance:stock.lower.z, side:"-Z"},
    {x:1, y:0, z:0, distance:stock.upper.x, side:"X"},
    {x:0, y:1, z:0, distance:stock.upper.y, side:"Y"},
    {x:0, y:0, z:1, distance:stock.upper.z, side:"Z"}
  );
  var intersection = undefined;
  var currentDistance = 999999.0;
  var localExpansion = -stockAllowance;
  for (var i = 0; i < sides.length; ++i) {
    if (i == 3) {
      localExpansion = -localExpansion;
    }
    if (isPointInBoxSide(point, sides[i])) { // only consider points within stock box
      var location = intersectPlane(point, direction, sides[i]);
      if (location != undefined) {
        if ((Vector.diff(point, location).length < currentDistance) || currentDistance == 0) {
          intersection = location;
          currentDistance = Vector.diff(point, location).length;
        }
      }
    }
  }
  return intersection;
}

/** Calculates the retract point using the stock box and safe retract distance. */
function getRetractPosition(currentPosition, currentDirection) {
  var retractPos = intersectStock(currentPosition, currentDirection);
  if (retractPos == undefined) {
    if (tool.getFluteLength() != 0) {
      retractPos = Vector.sum(currentPosition, Vector.product(currentDirection, tool.getFluteLength()));
    }
  }
  if ((retractPos != undefined) && properties.safeRetractDistance) {
    retractPos = Vector.sum(retractPos, Vector.product(currentDirection, properties.safeRetractDistance));
  }
  return retractPos;
}

/** Determines if the angle passed to onRewindMachine is a valid starting position. */
function isRewindAngleValid(_a, _b, _c) {
  // make sure the angles are different from the last output angles
  if (!abcFormat.areDifferent(getCurrentDirection().x, _a) &&
      !abcFormat.areDifferent(getCurrentDirection().y, _b) &&
      !abcFormat.areDifferent(getCurrentDirection().z, _c)) {
    error(
      localize("REWIND: Rewind angles are the same as the previous angles: ") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return false;
  }
  
  // make sure angles are within the limits of the machine
  var abc = new Array(_a, _b, _c);
  var ix = machineConfiguration.getAxisU().getCoordinate();
  var failed = false;
  if ((ix != -1) && !machineConfiguration.getAxisU().isSupported(abc[ix])) {
    failed = true;
  }
  ix = machineConfiguration.getAxisV().getCoordinate();
  if ((ix != -1) && !machineConfiguration.getAxisV().isSupported(abc[ix])) {
    failed = true;
  }
  ix = machineConfiguration.getAxisW().getCoordinate();
  if ((ix != -1) && !machineConfiguration.getAxisW().isSupported(abc[ix])) {
    failed = true;
  }
  if (failed) {
    error(
      localize("REWIND: Rewind angles are outside the limits of the machine: ") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return false;
  }
  
  return true;
}

function onRewindMachine(_a, _b, _c) {
  
  if (!performRewinds) {
    error(localize("REWIND: Rewind of machine is required for simultaneous multi-axis toolpath and has been disabled."));
    return;
  }
  
  
  
  // Determine if input angles are valid or will cause a crash
  if (!isRewindAngleValid(_a, _b, _c)) {
    error(
      localize("REWIND: Rewind angles are invalid:") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return;
  }
  
  // Work with the tool end point
  if (currentSection.getOptimizedTCPMode() == 0) {
    currentTool = getCurrentPosition();
  } else {
    currentTool = machineConfiguration.getOrientation(getCurrentDirection()).multiply(getCurrentPosition());
  }
  var currentABC = getCurrentDirection();
  var currentDirection = machineConfiguration.getDirection(currentABC);
  
  // Calculate the retract position
  var retractPosition = getRetractPosition(currentTool, currentDirection);

  // Output warning that axes take longest route
  if (retractPosition == undefined) {
    error(localize("REWIND: Cannot calculate retract position."));
    return;
  } else {
    var text = localize("REWIND: Tool is retracting due to rotary axes limits.");
    warning(text);
    writeComment(text);
  }

  // Move to retract position
  var position;
  if (currentSection.getOptimizedTCPMode() == 0) {
    position = retractPosition;
  } else {
    position = machineConfiguration.getOrientation(getCurrentDirection()).getTransposed().multiply(retractPosition);
  }
  onLinear(position.x, position.y, position.z, safeRetractFeed);
  
  //Position to safe machine position for rewinding axes
  moveToSafeRetractPosition(false);

  // Rotate axes to new position above reentry position
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  onRapid5D(position.x, position.y, position.z, _a, _b, _c);
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();

  // Move back to position above part
  if (currentSection.getOptimizedTCPMode() != 0) {
    position = machineConfiguration.getOrientation(new Vector(_a, _b, _c)).getTransposed().multiply(retractPosition);
  }
  returnFromSafeRetractPosition(position);

  // Plunge tool back to original position
  if (currentSection.getOptimizedTCPMode() != 0) {
    currentTool = machineConfiguration.getOrientation(new Vector(_a, _b, _c)).getTransposed().multiply(currentTool);
  }
  onLinear(currentTool.x, currentTool.y, currentTool.z, safePlungeFeed);
}
// End of onRewindMachine logic






function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  writeBlock(gPlaneModal.format(17));
  
  var start = getCurrentPosition();
  var turns = useArcTurn ? Math.floor(Math.abs(getCircularSweep())/(2 * Math.PI)) : 0; // full turns

  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    if (turns > 1) {
      error(localize("Multiple turns are not supported."));
      return;
    }
    // G90/G91 are dont care when we do not used XYZ
    switch (getCircularPlane()) {
    case PLANE_XY:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 17)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 18)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 19)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (useArcTurn) { // IJK mode
    if (isHelical()) {
      forceXYZ();
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 17)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      // arFormat.format(Math.abs(getCircularSweep()));
      if (turns > 0) {
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed), "TURN=" + turns);
      } else {
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      }
      break;
    case PLANE_ZX:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 18)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      if (turns > 0) {
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed), "TURN=" + turns);
      } else {
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      }
      break;
    case PLANE_YZ:
      if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
        if ((gPlaneModal.getCurrent() !== null) && (gPlaneModal.getCurrent() != 19)) {
          error(localize("Plane cannot be changed when radius compensation is active."));
          return;
        }
      }
      if (turns > 0) {
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed), "TURN=" + turns);
      } else {
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      }
      break;
    default:
      if (turns > 1) {
        error(localize("Multiple turns are not supported."));
        return;
      }
      if (properties.useCIP) { // allow CIP
        var ip = getPositionU(0.5);
        writeBlock(
          gAbsIncModal.format(90), "CIP",
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          "I1=" + xyzFormat.format(ip.x),
          "J1=" + xyzFormat.format(ip.y),
          "K1=" + xyzFormat.format(ip.z),
          getFeed(feed)
        );
        gMotionModal.reset();
        gPlaneModal.reset();
      } else {
        linearize(tolerance);
      }
    }
  } else { // use radius mode
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    forceXYZ();
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), "CR=" + xyzFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), zOutput.format(z), "CR=" + xyzFormat.format(r), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), yOutput.format(y), zOutput.format(z), "CR=" + xyzFormat.format(r), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var currentCoolantMode = undefined;

function forceCoolant() {
  currentCoolantMode = undefined;
}

function setCoolant(coolant) {
  if (coolant == currentCoolantMode) {
    return; // coolant is already active
  }
  
  var m;
  switch (coolant) {
  case COOLANT_OFF:
    m = 9;
    break;
  case COOLANT_FLOOD:
    m = 8;
    break;
    case COOLANT_THROUGH_TOOL: // <<<<< Add this case, change ?? to the actual code
    m = 7;
    break;
  default:
    onUnsupportedCoolant(coolant);
    m = 9;
  }
  
  if (m) {
    writeBlock(mFormat.format(m));
    currentCoolantMode = coolant;
  }
}

var mapCommand = {
  COMMAND_STOP:0,
  COMMAND_OPTIONAL_STOP:1,
  COMMAND_END:30,
  COMMAND_SPINDLE_CLOCKWISE:3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE:4,
  COMMAND_STOP_SPINDLE:5,
  COMMAND_ORIENTATE_SPINDLE:19,
  COMMAND_LOAD_TOOL:6
};

function onCommand(command) {
  switch (command) {
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    return;
  case COMMAND_COOLANT_OFF:
    setCoolant(COOLANT_OFF);
    return;
  case COMMAND_COOLANT_ON:
    setCoolant(COOLANT_FLOOD);
    return;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    return;
  case COMMAND_STOP_CHIP_TRANSPORT:
    return;
  case COMMAND_BREAK_CONTROL:
    return;
  case COMMAND_TOOL_MEASURE:
    return;
  }
  
  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  if (currentSection.isMultiAxis()) {
    writeBlock("TRAFOOF");
    writeBlock(gPlaneModal.reset()); //anton g17
    
  }

  // writeBlock(gPlaneModal.format(17)); //anton g17

  if (true) {
    if (isRedirecting()) {
      if (firstPattern) {
        var finalPosition = getFramePosition(currentSection.getFinalPosition());
        var abc;
        if (currentSection.isMultiAxis() && machineConfiguration.isMultiAxisConfiguration()) {
          abc = currentSection.getFinalToolAxisABC();
        } else {
          abc = currentWorkPlaneABC;
        }
        if (abc == undefined) {
          abc = new Vector(0, 0, 0);
        }
        setAbsoluteMode(finalPosition, abc);
        subprogramEnd();
      }
    }
  }

  forceAny();
}

properties.homeXYAtEnd = false;
if (propertyDefinitions === undefined) {
  propertyDefinitions = {};
}
propertyDefinitions.homeXYAtEnd = {title:"Home XY at end", description:"Specifies that the machine moves to the home position in XY at the end of the program.", type:"boolean"};

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  if (arguments.length == 0) {
    error(localize("No axis specified for writeRetract()."));
    return;
  }
  var block = "";
  var zIsOutput = false; //THIS LINE ADDED FOR D0 MODIFICATION
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
    case X:
      block += "X" + xyzFormat.format(machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : 0) + " ";
      break;
    case Y:
      block += "Y" + xyzFormat.format(machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : 0) + " ";
      break;
    case Z:
      block += "Z" + xyzFormat.format(machineConfiguration.getRetractPlane()) + " ";
      retracted = true; // specifies that the tool has been retracted to the safe plane
      zIsOutput = true;
      break;
    default:
      error(localize("Bad axis specified for writeRetract()."));
      return;
    }
  }
  if (false) { //block //anton supa
    gMotionModal.reset();
    writeBlock(gMotionModal.format(0), "SUPA " + block + conditional(zIsOutput, "D0")); // retract
  }
  zOutput.reset();
}

function onClose() {
  writeln("");

  writeRetract(Z);

  setWorkPlane(new Vector(0, 0, 0), true); // reset working plane

  writeln("G0 Z200.0 M5");


  if (properties.homeXYAtEnd) {
    writeRetract(X, Y);
  }
  writeln("G53 Y580.0");
  writeln("M29");
  writeln("GOTOB BEGIN ");

  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  writeln(mFormat.format(30)); // stop program, spindle stop, coolant off
  if (subprograms.length > 0) {
    writeln("");
    write(subprograms);
  }
}
