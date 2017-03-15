# require 'id3lib'
require "streamio-ffmpeg"
require "ruby-progressbar"

class ListMusic
	attr_reader :list

	def initialize(path)
		@path = path
        @audioCodec = ["aac", "ogg", "ac3", "vorbis", "flac"]
        @audioChannels = 2
        @audioRate = 44100
        @bitrate = 44100
	end

	def list
		@list = Dir.glob(@path + "/**/*")
        # puts @list
	end

	def Verbose(name, movie)
		puts name.split('/')[-1]
		puts movie.resolution
	end

    def checkContainer(file)
        if (file.split(".")[-1] != @contain)
            @error["container"] = " Ext:" + (file.split(".")[-1])
            @error["number"] += 1
        end
    end

    def checkChannels(file)
        if (file.audio_channels and file.audio_channels < @audioChannels.to_i)
            @error["audioChannels"] = " AudioChannels:" + file.audio_channels
            @error["number"] += 1
        end
    end

    def checkAudioCodec(file)
        if (file.audio_codec and !@audioCodec.include? file.audio_codec)
            @error["audioCodec"] = " AudioCodec:" + file.audio_codec
            @error["number"] += 1
        end
    end

    def checkBitrate(file)
        if (file.audio_sample_rate and file.audio_sample_rate < @audioRate)
            @error["audioRate"] = " AudioRate:" + file.audio_sample_rate
            @error["number"] += 1
        end
    end

    def printError
        print "• ".red
        print @error["name"].yellow
        print @error["container"]

        print @error["width"]
        print @error["height"]
        print @error["ratio"]

        print @error["framerate"]
        print @error["videoCodec"]

        print @error["lowSize"]
        print @error["bigSize"]

        print @error["audioCodec"]
        print @error["audioChannels"]
        print @error["audioRate"]
        print "\n"
    end

	def check
        progressbar = ProgressBar.create
        progressbar.total = @list.length
		contain = %w(mp3 ogg flac)
		@list.each do |music|
            progressbar.increment
            file = FFMPEG::Movie.new(music)
			if music.end_with? *contain
                @error = Hash.new
                @error["number"] = 0
                @error["name"] = music.split("/")[-1]
                # puts file
                checkAudioCodec(file)
                if (@error["number"] > 0)
                    printError
                end
                # else
                #     print "•".green
			end
		end
	end

	def Result
		puts "
        Generating report"
		file = File.open("report.out", "w")
		file.puts "[Bad width]"
		file.puts @Bwidth
		file.puts "
        [Bad height]"
		file.puts @Bheight
		file.puts "
        [Bad container]"
		file.puts @Bcontain
		file.puts "
        [Bad size]"
		file.puts @Bsize
		file.puts "
        [Bad bitrate]"
		file.puts @Bbitrate
		file.puts "
        [Bad audio channels]"
		file.puts @Baudio
		file.close
	end

end
