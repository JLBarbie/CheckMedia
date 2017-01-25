load "lib/video.rb"

# check-media <type> <path>

def usage()
    puts "Usage:"
    exit
end

conf = Hash.new

if (ARGV.count != 2)
    usage()
end

verbose = 0
if (ARGV[0] and ARGV[0] == "video")
    movie = ListMovie.new(ARGV[1])
    movie.list
    movie.check
    # movie.Result
end

if (ARGV[0] and ARGV[0] == "musique")
	verbose = 1
    movie = ListMovie.new(conf, verbose)
    movie.List
    movie.Check
    movie.Result
end
