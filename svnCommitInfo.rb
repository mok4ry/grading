# svnCommitInfo.rb
#
# Tool for gathering statistics on the output of SVN log
# Assumes that no commit matches " *|*|*|* "
#
# Usage:
#   $ svn log > file.txt
#   $ ruby svnCommitInfo.rb file.txt
#     OR
#   $ svn log | ruby svnCommitInfo.rb
#
# @author Matt Mokary (mxm6060@rit.edu)

class GetSVNCommitInfo
    attr_accessor :numberOfCommits

    def initialize
        @commitsPerUser = Hash.new
        @commitTimesOfDay = Hash.new( 0 )
        @commitsByWeek = Hash.new( 0 )
        @numberOfCommits = 0
        @BAR_MAX_WIDTH = 80
        @DECORATIVE_PRINT_LENGTH = 70
        @MONTH_STRS = [ nil, "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
    end

    def main
        input = ARGF.read        
        input.each do |line|
            parseLine( line )
        end
    end

    def parseLine( line )
        splitLine = line.split(" | ")
        if splitLine.length == 4
            parseCommitInfo( splitLine )
        end
    end

    def parseCommitInfo( splitInfoLine )
        revision, author, date = getDataFromSplitLine(splitInfoLine)
        incrementNumberOfCommits
        addToCommitsByWeek( date.split(" ")[0] )
        addToCommitTimesOfDay( date.match(/\d\d:/)[0][0,2] )
        addToCommitsPerUser( author )
    end

    def getDataFromSplitLine( splitLine )
        return splitLine[0], splitLine[1], splitLine[2]
    end

    def incrementNumberOfCommits
        @numberOfCommits += 1
    end

    def addToCommitsByWeek( date )
        splitDate = date.split("-")
        month = splitDate[1]
        week = Integer( stripLeadingZero(splitDate[2]) ) / 7
        monthName = @MONTH_STRS[ Integer( stripLeadingZero(month) ) ]
        weekStr = "#{monthName}, week #{week}"
        incrementOrAdd( @commitsByWeek, weekStr )
    end

    def addToCommitsPerUser( auth )
        incrementOrAdd( @commitsPerUser, auth )
    end

    def addToCommitTimesOfDay( hour )
        hour = Integer( stripLeadingZero( hour ) )
        incrementOrAdd( @commitTimesOfDay, hour )
    end

    def incrementOrAdd( someHash, someKey )
        if someHash.include? someKey
            someHash[someKey] += 1
        else
            someHash[someKey] = 1
        end
    end

    def stripLeadingZero( strNum )
        strNum[0] == ?0.ord ? strNum[1..-1] : strNum
    end

    def printResults
        puts "\n"
        printCommitterInfoGraph
        puts "\n"
        printCommitTimesOfDayGraph
        puts "\n"
        printCommitsByWeekGraph
        puts "\n"
    end
    
    def printCommitterInfoGraph
        printCommitterInfoGraphLabel
        @commitsPerUser.sort_by {|k,v| v} .each do |auth,val|
            printBarOfCommitterInfo auth, val
        end
    end

    def printBarOfCommitterInfo( auth, num )
        bar = nHashtags( getWidthOfBar( num ) )
        percent = percentOfCommits( num )
        puts "#{forceNameTo8Chars(auth)}:  #{bar}  #{percent}% (#{num})"
    end

    def printCommitterInfoGraphLabel
        puts "-" * @DECORATIVE_PRINT_LENGTH
        puts "  " + "Number of commits by user"
        puts "  " + "Based on commits by #{@commitsPerUser.size} " +
            "users and #{@numberOfCommits} commits total."
        puts "-" * @DECORATIVE_PRINT_LENGTH
    end

    def forceNameTo8Chars( name )
        name.length < 8 ? name + " " * ( 8 - name.length ) : name[0..8]
    end

    def printCommitTimesOfDayGraph
        printCommitTimesOfDayGraphLabel
        (0..23).each do |hour|
            printBarOfCommitTimesOfDay hour
        end
    end

    def printBarOfCommitTimesOfDay( time )
        n = @commitTimesOfDay[time]
        bar = nHashtags( getWidthOfBar( n ) )
        percent = percentOfCommits( n )
        puts "#{padIntWithLeadingZero(time)}:  #{bar}  #{percent}%"
    end

    def printCommitTimesOfDayGraphLabel
        puts "-" * @DECORATIVE_PRINT_LENGTH
        puts "  " + "Commits by time of day (24-hour clock)"
        puts "-" * @DECORATIVE_PRINT_LENGTH
    end

    def printCommitsByWeekGraph
        printCommitsByWeekGraphLabel
        @commitsByWeek.each do |week,n|
            printBarOfCommitsByWeek week, n
        end
    end

    def printBarOfCommitsByWeek( week, n )
        bar = nHashtags( getWidthOfBar( n ) )
        percent = percentOfCommits( n )
        puts "#{week}:  #{bar}  #{percent}% (#{n})"
    end

    def printCommitsByWeekGraphLabel
        weeks = @commitsByWeek.size
        puts "-" * @DECORATIVE_PRINT_LENGTH
        puts "  " + "Commits by week"
        puts "  " + "Based on commits spanning #{weeks} weeks"
        puts "-" * @DECORATIVE_PRINT_LENGTH
    end

    def padIntWithLeadingZero( someInt )
        someInt < 10 ? "0" + someInt.to_s : someInt.to_s
    end

    def percentOfCommits( commits )
        ( commits.to_f / @numberOfCommits * 100 ).to_int
    end

    def getWidthOfBar( occurrences )
        ( occurrences.to_f / @numberOfCommits * @BAR_MAX_WIDTH ).to_int
    end

    def nHashtags( n )
        "#" * n
    end
end

if __FILE__ == $0
    getsvncominfo = GetSVNCommitInfo.new
    getsvncominfo.main
    getsvncominfo.printResults
end
