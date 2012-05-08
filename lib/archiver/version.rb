class Archiver
  MAJOR = 0
  MINOR = 0
  PATCH = 1
  BUILD = nil
  VERSION = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
end
