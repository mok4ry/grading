# Usage:
#
#   Organize current working directory:
#       ruby organize.rb
#   Specify directory:
#       ruby organize.rb <directory with student files>
#
# Puts all files from one student into a folder with their name.
# Assumes file format used by the "myCourses" service
#
# Matt Mokary (mxm6060@rit.edu)

def main
    # 12345-1234567 - World, Hello - some-filename.zip
    filenameRegex = /\d+-\d+ - .+, .+ - .+/

    Dir.chdir( ARGV[0] || "." )
    Dir.foreach(".") do |filename|
        student = filenameRegex.match(filename) ? filename.split(" - ")[1] : ''
        if ( student.include?(", ") )
            if !(File.directory?(student))
                mkdir(student)
            end
            if !(File.directory?(filename))
                mv( filename, student )
            end
        end
    end
end

def mkdir( directory )
    system("mkdir " + escapeSpecialChars(directory))
end

def mv( file, destination )
    system("mv " + escapeSpecialChars(file) + " " +
        escapeSpecialChars(destination))
end

def escapeSpecialChars( str )
    specialChars = [ " ", "(", ")" ]
    newstr = ""
    str.each_char do |c|
        newstr += ( specialChars.include?(c) ) ? "\\" + c : c
    end
    newstr
end

if __FILE__ == $0
    main
end
