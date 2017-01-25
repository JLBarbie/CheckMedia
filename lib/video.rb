require "rvideo"
require "rubygems"
require "colorize"
require "streamio-ffmpeg"
require "io/console"

class ListMovie
	attr_reader :list

	def initialize(path)
		@path = path
        @width = 700 # 720
        @height = 320 #340
        @ratio = 2.11
        @contain = "mkv"
        @framerate = 0
        @maxSize = 2
        @minSize = 0.65
        @videoCodec = "h264"
        @audioCodec = ["aac", "ogg", "ac3", "mp3"]
        @audioChannels = 2
        @audioRate = 44100
	end

	def list
		@list = Dir.glob(@path + "/**/*")
        # puts @list
	end

	def Verbose(name, movie)
		puts name.split('/')[-1]
		puts movie.resolution
	end

    def checkWidth(file)
        if (file.width and file.width < @width)
            @error["width"] = " W:" + file.width.to_s
            @error["number"] += 1
        end
    end

    def checkHeight(file)
        if (file.height and file.height < @height)
            @error["height"] = " H:" + file.height.to_s
            @error["number"] += 1
        end
    end

    def checkRatio(file)
        if (file.height and file.width and
            (file.height / file.width) > @ratio - 0.11 and
            (file.height / file.width) > @ratio + 0.11)
            @error["ratio"] = " R:" + (file.height / file.width)
            @error["number"] += 1
        end
    end

    def checkContainer(file)
        if (file.split(".")[-1] != @contain)
            @error["container"] = " Ext:" + (file.split(".")[-1])
            @error["number"] += 1
        end
    end

    def checkFramerate(file)
        if (file.frame_rate and file.frame_rate < @framerate)
            @error["framerate"] = " Framerate:" + file.frame_rate
            @error["number"] += 1
        end
    end

    def checkMinSize(file)
        if (file.size and file.size < @minSize*1000000000)
            @error["lowSize"] = " Size:" + file.size
            @error["number"] += 1
        end
    end

    def checkMaxSize(file)
        if (file.size and file.size < @maxSize*1000000000)
            # @error["bigSize"] = " Size:" + file.size
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

    def checkAudioRate(file)
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
		contain = %w(avi mkv mov mp4 mpg mpeg wmv rm 3gp webm flv)
		@list.each do |movie|
            file = FFMPEG::Movie.new(movie)
			if movie.end_with? *contain
                @error = Hash.new
                @error["number"] = 0
                @error["name"] = movie.split("/")[-1]
                # puts file
                checkContainer(movie)

                checkWidth(file)
                checkHeight(file)
                checkRatio(file)

                checkFramerate(file)
                # checkVideoCodec(file)

                checkMinSize(file)
                # checkMaxSize(file)

                checkChannels(file)
                checkAudioCodec(file)
                checkAudioRate(file)
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
