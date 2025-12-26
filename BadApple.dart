import 'dart:io';
import 'dart:async';

const int totalFrames = 6569;
const int targetWidth = 120;
const int targetHeight = 45;
const int sourceWidth = 640;
const int sourceHeight = 480;

void main(List<String> args) async {
  resizeTerminal(targetWidth, targetHeight);
  stdout.write('\x1B[2J\x1B[H');
  
  Process? audioProcess;
  try {
    audioProcess = await playAudio('BadApple.wav');
  } catch (e) {
    stderr.writeln('Audio error: $e');
  }

  StreamSubscription? sigintSubscription;
  if (!Platform.isWindows) { 
     sigintSubscription = ProcessSignal.sigint.watch().listen((signal) {
       audioProcess?.kill();
       stdout.write('\x1B[2J\x1B[H');
       exit(0);
     });
  } else {
     sigintSubscription = ProcessSignal.sigint.watch().listen((signal) {
       bool killed = audioProcess?.kill() ?? false;
       if (!killed) {}
       stdout.write('\x1B[2J\x1B[H'); 
       exit(0);
     });
  }

  Stopwatch stopwatch = Stopwatch()..start();
  const int frameDurationMs = 32;
  
  for (int i = 1; i <= totalFrames; i++) {
    int expectedTime = i * frameDurationMs;
    
    int currentWidth = targetWidth;
    int currentHeight = targetHeight;
    try {
      if (stdout.hasTerminal) {
        currentWidth = stdout.terminalColumns;
        currentHeight = stdout.terminalLines;
      }
    } catch (_) {}

    File file = File('data/out ($i).txt');
    if (!await file.exists()) {
      break; 
    }
    
    List<String> lines = await file.readAsLines();
    String frame = renderFrame(lines, currentWidth, currentHeight);
    
    int elapsed = stopwatch.elapsedMilliseconds;
    int waitTime = expectedTime - elapsed;
    
    if (waitTime > 0) {
      await Future.delayed(Duration(milliseconds: waitTime));
    }
    
    stdout.write('\x1B[H' + frame);
  }

  if (audioProcess != null) {
    audioProcess.kill();
  }
  sigintSubscription.cancel();
  exit(0);
}

String renderFrame(List<String> lines, int width, int height) {
  List<List<bool>> grid = List.generate(height, (_) => List.filled(width, false));

  for (int srcY = 0; srcY < lines.length; srcY++) {
    String line = lines[srcY].trim();
    if (line.isEmpty) continue;

    int drawHeight = height > 1 ? height - 1 : height; 
    
    int destY = (srcY * drawHeight) ~/ sourceHeight;
    if (destY >= drawHeight) continue;

    List<String> parts = line.split(' ');
    
    for (int k = 0; k < parts.length - 1; k += 2) {
      int? start = int.tryParse(parts[k]);
      int? end = int.tryParse(parts[k+1]);
      
      if (start != null && end != null) {
        int destXStart = (start * width) ~/ sourceWidth;
        int destXEnd = (end * width) ~/ sourceWidth;
        
        if (destXStart < 0) destXStart = 0;
        if (destXEnd >= width) destXEnd = width - 1;

        for (int x = destXStart; x <= destXEnd; x++) {
          grid[destY][x] = true;
        }
      }
    }
  }

  StringBuffer sb = StringBuffer();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      sb.write(grid[y][x] ? '#' : ' ');
    }
    
    if (y < height - 1) {
      sb.write('\n');
    }
  }
  return sb.toString();
}

void resizeTerminal(int width, int height) {
  if (Platform.isWindows) {
    try {
      Process.run('mode', ['con:', 'cols=$width', 'lines=${height + 1}']);
    } catch (e) {}
  } else {
    stdout.write('\x1B[8;${height + 1};${width}t');
  }
}

Future<Process?> playAudio(String filePath) async {
  if (Platform.isWindows) {
    return Process.start('powershell', [
      '-c',
      '(New-Object System.Media.SoundPlayer "$filePath").PlaySync()'
    ], mode: ProcessStartMode.detached);
  } else if (Platform.isMacOS) {
    return Process.start('afplay', [filePath], mode: ProcessStartMode.detached);
  } else if (Platform.isLinux) {
    try {
      var result = await Process.run('which', ['paplay']);
      if (result.exitCode == 0) {
        return Process.start('paplay', [filePath], mode: ProcessStartMode.detached);
      }
      return Process.start('aplay', [filePath], mode: ProcessStartMode.detached);
    } catch (e) {
      return Process.start('aplay', [filePath], mode: ProcessStartMode.detached);
    }
  }
  return null;
}