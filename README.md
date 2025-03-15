# Beauty

![logs screenshot](resources/screenshot.png)

# Usage
```zig
pub fn main() !void {
  log.setLogLevel(log.LogLevel.trace);
  log.withTime(true);
  log.withThreadName(true);

  log.debug(@src(), "User got data!", .{});
  log.trace(@src(), "Tracing!", .{});
  log.info(@src(), "Here's info!", .{});
  log.warn(@src(), "Wow! Isn't it a warning???", .{});
  log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});
}
```
